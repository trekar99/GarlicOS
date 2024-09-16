/*------------------------------------------------------------------------------

	"garlic_graf.c" : fase 1 / programador G

	Funciones de gesti�n de las ventanas de texto (gr�ficas), para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>

#include <garlic_system.h>	// definici�n de funciones y variables de sistema
#include <garlic_font.h>	// definici�n gr�fica de caracteres


/* definiciones para realizar c�lculos relativos a la posici�n de los caracteres
	dentro de las ventanas gr�ficas, que pueden ser 4 o 16 */
#define NVENT	4				// n�mero de ventanas totales
#define PPART	2				// n�mero de ventanas horizontales o verticales
								// (particiones de pantalla)
#define VCOLS	32				// columnas y filas de cualquier ventana
#define VFILS	24
#define PCOLS	VCOLS * PPART	// n�mero de columnas totales (en pantalla)
#define PFILS	VFILS * PPART	// n�mero de filas totales (en pantalla)

u16 * bg3Ptr;
u16 * bg2Ptr;
int bg2, bg3;

/* _gg_generarMarco: dibuja el marco de la ventana que se indica por par�metro*/
void _gg_generarMarco(int v)
{	
	int vDivPart = v / PPART;
	int vModPart = v % PPART;
	
	for(int i = 1; i < VCOLS - 1; i++)
	{
		bg3Ptr[vDivPart * VFILS * PCOLS + vModPart * VCOLS + i] = 99;		//limit superior
		bg3Ptr[(vDivPart * (VFILS - 1) + (VFILS - 1)) * PCOLS + vModPart * VCOLS + i] = 97;	//limit inferior
	}
	for(int j = 1; j < VFILS - 1; j++)
	{
		bg3Ptr[(vDivPart * (VFILS - 1) + j) * PCOLS + vModPart * VCOLS] = 96;	//limit esquerra
		bg3Ptr[(vDivPart * (VFILS - 1) + j) * PCOLS + (vModPart + 1) * VCOLS - 1] = 98;	//limit dret
	}
	
	bg3Ptr[vDivPart * VFILS * PCOLS + vModPart * VCOLS] = 103;	//cantonada superior esquerra
	bg3Ptr[vDivPart * VFILS * PCOLS + (vModPart + 1) * VCOLS - 1] = 102;	//cantonada superior dreta
	bg3Ptr[(vDivPart * (VFILS - 1) + VFILS - 1) * PCOLS + vModPart * VCOLS] = 100;	//cantonada inferior esquerra
	bg3Ptr[(vDivPart * (VFILS - 1) + VFILS - 1) * PCOLS + (vModPart + 1) * VCOLS - 1] = 101;	//cantonada inferior dreta
}


/* _gg_iniGraf: inicializa el procesador gr�fico A para GARLIC 1.0 */
void _gg_iniGrafA()
{
	int scale = 1 << 9;
	//int scale = 1 << 10;	//scale per la fase 2
	
	//inicializar el procesador gr�fico principal (A) en modo 5,
	//con salida en la pantalla superior de la NDS
	videoSetMode(MODE_5_2D);

	//reservar el banco de memoria de v�deo A
	vramSetBankA(VRAM_A_MAIN_BG_0x06000000);

	//inicializar los fondos gr�ficos 2 y 3 en modo Extended Rotation,
	//con un tama�o total de 512x512 p�xeles (fase1) o 1024*1024 (fase 2)
	bg2 = bgInit(2, BgType_ExRotation, BgSize_ER_512x512, 0, 1);
	bg3 = bgInit(3, BgType_ExRotation, BgSize_ER_512x512, 4, 1);
	//bg2 = bgInit(2, BgType_ExRotation, BgSize_ER_1024x1024, 0, 0);
	//bg3 = bgInit(3, BgType_ExRotation, BgSize_ER_1024x1024, 8, 4);

	//fijar el fondo 3 como m�s prioritario que el fondo 2
	bgSetPriority(bg2, 1); // Prioridad del fondo 2 a nivel 0
	bgSetPriority(bg3, 0); // Prioridad del fondo 3 a nivel 1

	//descomprimir el contenido de la fuente de letras sobre
	//una zona adecuada de la memoria de v�deo
	decompress(garlic_fontTiles, bgGetGfxPtr(bg3), LZ77Vram); // Descomprimim en format LZ77

	//copiar la paleta de colores de la fuente de letras
	//sobre la zona de memoria correspondiente
	dmaCopy(garlic_fontPal, BG_PALETTE, sizeof(garlic_fontPal));

	//generar los marcos de las ventanas de texto en el fondo 3
	bg3Ptr = bgGetMapPtr(bg3);
	bg2Ptr = bgGetMapPtr(bg2);
	
	for(int x = 0; x < NVENT; x++)
	{
		_gg_generarMarco(x);
	}

	//escalar los fondos 2 y 3 para que se ajusten exactamente a las
	//dimensiones de una pantalla de la NDS (reducci�n al 50%)
	bgSetScale(bg2, scale, scale);
	bgSetScale(bg3, scale, scale);
	
	//update dels fondos
	bgUpdate();
}


void long2str(char *valor, int longitud, long long valor_2long){
	
	long long quo;
	unsigned int mod;
	unsigned int divisor = 10;
	
	
	longitud--;	//index de l'ultima posicio del vector
	while(longitud >= 0)
	{	
		_ga_divmodL(&valor_2long, &divisor, &quo,  &mod);
		valor_2long = quo;
		valor[longitud] = mod + 48; //Convertim a ASCII
		longitud--;
	}
	valor[longitud] = '\0';
}



/* _gg_procesarFormato: copia los caracteres del string de formato sobre el
					  string resultante, pero identifica los c�digos de formato
					  precedidos por '%' e inserta la representaci�n ASCII de
					  los valores indicados por par�metro.
	Par�metros:
		formato	->	string con c�digos de formato (ver descripci�n _gg_escribir);
		val1, val2	->	valores a transcribir, sean n�mero de c�digo ASCII (%c),
					un n�mero natural (%d, %x) o un puntero a string (%s);
		resultado	->	mensaje resultante.
	Observaci�n:
		Se supone que el string resultante tiene reservado espacio de memoria
		suficiente para albergar todo el mensaje, incluyendo los caracteres
		literales del formato y la transcripci�n a c�digo ASCII de los valores.
*/
void _gg_procesarFormato(char *formato, unsigned int val1, unsigned int val2, char *resultado)
{
	int i = 0;
	int res_i = 0;
	bool valActual = false;
	while(formato[i] != '\0')
	{
		if(formato[i] == '%')	//identifiquem un format
		{
			if(formato[i+1] == 'c')	//si es tracta d'un char
			{
				//decidim quin val fem servir
				if(!valActual) resultado[res_i] = val1;
				else resultado[res_i] = val2;
				res_i++;
			}
			else if(formato[i+1] == 'd')	//si es tracta d'un natural(en dec)
			{
				char num[12];
				int index = 0;
				int error;
				
				//decidim quin val fem servir
				if(!valActual) error = _gs_num2str_dec(num, sizeof(num), val1);
				else error = _gs_num2str_dec(num, sizeof(num), val2);
				
				if(error == 0)	//en cas de que la funcio s'hagi pogut executar be...
				{
					while(num[index] == ' ') index++;	//trobem el comen�ament del numero
					while(num[index] != '\0')
					{
						resultado[res_i] = num[index];	//guardem el numero dec a l'string final
						res_i++;
						index++;
					}
				}
			}
			else if(formato[i+1] == 'x')	//si es tracta d'un natural(en hex)
			{
				char num[9];	//8 posicions + sentinella
				int index = 0;
				int error;
				
				//decidim quin val fem servir
				if(!valActual) error = _gs_num2str_hex(num, sizeof(num), val1);
				else error = _gs_num2str_hex(num, sizeof(num), val2);
				
				if(error == 0)	//en cas de que la funcio s'hagi pogut executar be...
				{
					if((!valActual && val1 == 0) || (valActual && val2 == 0)) {	//si ens passen el n�mero 0
						resultado[res_i] = '0';	//guardem el numero hex a l'string final
						res_i++;
					}
					else {
						while(num[index] == '0') index++;	//trobem el comen�ament del numero
						while(num[index] != '\0')
						{
							resultado[res_i] = num[index];	//guardem el numero hex a l'string final
							res_i++;
							index++;
						}
					}
				}
			}
			else if(formato[i+1] == 's')	//si es tracta d'un ptr a string
			{
				char *temp;
				int temp_i = 0;
				
				//decidim quin valor fem servir
				if(!valActual) temp = (char *)val1;
				else  temp = (char *)val2;
				
				while(temp[temp_i] != '\0')
				{
					resultado[res_i] = temp[temp_i];	//recorrem l'string i anem guardant-ho tot a la nostra string
					res_i++;
					temp_i++;
				}
			}
			else
			{
				resultado[res_i] = '%';
				res_i++;
			}
			valActual = true;	//si hem trobat algun format, indiquem que ja hem fet servir el 1r valor
			i++;
		}
		else	//si no s'identifica cap format, es copia el caracter directament al vector
		{
			resultado[res_i] = formato[i];
			res_i++;
		}
		i++;
	}
	resultado[res_i] = '\0';	//posem un centinella al array
}


/* _gg_escribir: escribe una cadena de caracteres en la ventana indicada;
	Par�metros:
		formato	->	cadena de formato, terminada con centinela '\0';
					admite '\n' (salto de l�nea), '\t' (tabulador, 4 espacios)
					y c�digos entre 32 y 159 (los 32 �ltimos son caracteres
					gr�ficos), adem�s de c�digos de formato %c, %d, %x y %s
					(max. 2 c�digos por cadena)
		val1	->	valor a sustituir en primer c�digo de formato, si existe
		val2	->	valor a sustituir en segundo c�digo de formato, si existe
					- los valores pueden ser un c�digo ASCII (%c), un valor
					  natural de 32 bits (%d, %x) o un puntero a string (%s)
		ventana	->	n�mero de ventana (de 0 a 3)
*/
void _gg_escribir(char *formato, unsigned int val1, unsigned int val2, int ventana)
{
	char text[97];	//char array de 3 linies de llarg (32 Bytes * 3) + centinella
	int i = 0;
	int fila, cPendents, numChars;
	bool final = false;
	
	//Convertir el string de formato y los valores pasados por par�metro en un
	//mensaje de texto definitivo, sustituyendo los c�digos de formato %c, %d,
	//%x, %s y %% en los caracteres ASCII correspondientes a los valores
	//tratados seg�n el tipo de formato especificado
	_gg_procesarFormato(formato, val1, val2, text);
	
	//Leer el campo pControl de la entrada _gd_wbfs[ventana], y obtener
	//la fila actual y el n�mero de caracteres almacenados en el campo
	//pChars[] (vector de 32 caracteres)
	fila = _gd_wbfs[ventana].pControl >> 16;	//obtenim la fila actual a la que escriurem
	numChars = _gd_wbfs[ventana].pControl & 0x0000ffff;	//obtenim el numero de caracters pendents a la fila
	cPendents = numChars;	//obtenim el numero d'elements al vector
	
	
	//Analizar los caracteres del mensaje de texto definitivo, uno a uno, y
	//a�adir los c�digos ASCII que correspondan al final del buffer de l�nea
	//de la ventana, o sea, en el campo pChars[]
	while(text[i] != '\0')
	{
		final = false;
		//Si se trata de un tabulador ('\t'), a�adir espacios en blanco hasta la
		//pr�xima columna (posici�n del buffer) con �ndice m�ltiplo de 4
		if(text[i] == '\t')
		{
			if(numChars % 4 == 0)
			{
				_gd_wbfs[ventana].pChars[numChars] = ' ';
				numChars++;
				cPendents--;
			}
			while(numChars % 4 != 0)
			{
				_gd_wbfs[ventana].pChars[numChars] = ' ';
				numChars++;
				cPendents--;
			}
		}
		
		//Si se trata de un car�cter literal, a�adir su c�digo ASCII tal cual
		if(text[i] >= 32 && text[i] <= 159)
		{
			_gd_wbfs[ventana].pChars[numChars] = text[i];
			numChars++;
			cPendents--;
		}
		
		//Si se trata de un salto de l�nea ('\n') o se ha llenado el buffer de l�nea
		//de la ventana, esperar el siguiente per�odo de retroceso vertical,
		//invocando la rutina swiWaitForVBlank(), para asegurar que el
		//controlador de gr�ficos no est� accediendo a la memoria de v�deo, y
		//transferir los caracteres del buffer sobre las posiciones de memoria de
		//v�deo correspondientes a la l�nea actual de escritura en ventana,
		//utilizando la rutina _gg_escribirLinea() (ver m�s adelante)
		if(text[i] == '\n' || numChars >= VCOLS)
		{
			//Incrementar la l�nea actual de escritura; en el caso que el n�mero de
			//l�nea anterior fuera 23 (�ltima fila), ser� necesario realizar un
			//desplazamiento hacia arriba (scroll) con la rutina _gg_desplazar()
			//(ver m�s adelante) antes de transferir el contenido del buffer (punto
			//anterior), para dejar sitio a la nueva l�nea
			if(fila >= VFILS)
			{
				swiWaitForVBlank();
				_gg_desplazar(ventana);
				fila = VFILS - 1;
			}
			
			if(numChars != 0) 	//Si nom�s tenim un \n sense res m�s, saltem de linia
			{
				swiWaitForVBlank();
				_gg_escribirLinea(ventana, fila, numChars);
				cPendents += numChars;
				numChars = 0;
			}
			final = true;	//indiquem que hem arribat al final de la linia
			fila++;	//incrementem la fila actual en 1
		}
		else if(text[i+1] == '\0')
		{
			if(fila >= VFILS)
			{
				swiWaitForVBlank();
				_gg_desplazar(ventana);
				fila = VFILS - 1;
			}
			
			swiWaitForVBlank();
			_gg_escribirLinea(ventana, fila, numChars);
			fila++;	//incrementem la fila actual en 1
		}
		
		//Seguir con este proceso hasta el final del mensaje de texto definitivo,
		//actualizando el campo pControl seg�n el estado final de la
		//transferencia (�ltima posici�n de inserci�n)
		if(final)
		{
			_gd_wbfs[ventana].pControl &= 0x0000ffff;	//eliminem l�nia a la que estem actualment
			_gd_wbfs[ventana].pControl |= (fila << 16);	//afegim quina l�nia ser� la seg�ent
			_gd_wbfs[ventana].pControl &= 0xffff0000;	//com que canviem de l�nia, tenim 0 car�cters escrits en aquesta nova l�nia
		}
		else
		{
			_gd_wbfs[ventana].pControl &= 0xffff0000;	//eliminem l�nia a la que estem actualment
			_gd_wbfs[ventana].pControl |= numChars;	//indiquem quants caracters tenim posats
		}
		i++;
	}
}
