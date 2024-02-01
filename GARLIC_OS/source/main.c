/*------------------------------------------------------------------
"main.c" : fase 1 / programador P
------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <garlic_system.h>
extern int * punixTime;		// puntero a zona de memoria con el tiempo real
#define NVENT	4				// número de ventanas totales

//------------------------------------------------------------------
void inicializarSistema() {
//------------------------------------------------------------------
	// sub display, VRAM_C, and BG0 and enables MODE_0_2D on the sub display. 
	int v;
	_gg_iniGrafA();			// inicializar procesador gráfico A
	for (v = 0; v < NVENT; v++)	// para todas las ventanas
		_gd_wbfs[v].pControl = 0;		// inicializar los buffers de ventana
	
	_gd_seed = *punixTime;	// inicializar semilla para números aleatorios con
	_gd_seed <<= 16;		// el valor de tiempo real UNIX, desplazado 16 bits

	if (!_gm_initFS())
	{
		_gg_escribir("ERROR: ¡no se puede inicializar el sistema de ficheros!", 0, 0, 0);
		exit(0);
	}
	irqInitHandler(_gp_IntrMain); // instalar rutina principal
	irqSet(IRQ_VBLANK, _gp_rsiVBL); // instalar RSI de VBlank
	irqEnable(IRQ_VBLANK); // activar inter. VBlank
	REG_IME = IME_ENABLE; // activar inter. en general
	_gd_pcbs[0].keyName = 0x4C524147; // "GARL"*/
	
	
	// Inicializamos teclado
	_gt_initKB();
}
/* Proceso de prueba */

//--------------------------------------------------------------
int main(int argc, char **argv) {
//--------------------------------------------------------------
	intFunc start;
    inicializarSistema();
	
	start = _gm_cargarPrograma("SHA2");
	if (start) _gp_crearProc(start, 10, "SHA2", 1);
	else _gg_escribir("*** Programa 4 \"SHA2\" NO cargado\n", 0, 0, 2);
	
	start = _gm_cargarPrograma("ERAT");
	if (start) _gp_crearProc(start, 11, "ERAT", 0);		
	else _gg_escribir("*** Programa 2 \"ERAT\" NO cargado\n", 0, 0, 3);

	
	start = _gm_cargarPrograma("FIZZ");
	if (start) _gp_crearProc(start, 12, "FIZZ", 2);		
	else _gg_escribir("*** Programa 3 \"FIZZ\" NO cargado\n", 0, 0, 0);
	
	start = _gm_cargarPrograma("XF_5");
	if (start) _gp_crearProc(start, 9, "XF_5", 1);		// llamada al proceso HOLA con argumento 1
	else _gg_escribir("*** Programa 1 \"XF_5\" NO cargado\n", 0, 0, 1);

	while (1)
	{
		_gp_WaitForVBlank();
	}
	return 0;
}