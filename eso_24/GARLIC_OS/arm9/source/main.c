/*------------------------------------------------------------------------------

	"main.c" : fase 2 / progM

	Versión final de GARLIC 2.0
	(carga de programas con 2 segmentos, listado de programas, gestión de
	 franjas de memoria)

------------------------------------------------------------------------------*/
#include <nds.h>

#include <garlic_system.h>	// definición de funciones y variables de sistema

extern int * punixTime;		// puntero a zona de memoria con el tiempo real

char indicadoresTeclas[8] = {'^', '>', 'v', '<', 'A', 'B', 'L', 'R'};
unsigned short bitsTeclas[8] = {KEY_UP, KEY_RIGHT, KEY_DOWN, KEY_LEFT, KEY_A, KEY_B,
									KEY_L, KEY_R};

const short divFreq0 = -33513982/1024;			// frecuencia de TIMER0 = 1 Hz
const short divFreq1 = -33513982/(1024*7);		// frecuencia de TIMER1 = 7 Hz
int pos = 0;


/* Funcion para gestionar los sincronismos  */
void gestionSincronismos()
{
	int i, mask;
	
	if (_gd_sincMain & 0xFFFE)		// si hay algun sincronismo pendiente
	{
		mask = 2;
		for (i = 1; i <= 15; i++)
		{
			if (_gd_sincMain & mask)
			{	// liberar la memoria del proceso terminado
				_gm_liberarMem(i);
				_gg_escribir("* %d: proceso terminado\n", i, 0, 0);
				_gs_dibujarTabla();
				_gd_sincMain &= ~mask;		// poner bit a cero
			}
			mask <<= 1;
		}
	}
}


/* Funcion para escoger una opcion con un boton (tecla) de la NDS */
int leerTecla(int num_opciones)
{
	int i, j, k;

	i = -1;							// marca de no seleccion
	do {
		_gp_WaitForVBlank();
		gestionSincronismos();
		scanKeys();
		k = keysDown();				// leer botones
		if (k != 0)
			for (j = 0; (j < num_opciones) && (i == -1); j++)
				if (k & bitsTeclas[j])
					i = j;			// deteccion de una opcion valida
	} while (i == -1);
	return i;
}

/* Funcio per pujar i baixar la llista de programes, ja que hi ha 11 programes i maxim en podem representar 8 pel total de tecles */
int escollirDesplacament()
{
	// Donem tres opcions, pujar, baixar o quedar-se al lloc 
	char str1[6] = "Amunt", str2[6] = "Quiet", str3[6] = "Avall";
	
	_gg_escribir("Indica desplacament llista de programes\n", 0, 0, 0);
	_gg_escribir("%c: %s\n", indicadoresTeclas[0], (unsigned int) str1, 0);
	_gg_escribir("%c: %s\n", indicadoresTeclas[1], (unsigned int) str2, 0);
	_gg_escribir("%c: %s\n", indicadoresTeclas[2], (unsigned int) str3, 0);
	
	return leerTecla(3);	// Llegim la tecla
}


/* Funcion para presentar una lista de opciones de tipo 'string' y escoger una */
int escogerString(char *strings[], int num_opciones)
{
	int j, i = 0;
	
	int x = escollirDesplacament();	// Ens retornara la tecla, pujar, baixar o quedar-se quiet
	
	if (x == 0 && pos > 0)	// Si escollim pujar '^' comprovem que poguem fer-ho i disminuim pos
	{
		pos--;
	}
	
	if (x == 2 && (pos + 8) < num_opciones)	// Si escollim baixar 'v' comprovem que poguem baixar i augmentem pos
	{
		pos++;
	}
	
	_gg_escribir("*** seleccionar programa :\n", 0, 0, 0);
	for (j = pos; j < pos + 8; j++)
	{								// mostrar opciones
		_gg_escribir("%c: %s\n", indicadoresTeclas[i], (unsigned int) strings[j], 0);
		i++;
	}
	
	return leerTecla(num_opciones)+pos; // Sumem pos per ajustar el index seleccionat ammb la posicio actual de la llista
}

/* Funcion para presentar una lista de opciones de tipo 'número' y escoger una */
int escogerNumero(const unsigned char numeros[], int num_opciones)
{
	int j;

	for (j = 0; j < num_opciones; j++)
	{								// mostrar opciones
		_gg_escribir("%c: %d\n", indicadoresTeclas[j], numeros[j], 0);
	}
	return numeros[leerTecla(num_opciones)];
}


/* Inicializaciones generales del sistema Garlic */
//------------------------------------------------------------------------------
void inicializarSistema() {
//------------------------------------------------------------------------------
	int v;

	_gg_iniGrafA();			// inicializar procesadores graficos
	_gs_iniGrafB();
	for (v = 0; v < 4; v++)	// para todas las ventanas
		_gd_wbfs[v].pControl = 0;		// inicializar los buffers de ventana
	_gs_dibujarTabla();

	_gd_seed = *punixTime;	// inicializar semilla para numeros aleatorios con
	_gd_seed <<= 16;		// el valor de tiempo real UNIX, desplazado 16 bits
	
	_gd_pcbs[0].keyName = 0x4C524147;	// "GARL"
	
	if (!_gm_initFS()) {
		_gg_escribir("ERROR: ?no se puede inicializar el sistema de ficheros!", 0, 0, 0);
		exit(0);
	}

	irqInitHandler(_gp_IntrMain);	// instalar rutina principal interrupciones
	irqSet(IRQ_VBLANK, _gp_rsiVBL);	// instalar RSI de vertical Blank
	irqEnable(IRQ_VBLANK);			// activar interrupciones de vertical Blank
	
	irqSet(IRQ_TIMER0, _gp_rsiTIMER0);
	irqEnable(IRQ_TIMER0);				// instalar la RSI para el TIMER1
	TIMER0_DATA = divFreq0; 
	TIMER0_CR = 0xC3;  	// Timer Start | IRQ Enabled | Prescaler 3 (F/1024)
	
	irqSet(IRQ_TIMER1, _gm_rsiTIMER1);
	irqEnable(IRQ_TIMER1);				// instalar la RSI para el TIMER1
	TIMER1_DATA = divFreq1; 
	TIMER1_CR = 0xC3;  	// Timer Start | IRQ Enabled | Prescaler 3 (F/1024)
	
	_gt_initKB();
	
	REG_IME = IME_ENABLE;			// activar las interrupciones en general
}


//------------------------------------------------------------------------------
int main(int argc, char **argv) {
//------------------------------------------------------------------------------
	intFunc start;
	char *progs[11];
	unsigned char zocalosDisponibles[3];
	int num_progs, ind_prog, zocalo;
	int i, j;

	inicializarSistema();
	
	_gg_escribir("********************************", 0, 0, 0);
	_gg_escribir("*                              *", 0, 0, 0);
	_gg_escribir("* Sistema Operativo GARLIC 2.0 *", 0, 0, 0);
	_gg_escribir("*                              *", 0, 0, 0);
	_gg_escribir("********************************", 0, 0, 0);
	_gg_escribir("*** Inicio fase 2 / ProgM\n", 0, 0, 0);

	num_progs = _gm_listaProgs(progs);

	// Imprimir llista de programes detectats
	_gg_escribir("*** Lista de programas disponibles:\n", 0, 0, 0);
	for (int i = 0; i < num_progs; ++i) {
		_gg_escribir("%d: %s\n", i + 1, (unsigned int)progs[i], 0);
	}

	if (num_progs == 0)
		_gg_escribir("ERROR: NO hay programas disponibles!\n", 0, 0, 0);
	else
	{
		while (1)
		{
			_gp_WaitForVBlank();
			gestionSincronismos();
			if ((_gd_pcbs[1].PID == 0) || (_gd_pcbs[2].PID == 0) || (_gd_pcbs[3].PID == 0))
			{
				_gg_escribir("*** seleccionar programa :\n", 0, 0, 0);
				ind_prog = escogerString(progs, num_progs);
				j = 0;
				for (i = 1; i <= 3; i++)	// detectar zócalos disponibles
				{
					if (_gd_pcbs[i].PID == 0)
					{
						zocalosDisponibles[j] = i;
						j++;
					}
				}
				_gg_escribir("\n*** seleccionar zocalo :\n", 0, 0, 0);
				zocalo = escogerNumero(zocalosDisponibles, j);

				start = _gm_cargarPrograma(zocalo, progs[ind_prog]);
				if (start)
				{
					_gp_crearProc(start, zocalo, progs[ind_prog], zocalo - 1);
					_gg_escribir("*** Programa cargado!\n\n\t", 0, 0, 0);
					_gg_escribir("%d: %s.elf\n\n", zocalo, (unsigned int)progs[ind_prog], 0);
				}
				else 
				{
					_gg_escribir("*** %s.elf: NO cargado!\n\n\t", 0, (unsigned int) progs[ind_prog], 0);				
				}
			}
		}
	}
	return 0;
}