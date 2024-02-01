@;==============================================================================
@;
@;	"garlic_itcm_mem.s":	código de rutinas de soporte a la carga de
@;							programas en memoria (version 2.0)
@;
@;==============================================================================

NUM_ZOC = 16
NUM_FRANJAS = 768	
MAX_COL = 32						
COL_ESTAT = 26
INI_MEM_PROC = 0x01002000
BASE_MAP = 0x6200000


.section .dtcm,"wa",%progbits
	.align 2


	.global _gm_zocMem
_gm_zocMem:	.space NUM_FRANJAS			@; vector de ocupacion de franjas mem.

	.align 2
.global _gm_num_franja_zoc
_gm_num_franja_zoc:	.space NUM_ZOC			@; vector de mida de franjes de zocalos


.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gm_reubicar
	@; rutina de soporte a _gm_cargarPrograma(), que interpreta los 'relocs'
	@; de un fichero ELF, contenido en un buffer *fileBuf, y ajustar las
	@; direcciones de memoria correspondientes a las referencias de tipo
	@; R_ARM_ABS32, a partir de las direcciones de memoria destino de código
	@; (dest_code) y datos (dest_data), y según el valor de las direcciones de
	@; las referencias a reubicar y de las direcciones de inicio de los
	@; segmentos de código (pAddr_code) y datos (pAddr_data)
	@;Parámetros:
	@; R0: dirección inicial del buffer de fichero (char *fileBuf)
	@; R1: dirección de inicio de segmento de código (unsigned int pAddr_code)
	@; R2: dirección de destino en la memoria (unsigned int *dest_code)
	@; R3: dirección de inicio de segmento de datos (unsigned int pAddr_data)
	@; (pila): dirección de destino en la memoria (unsigned int *dest_data)
	@;Resultado:
	@; cambio de las direcciones de memoria que se tienen que ajustar
_gm_reubicar:
    push {r0-r12, lr}
    
	@; r4: Valor de la pila
	ldr r4, [r13, #56] 			@; r4 = dest_data (SP + offset = r13 + 13 * 4))

    mov r12, #0 				@; Inicialització del comptador del bucle de seccions
	
.For_taula_seccions:
    @; Mida de cada entrada de la taula de seccions
    ldrh r5, [r0, #46]        	@; r5 = e_shentsize (posició 46) = (HalfWord de 2 bytes)  ldrh
    
    @; Recorregut de totes les seccions amb un bucle
    mul r7, r12, r5             @; r7 = índex de seccions (r3) * mida de seccions e_shentsize (r5)
    add r8, r7, #4             	
    
	@; Desplaçament de la taula de seccions (secció d'encapçalament)
    ldr r11, [r0, #32]			@; r11 = e_shoff (posició 32) = (Word de 4 bytes)
	
    add r8, r8, r11            	@; r8 = (r7 + 4) + desplaçament en el buffer -> per obtenir el tipus 
	
	@; Nombre d'entrades de la taula de seccions
    ldrh r5, [r0, #48]       	@; r5 = e_shnum (posició 48) = (HalfWord de 2 bytes)  ldrh   
    
    @; r8 = (índex de seccions * (mida de seccions + 4 (posició del tipus a la taula))) + r4 (e_shoff)
    
    add r12, r12, #1            @; Actualització del comptador r12++
    cmp r12, r5                 @; (r3 > r6) Final del bucle? 
    bgt .LFiR
    
    ldr r6, [r0, r8]           	@; r6 = tipus secció 
    cmp r6, #9                 	@; sh_type: tipus de la secció; les seccions de reubicadors són de tipus 9 (SHT_REL),
    bne .For_taula_seccions    	@; (r6 != 9) --> continuem buscant
    
    add r8, r7, #20            	@; r8 = r7 (índex de seccions (r3) * mida de seccions e_shentsize (r5)) + 20 
    add r8, r8, r11             @; r8 conté el desplaçament en el búfer de la mida de la secció + e_shoff (r4)
    
    @; (r7 + 20 + e_shoff)
    
    ldr r10, [r0, r8]          	@; r10 = sh_size 
    mov r10, r10, lsr #3       	@; r10 = nombre d'entrades a l'estructura de reubicadors 
								@; lsr #3 = dividir entre 8 bytes (2^3=8)
    
    add r8, r7, #16            	@; r8 = r7 (índex de seccions (r3) * mida de seccions e_shentsize (r5)) + 16
    add r8, r8, r11             @; r8 = conté el desplaçament en el búfer per a la posició del primer byte de la secció (r7 + 16 + e_shoff (r4))
    ldr r9, [r0, r8]          	@; r11 = sh_offset 
    
    @; Analitzar quins reubicadors són de tipus R_ARM_ABS32 (tipus = 2)
    mov r6, #0 				   	@; índex bucle reubicadors 
    
.For_estructura_reubicadors:
    mov r8, #8                 	@; r8 = 8
    
    @; Moure's pel reubicador
    mul r7, r6, r8             	@; r7 = índex de reubicadors (r9) * mida estructura reubicadors (r8)
    add r7, r7, r9            	@; r11 = sh_offset
    add r8, r7, #4             	@; r8 = desplaçament pel búfer (r7 + 4 + sh_offset (r11))
    @; obtenir r_info
    
    add r6, r6, #1             	@; Actualització del comptador r9++
    cmp r6, r10                	@; (r9 > r10) -> fins processar totes les entrades
    bgt .For_taula_seccions
    
    ldrb r11, [r0, r8]         	@; r12 = r_info (volem obtenir els 8 bits baixos, indica el tipus)
    cmp r11, #2                	@; (r12 != 2) 
    bne .For_estructura_reubicadors
    
    ldr r11, [r0, r7]          	@; r12 = r_offset
    
    @; Obtenir adreça de memòria destinació --> adreça memòria corresponent a R_ARM_ABS32 - adreça inici segment (r1) + adreça destinació memòria (r2)
    sub r11, r11, r1
    add r11, r11, r2
    
    ldr r8, [r11]              	@; Agafem el valor d'aquesta posició
	
	cmp r4, #0 					@; (comparem pila amb dest_data) / Comprovem si està al segment de codi o de dades
	
	beq .SegmentCode			@; pila == 0 -> Segment de codi
	
	cmp r8, r3					 
	bhs .SegmentData			@; (valor >= pAddr_data) -> Segment de dades
	
.SegmentCode:
	sub r8, r8, r1 				@; r1 = pAddr_code
	add r8, r8, r2				@; r2 = dest_code
	
	str r8, [r11]				@; Guardem

	b .ComprovFiR

.SegmentData:
	sub r8, r8, r3 				@; r3 = pAddr_data
	add r8, r8, r4				@; r4 = dest_data (pila)
	
	str r8, [r11]  				@; Guardem
 	
.ComprovFiR:
	cmp r6, r10					@; (r6 > r10) -> fins processar totes les entrades
	
	bge .For_taula_seccions
	b .For_estructura_reubicadors
	
.LFiR:
    pop {r0-r12, pc}
	
	
	
	.global _gm_reservarMem
	@; Rutina para reservar un conjunto de franjas de memoria libres
	@; consecutivas que proporcionen un espacio suficiente para albergar
	@; el tamaño de un segmento de código o datos del proceso (según indique
	@; tipo_seg), asignado al número de zócalo que se pasa por parámetro;
	@; también se encargará de invocar a la rutina _gm_pintarFranjas(), para
	@; representar gráficamente la ocupación de la memoria de procesos;
	@; la rutina devuelve la primera dirección del espacio reservado; 
	@; en el caso de que no quede un espacio de memoria consecutivo del
	@; tamaño requerido, devuelve cero.
	@;Parámetros
	@;	R0: el número de zócalo que reserva la memoria
	@;	R1: el tamaño en bytes que se quiere reservar
	@;	R2: el tipo de segmento reservado (0 -> código, 1 -> datos)
	@;Resultado
	@;	R0: dirección inicial de memoria reservada (0 si no es posible)
_gm_reservarMem:
	push {r1-r9, lr}
		
	cmp r1, #0					@; r1 = mida en bytes que es vol reservar -> Comptador per saber quants bytes queden per reservar 
	beq .LFiRM					@; (r1 == 0) -> Quan no queden mes bytes a reservar -> acabem funcio

	mov r3, #0 					@; r3 = index del vector _gm_zocMem[r3] = per fer el desplaçament
	ldr r4, =_gm_zocMem 		@; r4 = adreça base del vector 
	mov r6, #0			 		@; r6 = variable per guardar la mida de blocs seguits 
	mov r7, #0 					@; r7 = index inici franjes
	mov r8, #0 					@; r8 = nombre de franjes a pintar 
	
	@; Busquem les franjes consecutives que tenen espai per la mida del segment
.For_RMem_1:
	ldrb r5, [r4, r3] 			@; r5 = _gm_zocMem[index_vector] = r4[r3]
	
	cmp r5, #0 					@; Si _gm_zocMem[index_vector] = 0 -> en aquella posició esta lliure
	bne .LsegBloc				@; Si no esta lliure passem a mirar el seguent bloc
	
	add r8, #1 					@; r8++ (nombre de franjes a pintar + 1)
	add r6, #32 				@; r6 + 32 -> augmentem la mida dels blocs seguits -> 32 bytes per franja
	
	cmp r6, r1					@; Comparem els blocs que tenim amb el que ens falta reservar
	bge .LparametresFunct 		@; (r6 >= r1) -> La mida és >= a la que volem guardar (r0) -> Ja hem acabat
	blo .LsumIndex 				@; (r6 < r1) -> Encara ens falten buscar més blocs, no hi cap tot encara 

.LsegBloc:
	mov r6, #0					@; Reinicialitzem comptadors
	mov r8, #0					
	add r7, r3, #1				@; r7 = r3 + 1 -> Guardem l'index inicial d'on comencen les franjes
	
.LsumIndex:
	add r3, #1					@; Augmentem índex vector 
	cmp r3, #NUM_FRANJAS		@; Comparem el index del vector amb la seva maxima capacitat (768)
	blo .For_RMem_1				@; (r3 < NUM_FRANJAS) -> Seguim
	beq .Lerror					@; Si arribem al final del vector -> Lerror
	
.LparametresFunct:
	mov r3, r2					@; r3 = tipus de segment reservat (r2) -> (0 -> código, 1 -> datos) - per cridar a _gs_pintarFranjas
	mov r1, r7 					@; r1 = index inicial de les franjes (r7) - per cridar a _gs_pintarFranjas
	mov r2, r8 					@; r2 = nombre de franjes a pintar (r8) - per cridar a _gs_pintarFranjas
	
	bl _gs_pintarFranjas		@; Cridem a _gm_pintarFranjas (rutina para pintar las líneas verticales) i torna (branch with link)

	mov r5, #0 					@; r5 = comptador bucle For_RMem_2
	
.For_RMem_2:					@; Bucle per guardar a _gm_zocMem el numero de zocalo
	strb r0, [r4, r7]			@; Guardem r0 a _gm_zocMem[index_inici_franjes] 
	
	add r7, #1					@; r7++
	add r5, #1					@; r5++
	
	cmp r5, r8					@; Comparem franjes pintades, amb franjes per pintar
	bne .For_RMem_2				@; (r5 != r8) -> comptador bucle For_RMem_2 != nombre de franjes a pintar -> Seguim bucle
	
.Fi_2:				
	ldr r9, =_gm_num_franja_zoc @; Actualitzem taula de nombre de franjes per zocalo ->
	ldrb r4, [r9, r0]			@; Carreguem a r4 el byte guardat a num_franja_zoc[numero_zocalo]
	add r4, r2 					@; Nombre de franjes d'aquest zocalo + nombre de franjes que hem carregat
	strb r4, [r9, r0]			@; Guardem a la taula el total de franjes actuals

	@; Calculem adreça inicial per retornar
	ldr r0, =INI_MEM_PROC		@; r0 = 0x01002000 (Inici memòria per procés)
	mov r6, r1, lsl #5			@; r6 = index inici franja (r1) * mida de la franja (32 B)
	add r0, r6 					@; r0 = INI_MEM_PROC + r6
	
	b .LFiRM
	
.Lerror:
	mov r0, #0 					@; Si hi ha error -> r0 = adreça inicial de memoria reservada = 0
	
.LFiRM:							
	pop {r1-r9, pc}



	.global _gm_liberarMem
	@; Rutina para liberar todas las franjas de memoria asignadas al proceso
	@; del zócalo indicado por parámetro; también se encargará de invocar a la
	@; rutina _gm_pintarFranjas(), para actualizar la representación gráfica
	@; de la ocupación de la memoria de procesos.
	@;Parámetros
	@;	R0: el número de zócalo que libera la memoria
_gm_liberarMem:
	push {r0-r9, lr}
	
	ldr r9, =_gm_num_franja_zoc	@; r9 = taula de nombre de franjes per zocalo
	ldrb r2, [r9, r0]  			@; r2 = nombre de franjes del zocalo (passat per parametre r0)
	
	mov r1, #0  				@; r1 = index 
	mov r3, #0  				@; _gm_pintarFranjas -> R3: tipo_seg -> el tipo de segmento reservado (0 -> código)
	mov r4, #0  				@; r4 = index del vector _gm_zocMem[r4] = per fer el desplaçament
	ldr r5, =_gm_zocMem  		@; r5 = adreça base del vector 
	mov r7, r2  				@; r7 = r2 per comprovar si em alliberat totes les franjes
 	
	mov r8, r0 					@; Copia de r0, necessari per _gm_pintarFranjas
	mov r0, #0 					@; Per borrar -> _gm_pintarFranjas -> R0: zocalos -> si el primer zocalo de la lista es 0, las franjas se borraran (en negro)
 	
.Lbucle:						@; Bucle on mirem posicio per posicio, si (r6 == r0 (copia a r8)) -> Posem un 0
	ldrb r6, [r5, r4]  			@; Carreguem a r6 el byte de _gm_zocMem[r4]	= r5[r4]
	cmp r6, r8  				@; Busquem el numero de zocalo per borrar
	bne .LsegBloc2				@; (r6 != r8) -> Si no ho es passem a mirar el seguent bloc

	@; Si ho es el posem a 0
	strb r0, [r5, r4]  			@; Guardem r0 (0) a la posicio del vector a borrar -> _gm_zocMem[r4] = r5[r4]
	
	sub r7, #1					@; r7-- Una franja alliberada
	cmp r7, #0	

	beq .LpintarFranjas2		@; Si (r7 == 0) -> Hem acabat -> cridem a _gm_pintarFranjas
	
.LsumIndexLibM:
	add r4, #1					@; r4++
	
	cmp r4, #NUM_FRANJAS		
	beq .LfiLM					@; (r4 == NUM_FRANJAS) -> Hem arribat el final del vector -> Acabem funcio
	
	b .Lbucle					@; Sino seguim bucle
	
.LsegBloc2:
	add r1, r4, #1  			@; r1 = r1 + r4 (index del vector) + 1 -> Actualitzem index inicial del segment 
	
	cmp r7, r2					@; Comparem nombre de franjes del zocalo (r7) i franjes alliberades (r2)
	blo .LpintarFranjas			@; Si (r7 < r2) = Hem acabat d'aquesta posicio del _gm_zocMem
	
	b .LsumIndexLibM			@; Si (r7 >= r2) -> Seguim

.LpintarFranjas:				
	sub r2, r7  				@; r2 = franjes primer segment (total - restants)
	bl _gs_pintarFranjas		
	
	mov r2, r7  				@; r2 = franjes totals del segon segment
	b .Lbucle					@; Seguim amb el bucle
	
.LpintarFranjas2:				
	bl _gs_pintarFranjas		@; r0 ja es 0 per borrar	
	
.LfiLM:
	strb r0, [r9, r8]  			@; Guardem a r0 el byte contingut en la posicio de memoria de la suma de num_franja_zoc mes el numero de zocalo que allibera la memoria 
	
	pop {r0-r9, pc}				
	

	.global _gm_pintarFranjas
	@; _gm_pintarFranjas: rutina para pintar las líneas verticales correspondientes
	@;			a un conjunto de franjas consecutivas de memoria asignadas a un
	@;			segmento (de código o datos) del zócalo indicado por parámetro.
	@;Parámetros:
	@;	R0: zocalos		->	vector con numeros de zocalo de los procesos que estan
	@;						ocupando el rango de franjas indicado; la lista de
	@;						zocalos se termina con un valor centinela -1;
	@;						solo se permitiran mas de un zocalo si el segmento es
	@;						de tipo codigo (tipo_seg = 0);
	@;						si el primer zocalo de la lista es 0, las franjas se
	@;						borraran (en negro)
	@;	R1: index_ini	->	el índice inicial de las franjas
	@;	R2: num_franjas	->	el número de franjas a pintar
	@;	R3: tipo_seg	->	el tipo de segmento reservado (0 -> código, 1 -> datos)
_gm_pintarFranjas:
	push {r0-r8, lr}
	
	@;  Rutina para para pintar las franjas verticales correspondientes a un
	@; conjunto de franjas consecutivas de memoria asignadas a un segmento
	@; (de código o datos) del zócalo indicado por parámetro.
	
	bl _gs_pintarFranjas		
	
	pop {r0-r8, pc}
	

	.global _gm_rsiTIMER1
	@; Rutina de Servicio de Interrupción (RSI) para actualizar la representa-
	@; ción de la pila y el estado de los procesos activos.
_gm_rsiTIMER1:
	push {r0-r7, lr}

	mov r1, #MAX_COL			@; MAX_COL = 32
	mov r2, #COL_ESTAT			@; COL_ESTAT = 26 

.ProgramaRun:	
	ldr r0, =_gd_pidz			@; r0 = _gd_pidz -> Identificador de proceso (PID) + zócalo	(PID en 28 bits altos, zócalo en 4 bits bajos) // cero si se trata del propio sistema operativo
	ldr r0, [r0]				@; Carreguem el contingut de dins _gd_pidz
	and r0, #0xf 				@; Obtenim els  4 bits baixos per el zocalo
	
	add r5, r0, #4 				@; r5 = r0 + 4 -> fila = zocalo + 4
	
	@; Offset = (MAX_COL * fila + columna ) * Mida_Dades	
	mla r5, r1, r5, r2 			@; r5 = MAX_COL (r1) * fila (r5) + columna (r2)
	mov r5, r5, lsl #1 			@; r5 = r5 * Mida_dades -> Com que es un Hword = 2 = lsl 1
	
	add r5, #BASE_MAP 			@; Offset + BASE_MAP (0x6200000)
	
	mov r3, #178 				@; R (Run) -> valor = posicio mapa lletra - posicio inicial = 0x1B2-0x100 = 0xB2 = 178 
	strh r3, [r5]
	
	bl _gs_representarPilas		@; Cridem a la funcio per pintar les piles
	
.ComprovReady:					@; Primer mirem els processos de Ready (R)
	ldr r4, =_gd_nReady			@; _gd_nReady -> Cola de READY (procesos preparados)
	ldr r4, [r4] 				@; r4 = nombre de processos a la cua de Ready
	
	cmp r4, #0
	beq .ComprovDelay			@; Si no trobem cap -> Busquem a la seguent opcio
	
	ldr r6, =_gd_qReady			@; _gd_qReady -> Cola de READY (procesos preparados)
	mov r7, #0
	
.ProgramesReady:				@; Si em trobat algun busquem tots els que hi hagi 
	ldrb r0, [r6, r7]
	
	add r5, r0, #4 				@; r5 = r0 + 4 -> fila = zocalo + 4
	
	@; Offset = (MAX_COL * fila + columna ) * Mida_Dades	
	mla r5, r1, r5, r2 			@; r5 = MAX_COL (r1) * fila (r5) + columna (r2)
	mov r5, r5, lsl #1 			@; r5 = r5 * Mida_dades -> Com que es un Hword = 2 = lsl 1
	
	add r5, #BASE_MAP 			@; Offset + BASE_MAP (0x6200000)

	mov r3, #57 				@; Y (Ready) -> valor = 0x139-0x100 = 0x39 = 57 
	strh r3, [r5]
	
	bl _gs_representarPilas		@; Cridem a la funcio per pintar les piles
	
	add r7, #1
	cmp r7, r4
	bne .ProgramesReady			@; Quan no n'hi ha mes busquem a la seguent opcio
	
.ComprovDelay:					@; En segon lloc mirem els processos de Delay (D)
	ldr r4, =_gd_nDelay			@; _gd_nDelay -> Número de procesos en la cola de DELAY
	ldr r4, [r4] 				@; r4 = nombre de processos a la cua de Delay
	
	cmp r4, #0
	beq .ComprovKB				@; Si no trobem cap -> Busquem a la seguent opcio
	
	ldr r6, =_gd_qDelay			@; _gd_qDelay -> Cola de DELAY (procesos retardados)
	
	mov r7, #0

.ProgramesDelay:				@; Si em trobat algun busquem tots els que hi hagi 
	ldr r0, [r6, r7, lsl #2]
	and r0, #0xFF000000 		@; Mascara per obtenir el zocalo
	mov r0, r0, lsr #24			@; Baixar el zocalo als 8 bits baixos
	
	add r5, r0, #4 				@; r5 = r0 + 4 -> fila = zocalo + 4
	
	@; Offset = (MAX_COL * fila + columna ) * Mida_Dades	
	mla r5, r1, r5, r2 			@; r5 = MAX_COL (r1) * fila (r5) + columna (r2)
	mov r5, r5, lsl #1 			@; r5 = r5 * Mida_dades 
	
	add r5, #BASE_MAP 			@; Offset + BASE_MAP (0x6200000)	
	
	mov r3, #36 				@; B blanca -> valor = 0x122-0x100 = 0x22 
	strh r3, [r5]	
	
	bl _gs_representarPilas		@; Cridem a la funcio per pintar les piles
	
	add r7, #1
	cmp r7, r4
	bne .ProgramesDelay			@; Quan no n'hi ha mes busquem a la seguent opcio
	
.ComprovKB:						@; Finalment els processos de keyboard (K)
	ldr r4, =_gd_num_kbwait		@; _gd_num_kbwait -> Vector de procesos esperando teclado.
	ldrb r4, [r4] 				@; r4 = nombre de processos a la cua de Ready
	
	cmp r4, #0
	beq .LFiRSI					@; Si no en trobem cap -> Acabem, no hi ha mes opcions
	
	ldr r6, =_gd_kbwait			@; _gd_kbwait -> Número de procesos esperando teclado.
	
	mov r7, #0
	
.ProgramesKB:
	ldrb r0, [r6, r7]
	
	add r5, r0, #4 				@; r5 = r0 + 4 -> fila = zocalo + 4
	
	@; Offset = (MAX_COL * fila + columna ) * Mida_Dades	
	mla r5, r1, r5, r2 			@; r5 = MAX_COL (r1) * fila (r5) + columna (r2)
	mov r5, r5, lsl #1 			@; r5 = r5 * Mida_dades 
	
	add r5, #BASE_MAP 			@; Offset + BASE_MAP (0x6200000)
	
	mov r3, #43 				@; K (Keyboard) -> valor = 0x12B-0x100 = 0x2B = 43 
	strh r3, [r5]
	
	bl _gs_representarPilas		@; Cridem a la funcio per pintar les piles
	
	add r7, #1
	
	cmp r7, r4
	bne .ProgramesKB			@; Busquem fins a no tenir-ne cap
	
.LFiRSI:

	pop {r0-r7, pc}

	
.end
