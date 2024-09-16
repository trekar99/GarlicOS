/*------------------------------------------------------------------------------

	"GARLIC_API.h" : cabeceras de funciones del API (Application Program
					Interface) del sistema operativo GARLIC 2.0 (c�digo fuente
					disponible en "GARLIC_API.s")

------------------------------------------------------------------------------*/
#ifndef _GARLIC_API_h_
#define _GARLIC_API_h_


	/* GARLIC_pid: devuelve el identificador del proceso actual */
extern int GARLIC_pid();


	/* GARLIC_random: devuelve un n�mero aleatorio de 32 bits */
extern int GARLIC_random();


	/* GARLIC_divmod: calcula la divisi�n num / den (numerador / denominador),
		almacenando el cociente y el resto en las posiciones de memoria indica-
		das por *quo y *mod, respectivamente (pasa resultados por referencia);
		la funci�n devuelve 0 si la divisi�n es correcta, o diferente de 0
		si hay alg�n problema (divisi�n por cero).
		ATENCI�N: s�lo procesa n�meros naturales de 32 bits SIN signo. */
extern int GARLIC_divmod(unsigned int num, unsigned int den,
							unsigned int * quo, unsigned int * mod);


	/* GARLIC_divmodL: calcula la divisi�n num / den (numerador / denominador),
		almacenando el cociente y el resto en las posiciones de memoria indica-
		das por *quo y *mod, respectivamente; los par�metros y los resultados
		se pasan por referencia; el numerador y el cociente son de tipo
		long long (64 bits), mientras que el denominador y el resto son de tipo
		unsigned int (32 bits sin signo).
		la funci�n devuelve 0 si la divisi�n es correcta, o diferente de 0
		si hay alg�n problema (divisi�n por cero). */
extern int GARLIC_divmodL(long long * num, unsigned int * den,
							long long * quo, unsigned int * mod);

	/* GARLIC_printf: escribe un string en la ventana del proceso actual,
		utilizando el string de formato 'format' que se pasa como primer
		par�metro, insertando los valores que se pasan en los siguientes
		par�metros (hasta 2) en la posici�n y forma (tipo) que se especifique
		con los marcadores incrustados en el string de formato:
			%c	: inserta un car�cter (seg�n c�digo ASCII)
			%d	: inserta un natural (32 bits) en formato decimal
			%x	: inserta un natural (32 bits) en formato hexadecimal
			%s	: inserta un string
			%%	: inserta un car�cter '%' literal
		Adem�s, tambi�n procesa los metacar�cteres '\t' (tabulador) y '\n'
		(salto de l�nia), junto con c�digos de formato para cambiar el color
		actual de los caracteres:
			%0	:	fija el color blanco
			%1	:	fija el color amarillo
			%2	:	fija el color verde
			%3	:	fija el color rojo
		El �ltimo color seleccionado ser� persistente en las siguientes llamadas
		a la funci�n. */
extern void GARLIC_printf(char * format, ...);
	
	/* GARLIC_nice: establece un nivel de 'amabilidad' para cada proceso que
		determina la proporci�n de quantums que se asignar� al proceso que invoque
		a la funci�n. Se pueden indicar cuatro niveles, del 0 al 3, donde el 0 indica
		m�s quantums para el proceso y el 3 menos quantums.*/
extern void GARLIC_nice(unsigned int n);

/* GARLIC_printchar: escribe un car�cter (c) en la posici�n (vx, vy) de la
		ventana del proceso actual, donde (vx) tiene rango [0..31] y (vy) tiene
		rango [0..23], con el color especificado por par�metro (0 -> blanco,
		1 -> amarillo, 2 -> verde, 3 -> rojo) */
extern void GARLIC_printchar(int vx, int vy, char c, int color);

	/* GARLIC_printmat: escribe una matriz de car�cteres (m) en la posici�n
		(vx, vy) de la ventana del proceso actual, donde (vx) tiene rango
		[0..31] y (vy) tiene rango [0..23], con el color especificado por
		par�metro (0 -> blanco,	1 -> amarillo, 2 -> verde, 3 -> rojo);
		 la matriz consistir� en 8x8 posiciones	con c�digos ASCII, aunque las
		posiciones que contengan un c�digo inferior a 32 (espacio en blanco) no
		modificar�n las casillas correspondientes de la ventana. */
extern void GARLIC_printmat(int vx, int vy, char m[][8], int color);


	/* GARLIC_delay: retarda la ejecuci�n del proceso actual el n�mero de
		segundos que se especifica por el par�metro (nsec); el rango permitido
		ser� de [0..600] (max. 10 minutos); el valor 0 provocar� que el proceso
		se desbanque y pase a READY, lo cual corresponde a un tiempo de retardo
		muy peque�o, aunque no se puede determinar exactamente cu�l (el que
		resulte de volver a restaurar el proceso). */
extern void GARLIC_delay(unsigned int nsec);


	/* GARLIC_clear: borra todo el contenido de la ventana del proceso que
		invoca esta funci�n. La siguiente llamada a la funci�n GARLIC_print
		empezar� a escribir a partir de la primera fila de la ventana. */
extern void GARLIC_clear();

/* GARLIC_getstring: esta funci�n recibe por par�metro la direcci�n de 
		un vector de caracteres donde guardar el string introducido por 
		teclado, as� como el n�mero m�ximo de caracteres que puede contener el 
		vector (excluido el centinela), y devuelve como resultado el n�mero de 
		caracteres le�dos finalmente (excluido el centinela). */
extern int GARLIC_getstring(char * string, int max_char);

	/* GARLIC_getnumber: esta funci�n recibe por par�metro el type 'x' o 'd', 
		seg�n se desee interpretar el n�mero introducido por el usuario como 
		valor hexadecimal o decimal, respectivamente, o en caso de escoger 'd', 
		se admitir� un signo menos delante del n�mero, o el usuario solo podr� 
		teclear d�gitos del subconjunto correspondiente, �s decir, o bien d�gitos 
		hexa o bien d�gitos decimales m�s el s�mbolo de menos '-', y no se permitir� 
		al usuario rebasar el rango de los n�meros de 32 bits, la funci�n interpretar� 
		el valor del n�mero y lo devolver� como resultado; si el usuario no introduce 
		ning�n d�gito, se devolver� un cero. */
extern int GARLIC_getnumber(char type);

	/* GARLIC_getXYbuttons: permite a los programas realizar una consulta no 
		bloqueante del estado de los botones 'X' e 'Y' de la NDS, es decir, el 
		proceso que invoque dicha funci�n continuar� su ejecuci�n inmediatamente, 
		obteniendo un patr�n de bits que indicar� el estado de los dos botones:
		
		� Bit 0: =1 indica que el bot�n 'X' est� pulsado, =0 indica que est� soltado,
		� Bit 1: =1 indica que el bot�n 'Y' est� pulsado, =0 indica que est� soltado. */
extern char GARLIC_getXYbuttons(); 

#endif // _GARLIC_API_h_
