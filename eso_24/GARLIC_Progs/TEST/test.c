/*------------------------------------------------------------------------------

	"TEST.c" : programa de prueba para el sistema operativo GARLIC 2.0;
	Author: Germán Puerto

	Testea las funcionalidades del programador de Teclado:
		- GARLIC_getXYbuttons: pide pulsar la X para empezar el minijuego.
		- GARLIC_getstring: debes poner la palabra escogida por argumento.
		- GARLIC_getnumber: para "puntuar" el minijuego.

	Args:
		arg: Número de la palabra a jugar.
		
------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */
//#define MAKE_DECIMAL(q12)	(float)((q12 - (q12<0?-0.5:0.5))/(1<<12)) 

int _start(int arg)				/* función de inicio : no se usa 'main' */
{
	char *words[] = { "arm", "nintendo", "elf", "teclado"};
	char v[32], v2[32];
	int len, i, cond, xybuttons;

    GARLIC_printf("-- Programa TEST - PID (%d) --\n", GARLIC_pid());

	GARLIC_printf("Pulsa la tecla X para continuar\n");
	
	cond = 0;
	while (!cond) // bucle infinito
	{
		xybuttons = GARLIC_getXYbuttons();
		if (xybuttons == 1) { cond = 1; }
	}
	
	for (int i = 0; words[arg][i] != '\0'; i++) v2[i] = words[arg][i];
	
	len = 0;
	for (int i = 0; v2[i] != '\0'; i++) len++;

    GARLIC_printf("Escribe la palabra: %s\n", v2);
    GARLIC_getstring(v, len);
	
	cond = 1;
	for (i = 0; i < len; i++) {
    // Compara pares de caracteres correspondientes
		if (v[i] != v2[i]) cond = 0;
	}
	
	if (cond) GARLIC_printf("HAS ESCRITO LA PALABRA CORRECTA: %s\n", v);
	else GARLIC_printf("HAS ESCRITO LA PALABRA MAL: %s\n", v);
	
	GARLIC_printf("Que nota le das al juego? (Sin rango)\n");
	len = GARLIC_getnumber('q');
	//len = (float)((len - (len<0?-0.5:0.5))/(1<<12));
	GARLIC_printf("Tu nota: %x\n", (len));

    GARLIC_printf("-- FI Programa TEST --\n");

    return 0;
}
