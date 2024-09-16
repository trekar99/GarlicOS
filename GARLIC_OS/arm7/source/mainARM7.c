/*------------------------------------------------------------------------------

	Simon1  (Santiago Romaní, desembre 2015)
	
	-> based on "Common" templates from DevkitPro; see the following original
	   legal notice:
	
------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------
	
	default ARM7 core

		Copyright (C) 2005 - 2010
		Michael Noland (joat)
		Jason Rogers (dovoto)
		Dave Murphy (WinterMute)

	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any
	damages arising from the use of this software.

	Permission is granted to anyone to use this software for any
	purpose, including commercial applications, and to alter it and
	redistribute it freely, subject to the following restrictions:

	1.	The origin of this software must not be misrepresented; you
		must not claim that you wrote the original software. If you use
		this software in a product, an acknowledgment in the product
		documentation would be appreciated but is not required.

	2.	Altered source versions must be plainly marked as such, and
		must not be misrepresented as being the original software.

	3.	This notice may not be removed or altered from any source
		distribution.

------------------------------------------------------------------------------*/
#include <nds.h>

// Macro que indica si estamos pulsando dentro del rango de teclado.
#define IN_RANG(y)	(char)(((y>5?1:0) & (y<13?1:0)) & (y%2 == 0?1:0)) 

touchPosition tempPos = {0};
unsigned int _gt_tics = 0;

char _gt_CAPS_min[7][32] = {{' ', ' ', '\\', ' ', '1', ' ', '2', ' ', '3', ' ', '4', ' ', '5', ' ', '6', ' ', '7', ' ', '8', ' ', '9', ' ', '0', ' ', '\'', ' ', '{', ' ', '~', ' ', ' ', ' '},
						   {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
						   {' ', '@', ' ' , '<', ' ', 'q', ' ', 'w', ' ', 'e', ' ', 'r', ' ', 't', ' ', 'y', ' ', 'u', ' ', 'i', ' ', 'o' , ' ', 'p', ' ', '[', ' ', ' ', 'D', 'E', 'L', ' '},
						   {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
						   {' ', 'C', 'A' , 'P', 'S', ' ', 'a', ' ', 's', ' ', 'd', ' ',  'f', ' ','g', ' ', 'h', ' ', 'j', ' ', 'k', ' ' , 'l', ' ', '-', ' ', 'I', 'N', 'T', 'R', 'O', ' '},
						   {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
						   {' ', 'S', 'P' , 'A', 'C', 'E', ' ', 'z', ' ', 'x', ' ', 'c', ' ', 'v', ' ', 'b', ' ', 'n', ' ', 'm', ' ', ',' , ' ', '.', ' ', ' ', '<', '=', ' ', '=', '>', ' '}};

char _gt_CAPS_maj[7][32] = {{' ', ' ', '+', ' ', '!', ' ', '"', ' ', '#', ' ', '$', ' ', '%', ' ', '&', ' ', '/', ' ', '(', ' ', ')', ' ', '=', ' ', '?', ' ', '}', ' ', '|', ' ', ' ', ' '},
						   {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},						   
						   {' ', '*', ' ', '>', ' ', 'Q', ' ', 'W', ' ', 'E', ' ', 'R', ' ', 'T', ' ', 'Y', ' ', 'U', ' ', 'I', ' ', 'O', ' ', 'P', ' ', ']', ' ', ' ', 'D', 'E', 'L', ' '},
						   {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
						   {' ', 'C', 'A', 'P', 'S', ' ', 'A', ' ', 'S', ' ', 'D', ' ', 'F',' ' , 'G', ' ', 'H', ' ', 'J', ' ', 'K', ' ', 'L', ' ', '_', ' ', 'I', 'N', 'T', 'R', 'O', ' '},
			    		   {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
						   {' ', 'S', 'P', 'A', 'C', 'E', ' ', 'Z', ' ', 'X', ' ', 'C', ' ', 'V', ' ', 'B', ' ', 'N', ' ', 'M', ' ', ';', ' ', ':', ' ', ' ', '<', '=', ' ', '=', '>', ' '}};
 
/* comprobarPantallaTactil() verifica si se ha pulsado efectivamente la pantalla
   táctil con el lápiz, comprobando que está pulsada durante al menos dos llama-
   das consecutivas a la función y, además, las coordenadas raw sean diferentes
   de 0; en este caso, se fija el parámetro pasado por referencia, touchPos,
   con las coordenadas (x, y) en píxeles, y la función devuelve cierto. */
bool comprobarPantallaTactil(void)
{
	static bool penDown = false;
	bool lecturaCorrecta = false;

	if (!touchPenDown())
	{
		penDown = false;	// no hay contacto del lápiz con la pantalla
	}
	else		// hay contacto, pero hay que verificarlo
	{
		if (penDown)		// si anteriormente ya estaba en contacto
		{
			touchReadXY(&tempPos);	// leer la posición de contacto
			
			if ((tempPos.rawx == 0) || (tempPos.rawy == 0))
			{						// si alguna coordenada no es correcta
				penDown = false;	// anular indicador de contacto
			}
			else
			{
				lecturaCorrecta = true;
			}
		}
		else
		{					// si es la primera detección de contacto
			penDown = true;		// memorizar el estado para la segunda verificación
		}
	}
	return lecturaCorrecta;		
}


//------------------------------------------------------------------------------
int main() {
//------------------------------------------------------------------------------
  unsigned char mensaje;
  short x, y;
  char _gt_CAPS = 0;
  char xybuttons = 0, newxybuttons = 0;

  readUserSettings();			// configurar parámetros lectura de Touch Screen
  irqInit();
  irqEnable(IRQ_VBLANK | IRQ_IPC_SYNC | IRQ_TIMER0);	// activar interrupción VBlank para swiWaitForVBlank()
  REG_IPC_FIFO_CR = IPC_FIFO_ENABLE | IPC_FIFO_SEND_CLEAR;

  do
  {

    xybuttons = newxybuttons; 
	newxybuttons = ~REG_KEYXY & 0x3; 
	if (xybuttons != newxybuttons) 	REG_IPC_SYNC = IPC_SYNC_IRQ_REQUEST | newxybuttons << 8; 
	
	if (_gt_tics < 500) _gt_tics++; 

	else if (comprobarPantallaTactil())
	{		
		_gt_tics = 0;
		mensaje = 0;
		x = tempPos.px / 8;					// leer posición (x, y)
		y = tempPos.py / 8;					// Coordenadas en baldosas (dividimos entre 8)
		
		if (IN_RANG(y)) {
			y = y - 6;	// Correspondencia a _gt_CAPS_min/maj
			
			if ((y == 6) & (x > 28) & (x < 31)) mensaje = 1; // Caso RIGHT
			else if ((y == 6) & (x > 25) & (x < 28)) mensaje = 2; // Caso LEFT
			else if ((y == 2) & (x > 27) & (x < 31)) mensaje = 3; // Caso DEL
			else if ((y == 4) & (x > 25) & (x < 31)) mensaje = 4; // Caso INTRO
			else if ((y == 6) & (x > 0) & (x < 6)) mensaje = 5; // Caso SPACE
			else if ((y == 4) & (x > 0) & (x < 5)) {	// Caso CAPS
				mensaje = 6;
				_gt_CAPS = (_gt_CAPS ? 0 : 1);
			}
			else {
				mensaje = (_gt_CAPS ? _gt_CAPS_maj[y][x] : _gt_CAPS_min[y][x]); 
				if (mensaje == ' ') mensaje = 0;
			}
			
			if (mensaje != 0) REG_IPC_FIFO_TX = mensaje;
			
		}
		
	}
	swiWaitForVBlank();
  } while (1);
  return 0;
}

