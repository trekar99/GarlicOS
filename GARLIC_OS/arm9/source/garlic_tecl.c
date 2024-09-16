// Programador progT: Germán Puerto
// Librería Nintendo DS (libnds9)
#include <nds.h>

// Cabeceras del OS
#include <garlic_system.h>

// Gráficos
#include <garlic_font.h>

int _gt_IPC_SYNC_enabled = 0; // Variable auxiliar de GARLIC_getXYbuttons

int _gt_bgKB, _gt_bgCursorKB, _gt_bgColors;

char aux_output[] = {73, 110, 112, 117, 116, 32, 102, 111, 114, 32, 122, 48, 48, 
						32, 40, 80, 73, 68, 32, 48, 48, 48, 48, 48, 41, 58};
char _gt_CAPS_min[4][32] = {{' ', ' ', '\\', ' ', '1', ' ', '2', ' ', '3', ' ', '4', ' ', '5', ' ', '6', ' ', '7', ' ', '8', ' ', '9', ' ', '0', ' ', '\'', ' ', '{', ' ', '~', ' ', ' ', ' '},
						   {' ', '@', ' ' , '<', ' ', 'q', ' ', 'w', ' ', 'e', ' ', 'r', ' ', 't', ' ', 'y', ' ', 'u', ' ', 'i', ' ', 'o' , ' ', 'p', ' ', '[', ' ', ' ', 'D', 'E', 'L', ' '},
						   {' ', 'C', 'A' , 'P', 'S', ' ', 'a', ' ', 's', ' ', 'd', ' ',  'f', ' ','g', ' ', 'h', ' ', 'j', ' ', 'k', ' ' , 'l', ' ', '-', ' ', 'I', 'N', 'T', 'R', 'O', ' '},
						   {' ', 'S', 'P' , 'A', 'C', 'E', ' ', 'z', ' ', 'x', ' ', 'c', ' ', 'v', ' ', 'b', ' ', 'n', ' ', 'm', ' ', ',' , ' ', '.', ' ', ' ', '<', '=', ' ', '=', '>', ' '}};

char _gt_CAPS_maj[4][32] = {{' ', ' ', '+', ' ', '!', ' ', '"', ' ', '#', ' ', '$', ' ', '%', ' ', '&', ' ', '/', ' ', '(', ' ', ')', ' ', '=', ' ', '?', ' ', '}', ' ', '|', ' ', ' ', ' '},
						   {' ', '*', ' ', '>', ' ', 'Q', ' ', 'W', ' ', 'E', ' ', 'R', ' ', 'T', ' ', 'Y', ' ', 'U', ' ', 'I', ' ', 'O', ' ', 'P', ' ', ']', ' ', ' ', 'D', 'E', 'L', ' '},
						   {' ', 'C', 'A', 'P', 'S', ' ', 'A', ' ', 'S', ' ', 'D', ' ', 'F',' ' , 'G', ' ', 'H', ' ', 'J', ' ', 'K', ' ', 'L', ' ', '_', ' ', 'I', 'N', 'T', 'R', 'O', ' '},
			    		   {' ', 'S', 'P', 'A', 'C', 'E', ' ', 'Z', ' ', 'X', ' ', 'C', ' ', 'V', ' ', 'B', ' ', 'N', ' ', 'M', ' ', ';', ' ', ':', ' ', ' ', '<', '=', ' ', '=', '>', ' '}};
 
int _gt_make_q12(char signo, int entero, int decimal) {

	float aux;
	float dec = decimal;
	
	while((int)dec > 0) dec = (dec / 10.0);
    
	aux = entero + dec;
	if (signo) aux = -aux;

	return MAKE_Q12(aux);
}

// Rutina para inicializar la funcionalidad del teclado.
void _gt_initKB() {
	int aux, i, j;

	// Instalar RSI IPC_SYNC: irqSet (u32 irq, VoidFn handler)
	// Servirá para captar las pulsaciones de teclado de las teclas X e Y.
	irqSet(IRQ_IPC_SYNC, _gt_rsi_KEYS_XY);
	REG_IPC_SYNC = IPC_SYNC_IRQ_ENABLE; // Permite al ARM9 recibir señales del ARM7.
	
	// Instalar RSI IPC_FIFO: irqSet (u32 irq, VoidFn handler)
	// Enviará una codificación de la captura táctil de teclado para escribir string.
	irqSet(IRQ_FIFO_NOT_EMPTY, _gt_rsi_IPC_FIFO);
	REG_IPC_FIFO_CR = IPC_FIFO_ENABLE | IPC_FIFO_RECV_IRQ;

	// Inicializar los fondos gráficos:
	// 1. Fondo tabla procesos
	// 2. Fondo teclas
	// 3. Fondo cursor string
	// 4. Fondo colores
	_gt_bgtable = bgInitSub(0, BgType_Text8bpp, BgSize_T_256x256, 0, 1);
	_gt_bgKB = bgInitSub(1, BgType_Text8bpp, BgSize_T_256x256, 1, 1);
	_gt_bgCursorKB = bgInitSub(2, BgType_Text8bpp, BgSize_T_256x256, 2, 1);
	_gt_bgColors = bgInitSub(3, BgType_Text8bpp, BgSize_T_256x256, 3, 1);
	
	// Fijar el fondo del cursos con más prioridad
	bgSetPriority(_gt_bgColors, 3);
	bgSetPriority(_gt_bgKB, 1);
	bgSetPriority(_gt_bgCursorKB, 0);

	// descomprimir el contenido de la fuente de letras sobre una zona
	// adecuada de la memoria de vídeo
	decompress(garlic_fontTiles, bgGetGfxPtr(_gt_bgKB), LZ77Vram);
	
	// copiar la paleta de colores de la fuente de letras sobre la zona de
	// memoria correspondiente
	dmaCopy(garlic_fontPal, BG_PALETTE_SUB, sizeof(garlic_fontPal));
	
	_gt_mapbgKB = bgGetMapPtr(_gt_bgKB);
	_gt_mapbgCursorKB = bgGetMapPtr(_gt_bgCursorKB);
	_gt_mapbgColors = bgGetMapPtr(_gt_bgColors);
	
	// Ponemos el fondo a color salmon.
	for(i = 0; i < (32*24); i++) _gt_mapbgColors[i] = COLOR_SALMON + 95;
	_gt_bgcolors_reset();

	// Imprimir caracteres del la interfaz estándar.
	for(i = 0; i < 25; i++) {
		aux = aux_output[i] - 32;
		_gt_mapbgKB[i + INPUT_COLS * 0] = aux;
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
	
	_gt_mapbgKB[0 + INPUT_COLS * 3] = 96;	
	_gt_mapbgKB[31 + INPUT_COLS * 3] = 98;	

	_gt_mapbgCursorKB[LIM_LEFT + INPUT_SITE] = 97; // 97 = cursor

	for (i = 0, j = INPUT_COLS * 6 + 2; i < 46; i++, j+=2)
	{
		_gt_mapbgColors[j] = COLOR_BLUE + ASCII_TILE;
		
		if(i==13) j+= 35;
		else if(i==26) j+=43;
		else if(i==36) j+=45;
	}
	
	_gt_setcapsKB();
	_gt_hideKB();
}

void _gt_enable_IPC_SYNC() {
	if (_gt_IPC_SYNC_enabled == 0) {
		irqSet(IRQ_IPC_SYNC, _gt_rsi_KEYS_XY);
		REG_IPC_SYNC = IPC_SYNC_IRQ_ENABLE; // Permite al ARM9 recibir señales del ARM7.
		irqEnable(IRQ_IPC_SYNC);
		_gt_IPC_SYNC_enabled = 1;
	}
}

void _gt_bgcolors_reset() {
	int i = 0;
	for(i = 1; i < 31; i++) _gt_mapbgColors[INPUT_SITE + i] = COLOR_WHITE + ASCII_TILE;
	for(i = 1; i < 31; i++) _gt_mapbgColors[(INPUT_SITE + 32) + i] = COLOR_WHITE + ASCII_TILE;
	for(i = 1; i < 31; i++) _gt_mapbgColors[(INPUT_SITE - 32) + i] = COLOR_WHITE + ASCII_TILE;
	_gt_mapbgColors[INPUT_SITE + LIM_LEFT] = COLOR_BLUE + ASCII_TILE;
	_gt_mapbgColors[(INPUT_SITE + 32) + LIM_LEFT] = COLOR_BLUE + ASCII_TILE;
	_gt_mapbgColors[(INPUT_SITE - 32) + LIM_LEFT] = COLOR_BLUE + ASCII_TILE;
}

void _gt_bgcolors_put(int pos) {
	_gt_mapbgColors[INPUT_SITE + pos] = COLOR_BLUE + ASCII_TILE;
	_gt_mapbgColors[(INPUT_SITE + 32) + pos] = COLOR_BLUE + ASCII_TILE;
	_gt_mapbgColors[(INPUT_SITE - 32) + pos] = COLOR_BLUE + ASCII_TILE;
}

char _gt_kb_check_type(int type, int pos, char ascii) {
	if (type == 1) {
		// Si primera posicion no es o +/- devuelve 0.
		if (pos == 1) { if ((ascii != 45) & (ascii != 32)) return 0; }
		else if ((ascii < 48) | (ascii > 57)) return 0;
	}
	
	else if (type == 2) {
		if (((ascii < 48) | (ascii > 57)) | ((ascii < 65) | (ascii > 70))) return 0;
	}
	
	else if (type == 3) {
		// Si primera posicion no es o +/- devuelve 0.
		if (pos == 1) { if ((ascii != 45) & (ascii != 32)) return 0; }
		else if (pos == 7) return 0;
		else if ((ascii < 48) | (ascii > 57)) return 0;
	}
	
	return 1;
}

void _gt_highlightKB(int mes, int ascii) {
	int i = 0;
	if (mes == 1) for(i = 0; i < 2; i++) _gt_mapbgColors[INPUT_COLS * 12 + 29 + i] = COLOR_PINK + ASCII_TILE;
	else if (mes == 2) for(i = 0; i < 2; i++) _gt_mapbgColors[INPUT_COLS * 12 + 26 + i] = COLOR_PINK + ASCII_TILE;
	else if (mes == 3) for(i = 0; i < 3; i++) _gt_mapbgColors[INPUT_COLS * 8 + 28 + i] = COLOR_PINK + ASCII_TILE;
	else if (mes == 4) for(i = 0; i < 5; i++) _gt_mapbgColors[INPUT_COLS * 10 + 26 + i] = COLOR_PINK + ASCII_TILE;
	else if (mes == 5) for(i = 0; i < 5; i++) _gt_mapbgColors[INPUT_COLS * 12 + LIM_LEFT + i] = COLOR_PINK + ASCII_TILE;
}

void _gt_setcapsKB() {
	int i;
	
	// Escoger entre set MAJ or MIN
	if(_gt_capsKB){
		for(i = 0; i < 32; i++)	_gt_mapbgKB[INPUT_COLS * 6 + i] = _gt_CAPS_maj[0][i]-32;
		for(i = 0; i < 32; i++)	_gt_mapbgKB[INPUT_COLS * 8 + i] = _gt_CAPS_maj[1][i]-32;
		for(i = 0; i < 32; i++)	_gt_mapbgKB[INPUT_COLS * 10 + i] = _gt_CAPS_maj[2][i]-32;
		for(i = 0; i < 32; i++) _gt_mapbgKB[INPUT_COLS * 12 + i] = _gt_CAPS_maj[3][i]-32;
		for(i = 0; i < 4; i++) _gt_mapbgColors[INPUT_COLS * 10 + LIM_LEFT + i] = COLOR_PINK + ASCII_TILE;
	} 
	
	else 
	{
		for(i = 0; i < 32; i++)	_gt_mapbgKB[INPUT_COLS * 6 + i] = _gt_CAPS_min[0][i]-32;
		for(i = 0; i < 32; i++)	_gt_mapbgKB[INPUT_COLS * 8 + i] = _gt_CAPS_min[1][i]-32;
		for(i = 0; i < 32; i++)	_gt_mapbgKB[INPUT_COLS * 10 + i] = _gt_CAPS_min[2][i]-32;
		for(i = 0; i < 32; i++) _gt_mapbgKB[INPUT_COLS * 12 + i] = _gt_CAPS_min[3][i]-32;
		for(i = 0; i < 4; i++) _gt_mapbgColors[INPUT_COLS * 10 + LIM_LEFT + i] = COLOR_BLUE + ASCII_TILE;
	}
	
	for(i = 0; i < 2; i++) _gt_mapbgColors[INPUT_COLS * 12 + 29 + i] = COLOR_BLUE + ASCII_TILE;
	for(i = 0; i < 2; i++) _gt_mapbgColors[INPUT_COLS * 12 + 26 + i] = COLOR_BLUE + ASCII_TILE;
	for(i = 0; i < 3; i++) _gt_mapbgColors[INPUT_COLS * 8 + 28 + i] = COLOR_BLUE + ASCII_TILE;
	for(i = 0; i < 5; i++) _gt_mapbgColors[INPUT_COLS * 10 + 26 + i] = COLOR_BLUE + ASCII_TILE;
	for(i = 0; i < 5; i++) _gt_mapbgColors[INPUT_COLS * 12 + LIM_LEFT + i] = COLOR_BLUE + ASCII_TILE;
}

void _gt_showKB() {	
	// Activamos la RSI
	irqEnable(IRQ_IPC_SYNC | IRQ_FIFO_NOT_EMPTY);	
	
	// Ponemos la variable del teclado a ON.
	_gt_activeKB = 1;

	// Mostramos la interfaz de teclado: void bgShow(int id)
	bgShow(_gt_bgKB);
	bgShow(_gt_bgCursorKB);
	bgShow(_gt_bgColors);

	bgHide(_gt_bgtable);
}

void _gt_hideKB() {
	// Desactivamos la RSI
	irqDisable(IRQ_IPC_SYNC | IRQ_FIFO_NOT_EMPTY);	
	_gt_IPC_SYNC_enabled = 0;
	
	// Ponemos la variable del teclado a OFF.
	_gt_activeKB = 0;
	
	// Escondemos la interfaz de teclado: void bgHide(int id)
	bgHide(_gt_bgKB);
	bgHide(_gt_bgCursorKB);
	bgHide(_gt_bgColors);
	
	bgShow(_gt_bgtable);

}