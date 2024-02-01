/*------------------------------------------------------------------------------

	"garlic_mem.c" : fase 2 / programador M

	Funciones de carga de un fichero ejecutable en formato ELF, para GARLIC 2.0

------------------------------------------------------------------------------*/
#include <nds.h>
#include <filesystem.h>
#include <dirent.h>			// para struct dirent, etc.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <garlic_system.h>	// definici�n de funciones y variables de sistema

#define EI_NIDENT 16         	// M�xim de la taula de caracters del header
#define PT_LOAD 1            	// Tipus de segment 1 (PT_LOAD)
#define MAX_PROG 11				// N�mero m�xim de programes carregats
#define MAX_NAME_PROG 4			// N�mero total de caracters que te un nom de programa
#define MAX_NAME_DIR 12			// Caracters m�xims que pot tenir el directori
#define MAX_NAME_FILE_PROG 8	// N�mero total de caracters que te un fitxer de de programa
#define MAX_NAME_DIR_FILE 20	// Maxim de caracters que pot tenir el conjunt de directori + fitxer 
#define CODE_SEGMENT 5			// Segment de codi
#define DATA_SEGMENT 6 			// Segment de dades
#define SUCCESS 1				// Constant per definir correcte 
#define FAILURE 0				// Constant per definir error

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
    Elf32_Word p_flags;			// 5 (R-E) para el segmento de c�digo y 6 (RW-) para el segmento de datos
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

// Array bidimensional, noms complets dels programes (un per fila)
char nameProg[MAX_PROG][MAX_NAME_FILE_PROG];

/* _gm_initFS: inicializa el sistema de ficheros, devolviendo un valor booleano
					para indiciar si dicha inicializaci�n ha tenido �xito; */
int _gm_initFS()
{
	return nitroFSInit(NULL);	// inicializar sistema de ficheros NITRO
}


/* _gm_listaProgs: devuelve una lista con los nombres en clave de todos
			los programas que se encuentran en el directorio "Programas".
			 Se considera que un fichero es un programa si su nombre tiene
			8 caracteres y termina con ".elf"; se devuelven s?lo los
			4 primeros caracteres de los programas (nombre en clave).
			El resultado es un vector de strings (paso por referencia) y
			el numero de programas detectados 
*/
int _gm_listaProgs(char* progs[])
{
    DIR *dir;  					// Punter al tipus DIR (directori obert)
    char nameDir[MAX_NAME_DIR]; // Ruta del directori on hi ha els programes
    int numProg = 0; 			// Variable amb el nombre de programes que hi ha a la llista
    struct dirent *ent; 		// Punter a struct dirent (<dirent.h>)
    
    // Obrim el directori on hi ha els Programes
    sprintf(nameDir, "/Programas/");
    dir = opendir(nameDir);
    
    if (dir != NULL)
    {
        // Recorrem el directori per llegir les entrades
        while ((ent = readdir(dir)) != NULL) 
        {           
        // Comprovem que tingui 8 caracters, del quals els ultims siguin ".elf"
            if (strlen(ent->d_name) == MAX_NAME_FILE_PROG) {
                // Guradem el nom complet a la matriu constant nameProg  
                sprintf(nameProg[numProg], "%s", ent->d_name);

                // Verifiquem que el nom tingui 8 caracters
                if (strlen(nameProg[numProg]) == MAX_NAME_FILE_PROG) {
                    // Guardem els 4 primers car�cters del NOM_PROG a la llista de programes 
					// char *strndup(const char *s, size_t n); -> duplicate a string (https://en.cppreference.com/w/c/string/byte/strndup)
                    progs[numProg] = strndup(nameProg[numProg], MAX_NAME_PROG);
					numProg++;
                }
            } 
        }
        closedir(dir);
    } else {
        perror("No sha pogut obrir el directori"); 
    }
    return numProg;
}



/* _gm_cargarPrograma: busca un fichero de nombre "(keyName).elf" dentro del
				directorio "/Programas/" del sistema de ficheros, y carga los
				segmentos de programa a partir de una posici?n de memoria libre,
				efectuando la reubicaci?n de las referencias a los s?mbolos del
				programa, seg?n el desplazamiento del c?digo y los datos en la
				memoria destino;
	Parametros:
		zocalo	->	Indice del zocalo que indexaras el proceso del programa
		keyName ->	vector de 4 caracteres con el nombre en clave del programa
	Resultado:
		!= 0	->	direccion de inicio del programa (intFunc)
		== 0	->	no se ha podido cargar el programa
*/
intFunc _gm_cargarPrograma(int zocalo, char *keyName)
{

    // Inicialitzaci� de les estructures
    Elf32_Addr pAddr_code = 0, pAddr_data = 0;
    Elf32_Half num_segments;
    Elf32_Off desp_segments, desp_fit_segment;
    Elf32_Word tipus_segment, mida_file_segment, mida_mem_segment, dest_code = 0, dest_data = 0, flag;
    Elf32_Ehdr header;
    Elf32_Phdr taula_segments;
    
    int startAddress = 0; 					// Variable de retorn
    char nameFile[MAX_NAME_DIR_FILE]; 		// Char per guardar el nom del fitxer "/Programas/_ _ _ _.elf"
    int mida;								// Variable per guardar la mida del fitxer
    char* inputFile;						// Variable per reservar memoria
	char error = SUCCESS;			
	
	// Comprovem si ja tenim aquest programa carregat
	for (int i = 0; i < numLoadedPrograms; i++) {
    // Utilitzem strcmp() per comparar els noms de les claus
		if (strcmp(loadedPrograms[i].keyName, keyName) == 0) {
			// Si s�n iguals, retornem l'adre�a d'inici del programa carregat
			startAddress = (int)loadedPrograms[i].startAddress;
		}
	}
    
	// Si no el tenim carregat -> Procedim a la carrega
	if (startAddress == FAILURE) {
		
		// Utilitzem la funci� 'sprintf' per crear el nom del fitxer
		sprintf(nameFile, "/Programas/%s.elf", keyName);
		
		// Obrim el fitxer .elf en mode de lectura bin�ria. Si el fitxer no existeix, la funci� 'open()' retorna NULL.
		FILE *fit = fopen(nameFile, "rb");  
		
		// Si el fitxer est� buit o no existeix, no continuem
		if (fit != NULL) {
			
			// La funci� 'fseek' posiciona el punter del fitxer al SEEK_END - Final del fitxer
			fseek(fit, 0, SEEK_END);       // Aix� ens permet determinar la mida total del fitxer
			
			// Obtenim la mida del fitxer
			mida = ftell(fit);              // La funci� 'ftell' retorna la posici� actual del fitxer.
			
			// Posiciona el punter del fitxer al SEEK_SET - Inici del fitxer
			fseek(fit, 0, SEEK_SET);        // Aix� llegim el contingut complet, des de l'inici  
			
			inputFile = (char*) malloc(sizeof(char) * mida);  // La funci� 'malloc' reserva la mem�ria requerida i retorna un punter a aquesta.
			
			// Si hi ha hagut algun problema a la reserva de mem�ria, no continuem 
			if (inputFile != NULL) {
				
				// Comprovem si la mida del b�fer de dades del fitxer coincideix amb la mida del fitxer
				if (fread(inputFile, 1, mida, fit) == mida)  // La funci� 'fread' llegeix dades del fitxer i les posa al vector apuntat per 'inputFile'.
				{
					// Obtenim els valors de la cap�alera --> despla�ament i mida de la taula de segments
					fseek(fit, 0, SEEK_SET);		// Ens assegurem que estiguem a l'inici del fitxer
					fread(&header, 1, sizeof(Elf32_Ehdr), fit); // Obtenim la refer�ncia de la posici� de mem�ria de la cap�alera
					
					desp_segments = header.e_phoff;    		// Despla�ament de la taula de segments (program header)
					num_segments = header.e_phnum;     		// Nombre d'entrades de la taula de segments
					
					// Bucle per processar la quantitat de segments a l'arxiu ELF
					for (int i = 0; i < num_segments && error; i++)
					{
						
						fseek(fit, desp_segments, SEEK_SET); 	// Posicionem el punter a l'arxiu a l'inici del segment actual
						fread(&taula_segments, 1, sizeof(Elf32_Phdr), fit); // Llegim l'entrada de la taula de segments actual
						
						tipus_segment = taula_segments.p_type;   // Obtenim el tipus del segment actual
						
						// Comprovem si el segment �s de tipus PT_LOAD (tipus = 1)
						if (tipus_segment == PT_LOAD)
						{
							
							// Obtenim informaci� sobre el segment
							desp_fit_segment = taula_segments.p_offset; 	// Despla�ament al fitxer del primer byte del segment
							mida_file_segment = taula_segments.p_filesz;	// Mida del file dins de la mem�ria (per copiar el segment)
							mida_mem_segment = taula_segments.p_memsz;   	// Mida del mem dins de la mem�ria (per reservar memoria)
							
							flag = taula_segments.p_flags;					// Agafem el tipus de segment
							
							if (flag == CODE_SEGMENT) // Si es segment de Codi
							{ 
								pAddr_code = taula_segments.p_paddr; // Obtenim direccio de Memoria a reubicar
								dest_code = (int)_gm_reservarMem(zocalo, (unsigned int) mida_mem_segment, 0); // Obtenim contingut de la direccio de Memoria a reubicar
								
								if (dest_code != FAILURE) // Si no hi ha cap problema
								{
									// Rutina per copiar un bloc de memoria des d'una direccio font a una altra desti, coneixent el numero de bytes total.
									// R0: direccio font (inputFile + desp_fit_segment) / R1: direccio desti (dest_code) / R2: numero de bytes a copiar (mida_file_segment)
									_gs_copiaMem((const void *) inputFile + desp_fit_segment, (void *) dest_code, (unsigned int) mida_file_segment);
								} 
								else // Si hi ha algun problema alliberem la memoria i retornem error
								{
									// Rutina per alliberar totes les franges de Memoria assignades al proces del zocalo indicat per parametre
									_gm_liberarMem(zocalo);	// Si no hi ha res a reubicar alliberem la Memoria 
									error = FAILURE;
								}
								
							} else if (flag == DATA_SEGMENT) { // Mateix proces pero amb segment de Dades
 								
								pAddr_data = taula_segments.p_paddr;
								dest_data = (int)_gm_reservarMem(zocalo, (unsigned int) mida_mem_segment, 1);
								
								if (dest_data != FAILURE)
								{
									// Mateixa rutina pero en aquest cas amb direccio font (dest_data)
									_gs_copiaMem((const void *) inputFile + desp_fit_segment, (void *) dest_data, (unsigned int) mida_file_segment);
								} 
								else 
								{
									_gm_liberarMem(zocalo);
									error = FAILURE;
								}
								
							}
						}
						
						// Actualitzem la posici� del segment en cas que n'hi hagi un altre
						desp_segments += sizeof(Elf32_Phdr);
					}
					
					if (error == SUCCESS) // Si tot ha sortit correcte el reubiquem i calculem l'adre�a d'inici
					{
						_gm_reubicar(inputFile, (unsigned int) pAddr_code, (unsigned int *) dest_code, (unsigned int) pAddr_data, (unsigned int *) dest_data);
						startAddress = header.e_entry - pAddr_code + dest_code;
					} else {
						perror("Error\n");  // Si fes falta es podria ampliar la constant o crear una cua FIFO
						startAddress = 0;
					}
					
					free(inputFile);   		// La funci� 'free' allibera la mem�ria pr�viament reservada per una crida a 'calloc', 'malloc' o 'realloc'.
					fclose(fit);            // La funci� 'fclose' tanca l'arxiu. S'assegura que tots els buffers estiguin buidats.
					
					if (numLoadedPrograms < MAX_PROG && startAddress != 0) {	// Si no calculem el startAddress no seguim
						
						// Copiem la informaci� del programa carregat a l'array loadedPrograms
						strncpy(loadedPrograms[numLoadedPrograms].keyName, keyName, MAX_NAME_PROG);
						loadedPrograms[numLoadedPrograms].keyName[MAX_NAME_PROG] = '\0';
						loadedPrograms[numLoadedPrograms].startAddress = (intFunc)startAddress;
						numLoadedPrograms++;
						
					} else {
						perror("S'ha assolit el nombre m�xim de programes carregats.\n");  // Si fes falta es podria ampliar la constant o crear una cua FIFO
						startAddress = 0;
					}
				} else {
					perror("Error llegint el fitxer ELF.");  // Mostrem un missatge d'error en cas de problemes de lectura del fitxer ELF
				}
			} else {
				perror("Error de mem�ria al reservar l'espai de mem�ria per a inputFile");  	// Mostrem un missatge d'error en cas de manca de mem�ria
				free(inputFile);  						// Alliberem la mem�ria del b�fer del fitxer
			}
		} else {
			perror("Error obrint el fitxer ELF");
			fclose(fit);  		// Tanquem el fitxer
		}
	}
	
	return ((intFunc)startAddress);	// Retornem la direccio d'inici del programa (intFunc)
}




