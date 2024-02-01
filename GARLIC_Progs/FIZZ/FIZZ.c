/*------------------------------------------------------------------------------

	"fizz.c" : programa d'usuari

	Programa que escriurà en seqüència 100 números des de rand((arg+1)*50),
	substituint múltiples de 3 per FIZZ i múltiples de 5 per BUZZ

------------------------------------------------------------------------------*/
#include <GARLIC_API.h>		// inclusión del API para simular un proceso

int _start(int arg)
{

	unsigned int quo, res, start1, start2;
	int start;
	GARLIC_nice(arg);
	
	GARLIC_printf("-- Programa FIZZ  -  PID (%d) --\n", GARLIC_pid());
	
	start = GARLIC_divmod(GARLIC_random(), ((arg+1)*50), &quo, &res);
	start = res;
	for(int i = 1; i < 101; i++)
	{
		start1 = GARLIC_divmod(start, 3, &quo, &res);
		start1 = res;
		start2 = GARLIC_divmod(start, 5, &quo, &res);
		start2 = res;
		if(start1 == 0)	GARLIC_printf("%d: FIZZ\n", i);
		else if(start2 == 0)	GARLIC_printf("%d: BUZZ\n", i);
		else GARLIC_printf("%d: %d\n", i, start);
		start1 = 3;
		start2 = 5;
		start++;
	}
	
	return 0;
} 
