/*------------------------------------------------------------------------------

	"ERAT.c" : programa de prueba para el sistema operativo GARLIC 1.0;

	Criba d'Eratòstenes de longitud aleatòria [1..(arg+1)*25]
	Devuelve una lista con todos los números primos menores que n.

	Args:
		n: El número natural máximo.

	Returns:
		Una lista con todos los números primos menores que n.

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */

int _start(int arg)				/* función de inicio : no se usa 'main' */
{
	int n, lenght, i, j;

    GARLIC_printf("-- Programa ERAT - PID (%d) --\n", GARLIC_pid());
    GARLIC_printf("Introduce un número para realizar la criba\n");
    n = GARLIC_getnumber('d');

    // Límite número 0-6 
    // Máximo array primos 100: 100/25 = 4.
    if (n < 0) n = 0;
    else if (n > 3) n = 3;
    lenght = (n + 1) * 20;

    // Declaramos un array para almacenar los números primos.
    char primos[lenght + 1];

    // Inicializamos el array.
    for (i = 0; i <= lenght; i++) {
        primos[i] = 1;
    }

    // Iteramos sobre todos los números primos, comenzando por el 2.
    for (i = 2; i <= lenght; i++) {
        // Si i es primo, marcamos todos sus múltiplos como no primos.
        if (primos[i]) {
            for (j = i * i; j <= lenght; j += i) {
                primos[j] = 0;
            }
        }
    }

    // Imprimimos la lista de números primos.
    GARLIC_printf("Los números primos menores que %d son:\n", lenght);
    for (i = 2; i <= lenght; i++) {
        if (primos[i]) GARLIC_printf("El numero %d es primo\n", i);
    }

    GARLIC_printf("-- FI Programa ERAT --\n");

    return 0;
}