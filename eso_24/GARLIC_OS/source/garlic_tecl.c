// Programador progT: Germán Puerto
// Librería Nintendo DS (libnds9)
#include <nds.h>

// Cabeceras del OS
#include <garlic_system.h>

// Gráficos
#include <garlic_font.h>

int _gt_bgKB, _gt_bgCursorKB;

int aux_output[] = {73, 110, 112, 117, 116, 32, 102, 111, 114, 32, 122, 48, 48, 
						32, 40, 80, 73, 68, 32, 48, 48, 48, 48, 48, 41, 58};
int aux_output2[]= {39, 65, 47, 66, 39, 58, 99, 97, 114, 97, 99, 116, 101, 114, 
						32, 32, 32, 39, 60, 47, 62, 39, 58, 112, 111, 115, 105, 
						99, 105, 111, 110};
int aux_output3[] = {39, 83, 69, 76, 69, 67, 84, 39, 58, 98, 111, 114, 114, 97, 
						32, 32, 32, 39, 83, 84, 65, 82, 84, 39, 58, 114, 101, 
						116, 117, 114, 110};

short divFreq3 = -20000;

// Rutina para inicializar la funcionalidad del teclado.
void _gt_initKB() {

	// Instalar RSI Teclado: irqSet (u32 irq, VoidFn handler)
	// En vez de setear la rutina solo en el IRQ de teclas, se pondrá junto un 
	// timer para conseguir que la freq de captación de teclado sea más humana.
	irqSet(IRQ_KEYS, _gt_rsiKB);
	irqSet(IRQ_TIMER3, _gt_timerKB);
	REG_KEYCNT = KEY_A | KEY_B | KEY_SELECT | KEY_START | KEY_RIGHT | KEY_LEFT | (1<<14);
	
	TIMER3_DATA = divFreq3;
	TIMER3_CR = 0xC2;  // Timer Start | Timer IRQ Enabled | Prescaler Selection 1 (F/64)

	// INICIALIZAR INTERFAZ TECLADO (instrucciones 6.2)
	// inicializar el procesador gráfico principal (A) en modo 5, con salida 
	// en la pantalla superior de la NDS
	
	// Modo 5 de Display Engine A en BG3 es Extended
	videoSetModeSub(MODE_5_2D);
	
	// reservar el banco de memoria de vídeo A
	vramSetBankC(VRAM_C_SUB_BG_0x06200000);	
	
	// inicializar los fondos gráficos 2 y 3 en modo Extended Rotation, con un
	// tamaño total de 512x512 píxeles	
	// mapbase*2(halfword dirección paleta)
	
	_gt_bgKB = bgInitSub(3, BgType_ExRotation, BgSize_ER_256x256, 5, 0);
	_gt_bgCursorKB = bgInitSub(2, BgType_ExRotation, BgSize_ER_256x256, 7, 0);
	
	// fijar el fondo 3 como más prioritario que el fondo 2
	bgSetPriority(_gt_bgKB, 2);
	bgSetPriority(_gt_bgCursorKB, 3);

	// descomprimir el contenido de la fuente de letras sobre una zona
	// adecuada de la memoria de vídeo
	decompress(garlic_fontTiles, bgGetGfxPtr(_gt_bgKB), LZ77Vram);
	
	// copiar la paleta de colores de la fuente de letras sobre la zona de
	// memoria correspondiente
	dmaCopy(garlic_fontPal, BG_PALETTE_SUB, sizeof(garlic_fontPal));
	
	_gt_mapbgKB = bgGetMapPtr(_gt_bgKB);
	_gt_mapbgCursorKB = bgGetMapPtr(_gt_bgCursorKB);
	
	// Imprimir caracteres del la interfaz estándar.
	int aux, i;
	for(i = 0; i < 25; i++) {
		aux = aux_output[i] - 32;
		_gt_mapbgKB[i + INPUT_COLS * 0] = aux;
		//_gt_mapbgCursorKB[i + INPUT_COLS * 3] = 99;
	}
	
	for(i = 0; i < 32; i++) {
		if (i == 0) _gt_mapbgKB[i + INPUT_COLS * 2] = 103;
		else if (i == 31) _gt_mapbgKB[i + INPUT_COLS * 2] = 102;
		else _gt_mapbgKB[i + INPUT_COLS * 2] = 99;	
	}
	for(i = 0; i < 32; i++) {
		if (i == 0) _gt_mapbgKB[i + INPUT_COLS * 4] = 100;
		else if (i == 31) _gt_mapbgKB[i + INPUT_COLS * 4] = 101;
		else _gt_mapbgKB[i + INPUT_COLS * 4] = 97;	
	}
	
	_gt_mapbgKB[0 + 32 * 3] = 96;	
	_gt_mapbgKB[31 + 32 * 3] = 98;	


	for(i = 0; i < 31; i++) {
		aux = aux_output2[i] - 32;
		_gt_mapbgKB[i + INPUT_COLS * 6] = aux;	
	}
	for(i = 0; i < 31; i++) {
		aux = aux_output3[i] - 32;
		_gt_mapbgKB[i + INPUT_COLS *8] = aux;	
	}
	
	_gt_mapbgCursorKB[LIM_LEFT + INPUT_SITE] = 97; // 97 = cursor
	
	bgHide(_gt_bgKB);
	bgHide(_gt_bgCursorKB);
}


void _gt_showKB() {	
	// Activamos la RSI
	irqEnable(IRQ_KEYS);
	irqEnable(IRQ_TIMER0);
	
	// Ponemos la variable del teclado a ON.
	_gt_activeKB = 1;

	// Mostramos la interfaz de teclado: void bgShow(int id)
	bgShow(_gt_bgKB);
	bgShow(_gt_bgCursorKB);

}

void _gt_hideKB() {
	// Desactivamos la RSI
	irqDisable(IRQ_KEYS);
	irqDisable(IRQ_TIMER0);

	// Ponemos la variable del teclado a OFF.
	_gt_activeKB = 0;
	
	// Escondemos la interfaz de teclado: void bgHide(int id)
	bgHide(_gt_bgKB);
	bgHide(_gt_bgCursorKB);

}