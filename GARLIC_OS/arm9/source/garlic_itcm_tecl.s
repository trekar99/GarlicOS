@;==============================================================================
@;
@;	"garlic_itcm_tecl.s": código de las rutinas relativas a la gestión de teclado.
@; 
@;==============================================================================

.include "../include/garlic_tecl_incl.i"

.section .itcm,"ax",%progbits

	.arm
	.align 2

	.global _gt_getstring
	@; Rutina que recibe por parámetro la dirección de un vector de caracteres
	@; donde guardar el string introducido por teclado, así como el número
	@; máximo de caracteres que puede contener el vector (excluido el
	@; centinela), y devuelve como resultado el número de caracteres leídos
	@; finalmente (excluido el centinela)
	@;Parámetros:
	@; R0: string -> dirección base del vector de caracteres (bytes)
	@; R1: max_char -> número máximo de caracteres del vector
	@; R2: zocalo -> número de zócalo del proceso invocador
	@;Return
	@; R0: lenght string
_gt_getstring:
	push {r1-r6, lr}
	
	mov r4, r1						@; R4 = copia max char
	mov r5, r0						@; R5 = dirección base del vector de caracteres.
	mov r6, #0						@; R6 = tipo teclado string (#0)
	
	bl _gp_inhibirIRQs
	bl _gt_kbwaitAdd				@; Añadimos el proceso para solicitar teclado.
	bl _gp_desinhibirIRQs

	ldr r3, =_gt_activeKB			@; Comprobamos si el teclado está activo
	ldr r3, [r3]
	
	cmp r3, #1						@; Si esta activo, esperar.
	beq .LWaitForStartKB
	
.LShowKB:
	ldr r3, =_gt_str_lenght
	ldr r1, =_gt_str_lenght_buf
	ldrb r1, [r1]
	str r1, [r3]
	
	ldr r1, =_gt_typeKB				@; Teclado tipo string
	ldr r3, =_gt_typeKB_buf
	ldrb r3, [r3]
	str r3, [r1]
	
	push {r0-r2}
	bl _gt_putPIDZ 				
	bl _gt_showKB 		
	pop {r0-r2}
	
.LWaitForStartKB:
	ldr r3, = _gd_pidz				
	ldr r4, [r3]					@; R4 = _gd_pidz
	orr r4, r4, #0x80000000			@; Bit alto a de _gd_pidz a 1
	str r4, [r3]					
	
	bl _gp_WaitForVBlank			@; Retroceso vertical para aliviar CPU
	
	mov r0, r5						@; R0 = dirección base del vector de caracteres.

	bl _gt_cpy_str
	bl _gt_resetKB
	
	ldr r3, =_gd_num_kbwait			@; Comprobar si quedan peticiones de teclado.
	ldrb r3, [r3]					
	
	cmp r3, #0
	bleq _gt_hideKB
	bleq .LFiGetString
	
.LShowKBNext:
	ldr r2, =_gt_str_lenght			@; Ponemos la max lenght del proximo teclado.
	ldr r3, =_gt_str_lenght_buf
	ldrb r3, [r3]
	str r3, [r2]
	
	ldr r1, =_gt_typeKB				@; Teclado tipo string
	ldr r3, =_gt_typeKB_buf
	ldrb r3, [r3]
	str r3, [r1]

	ldr r2, =_gd_kbwait				
	ldrb r2, [r2]					@; R2 = siguiente zocalo.
	bl _gt_putPIDZ 					@; Ponemos en pantalla el siguiente.
	
.LFiGetString:

	pop {r1-r6, pc}

	.global _gt_getnumber
	@; Función que recibe por parámetro el type 'x' o 'd', según se desee 
	@; interpretar el número introducido por el usuario como valor hexadecimal 
	@; o decimal, respectivamente, o en caso de escoger 'd', se admitirá un 
	@; signo menos delante del número, o el usuario solo podrá teclear dígitos 
	@; del subconjunto correspondiente, és decir, o bien dígitos hexa o bien 
	@; dígitos decimales más el símbolo de menos '-', y no se permitirá al 
	@; usuario rebasar el rango de los números de 32 bits.
	@;Parámetros:
	@; R0: type -> tipo de dato 'x' o 'd'
	@; R2: zocalo -> número de zócalo del proceso invocador
	@;Return
	@; R0: number
_gt_getnumber:
	push {r1-r6, lr}
	
	@; Proceso de sincronización igual a getstring.

	cmp r0, #'d'					@; 'x': teclado hexa
	moveq r6, #1					@; R6 = teclado type (decimal)
	moveq r4, #11					@; R4 = max lenght (decimal)

	cmp r0, #'x'
	moveq r6, #2					@; R6 = teclado type (hexa)
	moveq r4, #8					@; R4 = max lenght (hexa)
	
	cmp r0, #'q'
	moveq r6, #3					@; R6 = teclado type (q12)
	moveq r4, #11					@; R4 = max lenght (q12)

	bl _gp_inhibirIRQs
	bl _gt_kbwaitAdd				@; Añadimos el proceso para solicitar teclado.
	bl _gp_desinhibirIRQs

	ldr r3, =_gt_activeKB			@; Comprobamos si el teclado está activo
	ldr r3, [r3]
	
	cmp r3, #1						@; Si esta activo, esperar.
	beq .LWaitForStartKB2
	
.LShowKB2:	
	ldr r3, =_gt_str_lenght
	ldr r1, =_gt_str_lenght_buf
	ldrb r1, [r1]
	str r1, [r3]
	
	ldr r1, =_gt_typeKB				
	ldr r3, =_gt_typeKB_buf
	ldrb r3, [r3]
	str r3, [r1]
	
	push {r0-r2}
	bl _gt_putPIDZ 				
	bl _gt_showKB 					
	pop {r0-r2}
	
.LWaitForStartKB2:
	ldr r3, = _gd_pidz				
	ldr r4, [r3]					@; R4 = _gd_pidz
	orr r4, r4, #0x80000000			@; Bit alto a de _gd_pidz a 1
	str r4, [r3]					
	
	bl _gp_WaitForVBlank			@; Retroceso vertical para aliviar CPU

	bl _gt_cpy_num
	mov r5, r0
	bl _gt_resetKB
	
	ldr r3, =_gd_num_kbwait			@; Comprobar si quedan peticiones de teclado.
	ldrb r3, [r3]					
	
	cmp r3, #0
	bleq _gt_hideKB
	bleq .LFiGetNumber

.LShowKBNext2:
	ldr r2, =_gt_str_lenght			@; Ponemos la max lenght del proximo teclado.
	ldr r3, =_gt_str_lenght_buf
	ldrb r3, [r3]
	str r3, [r2]
	
	ldr r1, =_gt_typeKB				
	ldr r3, =_gt_typeKB_buf
	ldrb r3, [r3]
	str r3, [r1]

	ldr r2, =_gd_kbwait				
	ldrb r2, [r2]					@; R2 = siguiente zocalo.
	bl _gt_putPIDZ 					@; Ponemos en pantalla el siguiente.
	
.LFiGetNumber:
	mov r0, r5

	pop {r1-r6, pc}

	.global _gt_kbwaitAdd
	@; Función auxiliar para añadir zócalo a la cola de espera de teclado.
	@; Y para añadir el max lenght de las peticiones de teclado.
	@;Parámetros
	@; R2 = zócalo
	@; R4 = max lenght str
	@; R6 = teclado type
_gt_kbwaitAdd:
	push {r0-r7, lr}
	
	ldr r0, =_gd_kbwait
	ldr r1, =_gd_num_kbwait
	ldr r5, =_gt_str_lenght_buf
	ldr r7, =_gt_typeKB_buf
	
	ldr r3, [r1]
	strb r2, [r0, r3]				@; Añadimos el número de zócalo a la cola.
	cmp r4, #LIM_RIGHT
	movhi r4, #LIM_RIGHT
	strb r4, [r5, r3]
	strb r6, [r7, r3]
	
	add r3, #1						@; Añadimos +1 a num procesos espera.
	str r3, [r1]
	
	pop {r0-r7, pc}
	
	.global _gt_kbwaitRemove
	@; Función auxiliar para quitar zócalo a la cola de espera de teclado.
	@; Y para quitar el max lenght de las peticiones de teclado.
_gt_kbwaitRemove:
	push {r0-r8, lr}
	
	ldr r0, =_gd_kbwait
	ldr r1, =_gd_num_kbwait
	ldr r5, =_gt_str_lenght_buf
	ldr r7, =_gt_typeKB_buf
	ldr r2, [r1]
	
	sub r2, #1						@; Restamos -1 a num procesos espera.
	str r2, [r1]
	
	mov r3, #0					@; Contador
.LMoverCola:
	add r3, #1					
	ldrb r4, [r0, r3]	
	ldrb r6, [r5, r3]
	ldrb r8, [r7, r3]
	sub r3, #1					
	strb r4, [r0, r3]			@; _gd_kbwait[i] = _gd_kbwait[i+1]
	strb r6, [r5, r3]
	strb r8, [r7, r3]
	add r3, #1				

	cmp r2, r3					@; Si R2 (numKBWait) > R3 (índex) itera
	bhi .LMoverCola			
	
	pop {r0-r8, pc}

	.global _gt_cpy_str
	@; Función auxiliar que copia string auxiliar a string de return.
	@;Parámetros
	@; R0 = dirección string
	@;Return
	@; R0 = lenght string
_gt_cpy_str:
	push {r1-r5, lr}
	
	ldr r1, = _gt_str_input
	
	mov r2, #0						@; Contador
	mov r4,	#0						@; Lenght total
.LForLenght:
	ldrb r3, [r1, r2]				@; Iteramos sobre la string	
	
	cmp r3, #200					@; Contar último carácter útil.

	movne r4, r2 
	
	add r2, #1
	cmp r2, #32
	bne .LForLenght	
	
	add r4, #1
	mov r2, #0						@; Contador
	mov r5, #1
.LForStr:
	ldrb r3, [r1, r5]				@; Iteramos sobre la string	
	strb r3, [r0, r2]				@; Copiamos ASCII en dirección string

	add r2, #1
	add r5, #1
	cmp r2, r4						@; If index < lenght: itera
	blo .LForStr

.LAddCentinela:
	mov r3, #0
	strb r3, [r0, r2]				@; Añadimos centinela al final de string.
	
	cmp r4, #0						
	subne r4, #1
	mov r0, r4						@; R0 = lenght string.
	pop {r1-r5, pc}

	.global _gt_cpy_num
	@; Función auxiliar que pasa de string ASCII a num.
	@;Return
	@; R0 = lenght string
_gt_cpy_num:
	push {r1-r10, lr}
		
	ldr r1, =_gt_str_input
	ldr r5, =_gt_str_lenght
	ldr r5, [r5]
	
	mov r2, #0						@; Contador
	mov r4,	#0						@; Lenght total
.LForLenght2:
	ldrb r3, [r1, r2]				@; Iteramos sobre la string	
	
	cmp r3, #200					@; Contar último carácter útil.
	movne r4, r2 
	
	add r2, #1
	cmp r2, r5
	bls .LForLenght2
	
	mov r5, #0						@; Num final
	add r4, #1
	mov r2, #0						@; Contador
	mov r7, #0
	
	ldr r6, =_gt_typeKB
	ldr r6, [r6]
	cmp r6, #2
	beq .LForHexa
	
	cmp r6, #3
	beq .LForQ12

.LForDec:
	ldrb r3, [r1, r2]				@; Iteramos sobre la string	
	
	cmp r3, #200
	moveq r3, #0
	subne r3, r3, #'0'
	
	cmp r2, #2
	movhi r6, #10
	mulhi r7, r5, r6

    add r5, r7, r3
	
	add r2, #1
	cmp r2, r4						@; If index < lenght: itera
	blo .LForDec
	
	ldrb r3, [r1, #1]				
	cmp r3, #45						@; Si tiene signo negativo lo negamos
	rsbeq r5, r5, #0

	b .LFiGetNum

.LForHexa:
	ldrb r3, [r1, r2]				@; Iteramos sobre la string	
	
	cmp r3, #200
	moveq r3, #0
	subne r3, r3, #'0'

	cmp r3, #17						@; ASCII A = 65 - '0' = 17
	subhs r3, r3, #7				
	
	cmp r2, #1
	movhi r5, r5, lsl #4			@; 0xF --> 0xF0
	orr r5, r5, r3					@; 0xF0 --> 0xFF
	
	add r2, #1
	cmp r2, r4						@; If index < lenght: itera
	blo .LForHexa
	b .LFiGetNum	

.LForQ12:
	mov r8, #0						@; R8 = signo
	mov r9, #0						@; R9 = parte entera
	mov r10, #0						@; R10 = parte decimal
	
	ldrb r8, [r1, #1]
	cmp r8, #200					@; Si es vacio
	moveq r8, #0
	
	cmp r8, #32						@; Si es positivo
	moveq r8, #0
	
	cmp r8, #45						@; Si hay signo
	moveq r8, #1
	
	mov r2, #2
.LForQ12Int:
	ldrb r3, [r1, r2]				@; Iteramos sobre la string	
	
	cmp r3, #200
	moveq r3, #0
	subne r3, r3, #'0'
	
	cmp r2, #2
	movhi r6, #10
	mulhi r7, r9, r6

    add r9, r7, r3
	
	add r2, #1
	cmp r2, #7						@; If index < len(parte entera): itera
	blo .LForQ12Int
	
	mov r2, #8
	mov r7, #0
.LForQ12Deci:
	ldrb r3, [r1, r2]				@; Iteramos sobre la string	
	
	cmp r3, #200
	moveq r3, #0
	subne r3, r3, #'0'
	
	cmp r2, #8
	movhi r6, #10
	mulhi r7, r10, r6

    add r10, r7, r3
	
	add r2, #1
	cmp r2, #12						@; If index < len(parte entera): itera
	blo .LForQ12Deci
	
	mov r0, r8
	mov r1, r9
	mov r2, r10
	bl _gt_make_q12
	mov r5, r0
	
.LFiGetNum:
	cmp r5, #0
	moveq r0, #0
	movne r0, r5						@; R0 = lenght string.
	
	pop {r1-r10, pc}

	.global _gt_putPIDZ
	@; Función auxiliar que escribe en la interfaz de teclado el número de 
	@; zócalo y el PID.
	@;Parámetros:
	@; R2: num zocalo
_gt_putPIDZ:
	push {r0-r7,lr}
	
	mov r5, r2					@; R5 = copia num zocalo.
	
	@; _gs_num2str_dec: R0 = string, R1 = MAXELEMS, R2 = ZÓCALO

	ldr r0, =_gt_aux			@; R0 = string aux
	mov r1, #3					@; R1 = 2 + CENTINELA
	bl _gs_num2str_dec			@; NUMBER TO ASCII
	
	ldr r0, =_gt_aux			@; R0 = string aux
	ldr r2, =_gt_mapbgKB		
	ldr r2, [r2]				
	mov r6, r2					
	add r2, #22					@; Nos posicionamos en <z00>
	
	mov r1, #0					
.LPutZoc:
	ldrb r4, [r0, r1]			
	cmp r4, #32					
	subne r4, #32				@; Si es num 0-9 pasamos a codificación baldosas.

	subeq r4, #16				@; Si es espacio (32) menos 16 para obtener un 0.
	mov r3, r1, lsl #1			
	strh r4, [r2, r3]			
	add r1, #1					
	cmp r1, #3					
	blo .LPutZoc 
	
	@; _gs_num2str_dec: R0 = string, R1 = MAXELEMS, R2 = ZÓCALO

	mov r4, #24
	mul r3, r5, r4
	ldr r2, =_gd_pcbs
	ldr r2, [r2, r3] 			@; Coger PID de tabla pcbs por num zocalo.
  
	ldr r0, =_gt_aux			@; R0 = string aux
	mov r1, #6					@; R1 = 5 + CENTINELA
	bl _gs_num2str_dec			
	
	ldr r0, =_gt_aux			@; R0 = string aux
	mov r2, r6					@; R2 = _gt_mapbgKB
	add r2, #39					@; Nos posicionamos en <PID 00000>
	
	mov r1, #0					
.LPutPID:
	ldrb r4, [r0, r1]			
	cmp r4, #32
	subne r4, #32
	subeq r4, #16
	mov r3, r1, lsl #1
	strh r4, [r2, r3]
	add r1, #1
	cmp r1, #5					
	blo .LPutPID 				

	pop {r0-r7, pc}
	
	.global _gt_bgPutChar
	@; Setea el carácter ASCII a baldosa en pantalla.
	@;Parámetros:
	@; R0: carácter ASCII
	@; R2: posición
_gt_bgPutChar:
	push {r0-r2, lr}
	
	ldr r1, =_gt_mapbgKB
	ldr r1, [r1]

	mov r2, r2, lsl #1
	
	add r1, r2						@; Sumar la posición actual de la string a base mapa.
	add r1, #INPUT_SITE				@; Sumar la línea donde se ubica la string.
	
	sub r0, #32
	strh r0, [r1]
	
	pop {r0-r2, pc}

	.global _gt_bgPutCursor
	@; Setea el cursor a baldosa en pantalla.
	@;Parámetros:
	@; R2: cursor anterior
	@; R3: cursor nuevo
_gt_bgPutCursor:
	push {r0-r3, lr}

	ldr r0, =_gt_mapbgCursorKB
	ldr r0, [r0]
	
	mov r2, r2, lsl #1				@; Baldosas (halfwords)
	mov r3, r3, lsl #1
	
	add r2, #INPUT_SITE
	add r3, #INPUT_SITE
	
	mov r1, #0						@; Espacio en cursor antiguo
	strh r1, [r0, r2]
	
	mov r1,	#97						@; Seteamos cursor nuevo
	strh r1, [r0, r3]		

	pop {r0-r3, pc}

	.global _gt_resetKB
	@; Rutina que resetea las variables de teclado.
_gt_resetKB:
	push {r0-r3, lr}
	
	ldr r1, = _gt_str_input

	mov r2, #0						@; Contador
.LResetString:
	mov r0, #200
	strb r0, [r1, r2]				@; Seteamos string a default (200)
	
	mov r0, #32						@; 32 = ASCII espacio
	
	cmp r2, #31						@; Vaciamos todas las baldosas menos límites.
	subeq r3, r2, #31
	movne r3, r2
	
	cmp r3, #0
	blne _gt_bgPutChar				@; Baldosas todas vacías
	
	add r2, #1
	cmp r2, #32
	blo .LResetString			

	mov r2, #0
.LResetCursor:
	mov r0, #32						@; 32 = ASCII espacio
	
	mov r3, #1						@; Cursor nuevo
	bl _gt_bgPutCursor
	
	add r2, #1
	cmp r2, #31
	blo .LResetCursor			
	
	ldr r0, =_gt_curr_pos			@; Cursor a 0
	mov r1, #1
	str r1, [r0]
	
	bl _gt_bgcolors_reset
	bl _gt_setcapsKB	
	
	pop {r0-r3, pc}
	
	.global _gt_putASCII
	@; Rutina de soporte para poner los carácteres ASCII según el tipo teclado.
	@;Parámetros:
	@; R0: nuevo ASCII
_gt_putASCII:
	push {r0-r4, lr}
	
	ldr r1, =_gt_str_input
	ldr r2, =_gt_curr_pos
	ldr r2, [r2]
	
	ldr r3, =_gt_typeKB
	ldr r3, [r3]
	cmp r3, #0
	beq .LFiputASCII
	
.LFiputASCII:
	strb r0, [r1, r2]
	bl _gt_bgPutChar
	
	pop {r0-r4, pc}
	
	.global _gt_rsi_IPC_FIFO
_gt_rsi_IPC_FIFO:
	push {r0-r5, lr}
	
	mov r0, #0x04100000
	ldr r1, [r0] @; R1 = contenido registro IPC_FIFO_RECV

	mov r5, r1		@; R5 = Copia IPC_FIFO_RECV
	bl _gt_setcapsKB

	mov r0, r5
	mov r1, r5
	cmp r1, #0
	beq .Lfin_rsi_IPC_FIFO @; Pulsacion NO valida.
	
	cmp r1, #1
	beq .LFIFO_RIGHT
	
	cmp r1, #2
	beq .LFIFO_LEFT
	
	cmp r1, #3
	beq .LFIFO_SELECT
	
	cmp r1, #4
	beq .LFIFO_INTRO
	
	cmp r1, #5
	beq .LFIFO_SPACE
	
	cmp r1, #6
	beq .LFIFO_CAPS
	
	mov r4, r1

	@; Si no es ningun caso especial, ponemos letra.
.LFIFO_CHARS:
	ldr r0, =_gt_typeKB
	ldr r0, [r0]		@; R0 = kbtype
	ldr r1, =_gt_curr_pos
	ldr r1, [r1]		@; R1 = position
	mov r2, r4			@; R2 = ascii
	
	bl _gt_kb_check_type
	cmp r0, #0
	beq .Lfin_rsi_IPC_FIFO
	
	ldr r0, =_gt_curr_pos
	ldr r1, [r0]
	
	ldr r3, =_gt_str_lenght
	ldr r3, [r3]
	
	sub r1, #1
	cmp r1, r3					@; Comprobamos límite derecho
	beq .Lfin_rsi_IPC_FIFO

	mov r0, r4
	bl _gt_putASCII 
	
	ldr r0, =_gt_str_lenght		@; Comprobamos que pueda haber siguiente letra.
	ldr r0, [r0]
	add r0, #1
	
	add r1, #2
	cmp r1, r0
	beq .Lfin_rsi_IPC_FIFO
	
	ldr r0, =_gt_curr_pos
	ldr r1, [r0]
	
	mov r2, r1					@; Cursor antiguo
	add r1, #1					@; Desplazar una posición a la izquierda
	str r1, [r0]				@; (2 bytes: halfword)
	
	mov r3, r1					@; Cursor nuevo
	bl _gt_bgPutCursor
	
	ldr r0, =_gt_curr_pos
	ldr r0, [r0]

	bl _gt_bgcolors_put
	
	b .Lfin_rsi_IPC_FIFO
	
.LFIFO_RIGHT:
	bl _gt_highlightKB
	
	ldr r0, =_gt_curr_pos
	ldr r1, [r0]
	
	ldr r3, =_gt_str_lenght
	ldr r3, [r3]
	
	cmp r1, r3					@; Comprobamos límite derecho
	bhs .Lfin_rsi_IPC_FIFO

	mov r2, r1					@; Cursor antiguo
	add r1, #1					@; Desplazar una posición a la derecha
	str r1, [r0]				
	
	mov r3, r1					@; Cursor nuevo
	bl _gt_bgPutCursor
	
	ldr r0, =_gt_curr_pos
	ldr r0, [r0]

	bl _gt_bgcolors_put
	
	b .Lfin_rsi_IPC_FIFO

.LFIFO_LEFT:
	bl _gt_highlightKB

	ldr r0, =_gt_curr_pos
	ldr r1, [r0]
	
	cmp r1, #LIM_LEFT			@; Comprobamos límite izquierdo
	beq .Lfin_rsi_IPC_FIFO

	mov r2, r1					@; Cursor antiguo
	sub r1, #1					@; Desplazar una posición a la izquierda
	str r1, [r0]				@; (2 bytes: halfword)
	
	mov r3, r1					@; Cursor nuevo
	bl _gt_bgPutCursor
	
	ldr r0, =_gt_curr_pos
	ldr r0, [r0]

	bl _gt_bgcolors_put
	
	b .Lfin_rsi_IPC_FIFO

.LFIFO_SELECT:
	bl _gt_highlightKB

	ldr r1, =_gt_str_input
	ldr r2, =_gt_curr_pos 
	ldr r2, [r2]
	
.LFIFO_SELFor:
	add r2, #1
	ldrb r0, [r1, r2]			@; _gt_str_input[i] = _gt_str_input[i+1]
	sub r2, #1
	strb r0, [r1, r2]
	
	cmp r0, #200				@; Si es valor 200 = espacio.
	moveq r0, #32
	bl _gt_bgPutChar
	
	add r2, #1
	cmp r2, #LIM_RIGHT					
	bls .LFIFO_SELFor

	b .Lfin_rsi_IPC_FIFO

.LFIFO_INTRO:
	bl _gt_highlightKB

	bl _gp_inhibirIRQs

	ldr r3, =_gd_kbwait
	ldrb r3, [r3]
	ldr r0, =_gd_nReady
	ldr r1, [r0]
	ldr r2, =_gd_qReady
	strb r3, [r2,r1]
	add r1, #1
	str r1, [r0]
	
	bl _gt_kbwaitRemove
	bl _gp_desinhibirIRQs

	b .Lfin_rsi_IPC_FIFO

.LFIFO_SPACE:
	bl _gt_highlightKB

	@;ldr r2, =_gt_curr_pos 
	@;ldr r2, [r2]
	
	@;mov r0, #32
	@;bl _gt_bgPutChar
	
	ldr r1, =_gt_str_input
	ldr r2, =_gt_curr_pos 
	ldr r2, [r2]
	ldr r3, =_gt_str_lenght
	ldr r3, [r3]
	
	ldrb r4, [r1, r2]			@; _gt_str_input[i] = _gt_str_input[i-1]
	mov r5, r4
	
	mov r0, #32
	strb r0, [r1, r2]
	bl _gt_bgPutChar
	
	mov r0, r5
	add r2, #1
.LFIFO_SPACEFor:
	ldrb r4, [r1, r2]			@; _gt_str_input[i] = _gt_str_input[i-1]

	strb r0, [r1, r2]
	cmp r0, #200				@; Si es valor 200 = espacio.
	moveq r0, #32
	bl _gt_bgPutChar
	
	add r2, #1
	
	mov r0, r4

	cmp r2, r3					
	bls .LFIFO_SPACEFor
	
	b .Lfin_rsi_IPC_FIFO
	
.LFIFO_CAPS:
	ldr r0, =_gt_capsKB
	ldr r1, [r0]
	cmp r1, #1
	moveq r1, #0
	movne r1, #1
	str r1, [r0]	
	bl _gt_setcapsKB

	b .Lfin_rsi_IPC_FIFO

.Lfin_rsi_IPC_FIFO:


	pop {r0-r5, pc}

	.global _gt_rsi_KEYS_XY
_gt_rsi_KEYS_XY:
	push {r0-r1, lr}
	ldr r0, =0x04000180 		@; R0 = registro IPC_SYNC
	ldr r0, [r0]				
	and r0, r0, #0x3			@; Cogemos bit X y bit Y
	
	ldr r1, =_gt_xybuttons		
	strb r0, [r1]				
	pop {r0-r1, pc}
	
.end

