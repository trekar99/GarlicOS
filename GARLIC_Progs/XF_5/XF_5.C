#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */

#define  fr1 "FRASE DE EJEMPLO\0"
#define  cl1 "AODHAOFNOJFPAWUD"

#define  fr2 "FRASE DE EJEMPLO\0"
#define  cl2 "IGKDNBPQKFKQKSHR"

#define  fr3 "ESTOY DESEANDO COMER UN HELADO\0"
#define  cl3 "IAJSDINKLASNDIASJDIASJDLADLJQO"

#define  fr4 "CON DIEZ CANONES POR BANDA VIENTO EN POPA A TODA VELA\0"
#define  cl4 "AJSJKIJOJIOPJIUHYUFAYTGYUDDG6GIUDJOIHOPOCHUFJPOMANJFH"

/****************************************/
/****************************************/
/****        Vigenere Cypher         ****/
/****    Author: Albert Cañadilla    ****/
/****          Version: 1.0          ****/
/****************************************/
/****************************************/


int _start(int arg){
	const char *message, *key;
	char cryptogram[80];

	GARLIC_nice(arg);
	GARLIC_printf("-- Programa XF_5  -  PID (%d) --\n", GARLIC_pid());

	
	switch (arg){
		case 0:
			message = fr1;
			key = cl1;
			break;
		case 1:
			message = fr2;
			key = cl2;
			break;		
		case 2:
			message = fr3;
			key = cl3;
			break;
		case 3:
			message = fr4;
			key = cl4;
			break;
		default:
			message = fr1;
			key = cl1;	
	}
	
	int ascii_original, ascii_key, new_char, i;
    for (i = 0; message[i] != '\0'; i++){
        if (message[i] == ' '){
            cryptogram[i] = ' ';
            continue;
        }
        ascii_original = (int) message[i] - 65;
        ascii_key = (int) key[i] - 65;
        new_char = (ascii_original + ascii_key)%26 + 65;
        cryptogram[i] = new_char;
    }
	cryptogram[i] = '\0';

    GARLIC_printf("(%d) MESS:\t%s\n\n", GARLIC_pid(), message);

	GARLIC_printf("(%d) RES:\t%s\n\n", GARLIC_pid(), cryptogram);

	GARLIC_printf("-- Programa XF_5  -  PID (%d) --\n", GARLIC_pid());
	GARLIC_printf("--         FINALIZADO        --\n");
	return 0;
}