/*------------------------------------------------------------------------------

	"fizz.c" : programa d'usuari

	Programa que escriurà en seqüència 100 números des de rand((arg+1)*50),
	substituint múltiples de 3 per FIZZ i múltiples de 5 per BUZZ

------------------------------------------------------------------------------*/
#include <GARLIC_API.h>		// inclusión del API para simular un proceso

int _start(int arg)	
{
	unsigned int quo, res1, res2;
	
	GARLIC_printf("-- Programa FIZZ  -  PID (%d) --\n", GARLIC_pid());
	
	int start = GARLIC_divmod(GARLIC_random(), ((arg+1)*50), &quo, &res1);
	start = res1;
	for(int i = 1; i < 101; i++)
	{
		GARLIC_divmod(start, 3, &quo, &res1);
		GARLIC_divmod(start, 5, &quo, &res2);
		if(res1 == 0 && res2 == 0)	GARLIC_printf("%3%d: FIZZ BUZZ\n", i);
		else if (res1 == 0)	GARLIC_printf("%1%d: FIZZ\n", i);
		else if(res2 == 0)	GARLIC_printf("%2%d: BUZZ\n", i);
		else GARLIC_printf("%0%d: %d\n", i, start);
		start++;
	}
	return 0;
}
