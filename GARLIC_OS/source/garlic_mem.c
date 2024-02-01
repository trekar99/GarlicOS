/*------------------------------------------------------------------------------

	"garlic_mem.c" : fase 1 / programador M

	Funciones de carga de un fichero ejecutable en formato ELF, para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>
#include <filesystem.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <garlic_system.h>	// definici�n de funciones y variables de sistema

#define INI_MEM 0x01002000		// direcci� inicial de mem�ria per programes
#define EI_NIDENT 16         	// M�xim de la taula de caracters del header
#define PT_LOAD 1            	// Tipus de segment 1 (PT_LOAD)
#define MAX_PROG 10				// N�mero m�xim de programes carregats
 
// Variable global que indica la primera posici� lliure dins de la zona de processos d'usuari
unsigned int primera_pos_lliure = INI_MEM;

// Tipus de dades ELF
typedef unsigned int Elf32_Addr;       // Direcci� de mem�ria
typedef unsigned short Elf32_Half;     // Mitj� enter (sense signe)
typedef unsigned int Elf32_Off;        // Despla�ament dins del fitxer (sense signe)
typedef unsigned int Elf32_Word;       // Enter (sense signe)
typedef signed int Elf32_Sword;        // Enter amb signe

// Estructura proporcionada pel header (arm-none-eabi-readelf -h HOLA.elf)
typedef struct {
    unsigned char e_ident[EI_NIDENT];
    Elf32_Half e_type;
    Elf32_Half e_machine;
    Elf32_Word e_version;
    Elf32_Addr e_entry;     	// Punt d'entrada del programa (adre�a de mem�ria de la primera instrucci� de la rutina _start())
    Elf32_Off e_phoff;      	// Despla�ament de la taula de segments (program header)
    Elf32_Off e_shoff;     		// Despla�ament de la taula de seccions (section header)
    Elf32_Word e_flags;
    Elf32_Half e_ehsize;
    Elf32_Half e_phentsize;     // Mida de cada entrada de la taula de segments
    Elf32_Half e_phnum;         // N�mero d'entrades de la taula de segments
    Elf32_Half e_shentsize;     // Mida de cada entrada de la taula de seccions
    Elf32_Half e_shnum;         // N�mero d'entrades de la taula de seccions
    Elf32_Half e_shstrndx;
} Elf32_Ehdr;

// Estructura proporcionada per la taula de segments (arm-none-eabi-readelf -l HOLA.elf)
typedef struct {
    Elf32_Word p_type;          // Tipus del segment; nom�s es carregaran segments de tipus 1 (PT_LOAD)
    Elf32_Off p_offset;         // Despla�ament al fitxer del primer byte del segment
    Elf32_Addr p_vaddr;
    Elf32_Addr p_paddr;         // Adre�a f�sica on s'hauria de carregar el segment
    Elf32_Word p_filesz;        // Mida del segment dins del fitxer
    Elf32_Word p_memsz;         // Mida del segment dins de la mem�ria
    Elf32_Word p_flags;
    Elf32_Word p_align;
} Elf32_Phdr;


// Declaraci� de l'estructura ProgramInfo
typedef struct ProgramInfo {
    char keyName[5];        // Nom del programa (4 car�cters) + 1 sentinella
    intFunc startAddress;   // Adre�a d'inici del programa (intFunc directe)
} ProgramInfo;

// Comptador de programes carregats
int numLoadedPrograms = 0;

// Declaraci� d'una matriu d'estructures ProgramInfo que representa la llista de programes carregats
ProgramInfo loadedPrograms[MAX_PROG];

/* _gm_initFS: inicializa el sistema de ficheros, devolviendo un valor booleano
					para indiciar si dicha inicializaci�n ha tenido �xito; */
int _gm_initFS()
{
	return nitroFSInit(NULL);	// inicializar sistema de ficheros NITRO
}


/* _gm_cargarPrograma: busca un fichero de nombre "(keyName).elf" dentro del
					directorio "/Programas/" del sistema de ficheros, y
					carga los segmentos de programa a partir de una posici�n de
					memoria libre, efectuando la reubicaci�n de las referencias
					a los s�mbolos del programa, seg�n el desplazamiento del
					c�digo en la memoria destino;
	Par�metros:
		keyName ->	vector de 4 caracteres con el nombre en clave del programa
	Resultado:
		!= 0	->	direcci�n de inicio del programa (intFunc)
		== 0	->	no se ha podido cargar el programa
*/
intFunc _gm_cargarPrograma(char *keyName)
{

    // Comprovem si ja tenim aquest programa carregat
    for (int i = 0; i < numLoadedPrograms; i++) {
        if (strcmp(loadedPrograms[i].keyName, keyName) == 0) {
            return loadedPrograms[i].startAddress;
        }
    }

    // Si no tenim el programa carregat, procedim a carregar-lo
	
    // Inicialitzaci� de les estructures
    Elf32_Addr dir_fisica_segment;
    Elf32_Half num_segments;
    Elf32_Off desp_segments, desp_fit_segment;
    Elf32_Word tipus_segment, mida_mem_segment;
    Elf32_Ehdr header;
    Elf32_Phdr taula_segments;
    
    int startAddress = 0; 	// Variable de retorn
    char nameFile[8]; 		// 4 car�cters + .elf (4)
    int mida;
    char* inputFile;
    
    // Llegir el fitxer executable .elf del disc ROM
    
    // Buscar el fitxer ("keyName.elf") al directori Programas
    
    // Utilitzem la funci� 'sprintf' per crear el nom del fitxer
    sprintf(nameFile, "/Programas/%s.elf", keyName);
    // Obrim el fitxer .elf en mode de lectura bin�ria. Si el fitxer no existeix, la funci� 'open()' retorna NULL.
    FILE *fit = fopen(nameFile, "rb");  
	
	// Si el fitxer est� buit o no existeix, no continuem
	if (fit == NULL) {
        perror("Error obrint el fitxer ELF");
		fclose(fit);  						// Tanquem el fitxer
        return (0);
    }
	
	// Si hem trobat el fitxer, el carreguem dins un b�fer de mem�ria din�mica (RAM) mitjan�ant 'malloc'
	
	// La funci� 'fseek' posiciona el punter del fitxer al SEEK_END - Final del fitxer
	fseek(fit, 0, SEEK_END);       // Aix� ens permet determinar la mida total del fitxer
	
	// Obtenim la mida del fitxer
	mida = ftell(fit);              // La funci� 'ftell' retorna la posici� actual del fitxer.
	
	// Posiciona el punter del fitxer al SEEK_SET - Inici del fitxer
	fseek(fit, 0, SEEK_SET);        // Aix� llegim el contingut complet, des de l'inici  
	
	inputFile = (char*) malloc(sizeof(char) * mida);  // La funci� 'malloc' reserva la mem�ria requerida i retorna un punter a aquesta.
	
	// Comprovem si la reserva de mem�ria s'ha realitzat amb �xit
	if (inputFile == NULL) {
		perror("Error de mem�ria al reservar l'espai de mem�ria per a inputFile");  	// Mostrem un missatge d'error en cas de manca de mem�ria
		fclose(fit);  						// Tanquem el fitxer
		return (0);  						// Retornem la direcci� de programa com a 0 (indicant que no s'ha pogut carregar el programa)
	}

	// Comprovem si la mida del b�fer de dades del fitxer coincideix amb la mida del fitxer
	if (fread(inputFile, 1, mida, fit) != mida)  // La funci� 'fread' llegeix dades del fitxer i les posa al vector apuntat per 'inputFile'.
	{
		perror("Error llegint el fitxer ELF. Les dimensions del fitxer podrien no coincidir amb les dimensions llegides");  // Mostrem un missatge d'error en cas de problemes de lectura del fitxer ELF
		free(inputFile);  						// Alliberem la mem�ria del b�fer del fitxer
		fclose(fit); 							// Tanquem el fitxer
		return (0);  							// Retornem la direcci� de programa com a 0 (indicant que no s'ha pogut carregar el programa)
	}

	// Obtenim els valors de la cap�alera --> despla�ament i mida de la taula de segments
	fseek(fit, 0, SEEK_SET);		// Ens assegurem que estiguem a l'inici del fitxer
	fread(&header, 1, sizeof(Elf32_Ehdr), fit); // Obtenim la refer�ncia de la posici� de mem�ria de la cap�alera
	
	desp_segments = header.e_phoff;    		// Despla�ament de la taula de segments (program header)
	num_segments = header.e_phnum;     		// Nombre d'entrades de la taula de segments
	
	// Bucle per processar la quantitat de segments a l'arxiu ELF
	for (int i = 0; i < num_segments; i++)
	{
		
		fseek(fit, desp_segments, SEEK_SET); 				// Posicionem el punter a l'arxiu a l'inici del segment actual
		
		fread(&taula_segments, 1, sizeof(Elf32_Phdr), fit); // Llegim l'entrada de la taula de segments actual
		
		// Obtenim el tipus del segment actual
		tipus_segment = taula_segments.p_type;   
		
		// Comprovem si el segment �s de tipus PT_LOAD (tipus = 1)
		if (tipus_segment == PT_LOAD)
		{
			
			// Obtenim informaci� sobre el segment
			desp_fit_segment = taula_segments.p_offset; 	// Despla�ament al fitxer del primer byte del segment
			dir_fisica_segment = taula_segments.p_paddr;	// Adre�a f�sica on s'hauria de carregar el segment
			mida_mem_segment = taula_segments.p_memsz;   	// Mida del segment dins de la mem�ria
			
			// Rutina per copiar un bloc de mem�ria des d'una adre�a font a una altra adre�a de destinaci�, el nombre de bytes indicat
			_gs_copiaMem((const void *) inputFile + desp_fit_segment, (void *) primera_pos_lliure, mida_mem_segment); // Carreguem el contingut del segment a la direcci� de mem�ria apropiada
			
			// Rutina per interpretar els 'relocs' d'un fitxer ELF i ajustar les adreces de mem�ria corresponents a les refer�ncies de tipus
 			_gm_reubicar(inputFile, dir_fisica_segment, (unsigned int *) primera_pos_lliure); // Reubiquem les posicions sensibles mitjan�ant la crida a la rutina '_gm_reubicar()'
			
			// Canviem la mida del segment perqu� sigui m�ltiple de 4
			if (mida_mem_segment % 4 != 0)
			{
				mida_mem_segment += 4 - mida_mem_segment % 4;
			}
			
			// Reubicaci� de l'adre�a d'inici del programa --> e_entry - p_paddr + primera_pos_lliure
			startAddress = header.e_entry - dir_fisica_segment + primera_pos_lliure; // Punt d'entrada del programa (adre�a de mem�ria de la primera instrucci� de la rutina '_start()')
			
			// Actualitzem la primera posici� lliure ja que aquesta est� ocupada per les dades del programa
			primera_pos_lliure += mida_mem_segment;
		}
		
		// Actualitzem la posici� del segment en cas que n'hi hagi un altre
		desp_segments += sizeof(Elf32_Phdr);
	}
	free(inputFile);   		// La funci� 'free' allibera la mem�ria pr�viament reservada per una crida a 'calloc', 'malloc' o 'realloc'.
    
    fclose(fit);            // La funci� 'fclose' tanca l'arxiu. S'assegura que tots els buffers estiguin buidats.
	
	if (numLoadedPrograms < MAX_PROG) {
        // Copiem la informaci� del programa carregat a l'array loadedPrograms
        strncpy(loadedPrograms[numLoadedPrograms].keyName, keyName, 4);
        loadedPrograms[numLoadedPrograms].keyName[4] = '\0';
        loadedPrograms[numLoadedPrograms].startAddress = (intFunc)startAddress;
        numLoadedPrograms++;
		
        return ((intFunc)startAddress);  // Retorna l'adre�a d'inici del programa
    } else {
        perror("S'ha assolit el nombre m�xim de programes carregats.\n");  // Si fes falta es podria ampliar la constant o crear una cua FIFO
        return (0);
    }
	
}
