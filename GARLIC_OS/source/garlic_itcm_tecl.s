@;==============================================================================
@;
@;	"garlic_itcm_tecl.s": cÃ³digo de las rutinas relativas a la gestiÃ³n de teclado.
@; 
@;==============================================================================

.include "../include/garlic_tecl_incl.i"

.section .itcm,"ax",%progbits

	.arm
	.align 2

	.global _gt_getstring
	@; Rutina que recibe por parÃ¡metro la direcciÃ³n de un vector de caracteres
	@; donde guardar el string introducido por teclado, asÃ­ como el nÃºmero
	@; mÃ¡ximo de caracteres que puede contener el vector (excluido el
	@; centinela), y devuelve como resultado el nÃºmero de caracteres leÃ­dos
	@; finalmente (excluido el centinela)
	@;ParÃ¡metros:
	@; R0: string -> direcciÃ³n base del vector de caracteres (bytes)
	@; R1: max_char -> nÃºmero mÃ¡ximo de caracteres del vector
	@; R2: zocalo -> nÃºmero de zÃ³calo del proceso invocador
	@;Return
	@; R0: lenght string
_gt_getstring:
	push {r1-r5, lr}
	
	push {r0}
	bl _gt_kbwaitAdd				@; AÃ±adimos el proceso para solicitar teclado.

.LWaitForStartKB:
	push {r0-r12}
	bl _gp_WaitForVBlank			@; Retroceso vertical para aliviar CPU
	pop {r0-r12}
		
	ldr r3, =_gt_activeKB			@; Comprobamos si el teclado estÃ¡ activo
	ldr r3, [r3]
	
	cmp r3, #1						@; Si esta activo, esperar.
	beq .LWaitForStartKB

	ldr r3, =_gd_kbwait				@; Comprobar si el propio proceso es el
	ldrb r3, [r3]					@; primero de la cola.
	
	cmp r3, r2
	bne .LWaitForStartKB
	
.LShowKB:
	ldr r3, =_gt_str_lenght
	cmp r1, #LIM_RIGHT
	movhi r1, #LIM_RIGHT
	str r1, [r3]
	
	push {r0-r2}
	ldr r1, =_gt_typeKB				@; Teclado tipo string
	mov r2, #0
	str r2, [r1]

	bl _gt_showKB 					
	bl _gt_putPIDZ 				
	pop {r0-r2}
	
	mov r5, #1
	mov r5, r5, lsl r2
.LWaitForFinishKB:
	push {r0-r12}
	bl _gp_WaitForVBlank			@; Retroceso vertical para aliviar CPU
	pop {r0-r12}
	
	ldr r3, =_gd_kbsignal			@; Comprobamos si el teclado ha acabado
	ldr r4, [r3]
	
	tst r4, r5						@; Si bit zÃ³calo activo (AND), espera.
	beq .LWaitForFinishKB
	
	mov r4, #0						@; Desactivamos el bit del zÃ³calo
	str r4, [r3]					@; Solo debe haber 1 bit, asÃ­ que todo a 0
	
	bl _gt_hideKB
	bl _gt_kbwaitRemove
	pop {r0}

	bl _gt_cpy_str
	bl _gt_resetKB
	
	pop {r1-r5, pc}

	.global _gt_kbwaitAdd
	@; FunciÃ³n auxiliar para aÃ±adir zÃ³calo a la cola de espera de teclado.
	@;ParÃ¡metros
	@; R2 = zÃ³calo
_gt_kbwaitAdd:
	push {r0-r3, lr}
	
	ldr r0, =_gd_kbwait
	ldr r1, =_gd_num_kbwait
	
	ldr r3, [r1]
	strb r2, [r0, r3]				@; AÃ±adimos el nÃºmero de zÃ³calo a la cola.
	
	add r3, #1						@; AÃ±adimos +1 a num procesos espera.
	str r3, [r1]
	
	pop {r0-r3, pc}
	
	.global _gt_kbwaitRemove
	@; FunciÃ³n auxiliar para quitar zÃ³calo a la cola de espera de teclado.
_gt_kbwaitRemove:
	push {r0-r4, lr}
	
	ldr r0, =_gd_kbwait
	ldr r1, =_gd_num_kbwait
	ldr r2, [r1]
	
	sub r2, #1						@; Restamos -1 a num procesos espera.
	str r2, [r1]
	
	mov r3, #0					@; Contador
.LMoverCola:
	add r3, #1					
	ldrb r4, [r0, r3]				
	sub r3, #1					
	strb r4, [r0, r3]			@; _gd_kbwait[i] = _gd_kbwait[i+1]
	add r3, #1				
	cmp r2, r3					@; Si R2 (numKBWait) > R3 (Ã­ndex) itera
	bhi .LMoverCola			
	
	pop {r0-r4, pc}

	.global _gt_cpy_str
	@; FunciÃ³n auxiliar que copia string auxiliar a string de return.
	@;ParÃ¡metros
	@; R0 = direcciÃ³n string
	@;Return
	@; R0 = lenght string
_gt_cpy_str:
	push {r1-r4, lr}
	
	ldr r1, = _gt_str_input
	
	mov r2, #0						@; Contador
	mov r4,	#0						@; Lenght total
.LForLenght:
	ldrb r3, [r1, r2]				@; Iteramos sobre la string	
	
	cmp r3, #200					@; Contar Ãºltimo carÃ¡cter Ãºtil.
	movne r4, r2 
	
	add r2, #1
	cmp r2, #32
	bne .LForLenght	
	
	add r4, #1
	mov r2, #0						@; Contador
.LForStr:
	ldrb r3, [r1, r2]				@; Iteramos sobre la string	
	strb r3, [r0, r2]				@; Copiamos ASCII en direcciÃ³n string

	add r2, #1
	cmp r2, r4						@; If index < lenght: itera
	blo .LForStr

.LAddCentinela:
	mov r3, #0
	strb r3, [r0, r2]				@; AÃ±adimos centinela al final de string.
	
	cmp r4, #0						
	subne r4, #1
	mov r0, r4						@; R0 = lenght string.
	pop {r1-r4, pc}

	.global _gt_cpy_num
	@; FunciÃ³n auxiliar que pasa de string ASCII a num.
	@;Return
	@; R0 = lenght string
_gt_cpy_num:
	push {r1-r7, lr}
		
	ldr r1, =_gt_str_input
	ldr r5, =_gt_str_lenght
	ldr r5, [r5]
	
	mov r2, #0						@; Contador
	mov r4,	#0						@; Lenght total
.LForLenght2:
	ldrb r3, [r1, r2]				@; Iteramos sobre la string	
	
	cmp r3, #200					@; Contar Ãºltimo carÃ¡cter Ãºtil.
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
	
.LFiGetNum:
	cmp r5, #0
	moveq r0, #0
	movne r0, r5						@; R0 = lenght string.
	
	mov r0, r5
	pop {r1-r7, pc}

	.global _gt_putPIDZ
	@; FunciÃ³n auxiliar que escribe en la interfaz de teclado el nÃºmero de 
	@; zÃ³calo y el PID.
_gt_putPIDZ:
	push {r0-r7,lr}
	
	ldr r0, =_gd_pidz			@; Cargamos los valores de zÃ³calo y PID
	ldr r4, [r0]				@; R0 = PID + zÃ³calo
	ldr r3, =0x3				@; FASE 1: ZÃ“CALO MOD 4 
	and r1, r4, r3				@; R1 = nÃºmero zÃ³calo
								@; R12 = PID
	mov r7, r4, lsr #4			@; Desplazamos los 28 bits a la derecha.
	
	@; _gs_num2str_dec: R0 = string, R1 = MAXELEMS, R2 = ZÃ“CALO
	ldr r0, =_gt_aux			@; R0 = string aux
	mov r2, r1					@; R2 = socol		
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
	subne r4, #32				@; Si es num 0-9 pasamos a codificaciÃ³n baldosas.
	subeq r4, #16				@; Si es espacio (32) menos 16 para obtener un 0.
	mov r3, r1, lsl #1			
	strh r4, [r2, r3]			
	add r1, #1					
	cmp r1, #3					
	blo .LPutZoc 
	
	@; _gs_num2str_dec: R0 = string, R1 = MAXELEMS, R2 = ZÃ“CALO
	ldr r0, =_gt_aux			@; R0 = string aux
	mov r1, #6					@; R1 = 5 + CENTINELA
	mov r2, r7					@; R2 = PID
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
	@; Setea el carÃ¡cter ASCII a baldosa en pantalla.
	@;ParÃ¡metros:
	@; R0: carÃ¡cter ASCII
	@; R2: posiciÃ³n
_gt_bgPutChar:
	push {r0-r2, lr}
	
	ldr r1, =_gt_mapbgKB
	ldr r1, [r1]

	mov r2, r2, lsl #1
	
	add r1, r2						@; Sumar la posiciÃ³n actual de la string a base mapa.
	add r1, #INPUT_SITE				@; Sumar la lÃ­nea donde se ubica la string.
	
	sub r0, #32
	strh r0, [r1]
	
	pop {r0-r2, pc}

.global _gt_bgPutCursor
	@; Setea el cursor a baldosa en pantalla.
	@;ParÃ¡metros:
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
	
	.global _gt_mod_freq_timer
	@; Rutina para acelerar la pulsaciÃ³n de teclas A/B
_gt_mod_freq_timer:
	push {r0-r3, lr}
	
	ldr r1, =_gt_curr_key
	ldr r2, [r1]
	str r0, [r1]
	
	ldr r1, =_gt_curr_key_tics
	ldr r3, [r1]
	
	cmp r2, r0				@; Comparo la letra anterior con la actual
	blne _gt_reset_timer
	ldreq r0, =2500
	
	movne r3, #0			@; Si no son iguales reiniciamos _gt_curr_key_tics
	strne r3, [r1] 
	
	cmp r3, #2				@; Cambiamos freq cada 2 tics de tecla repetida.
	addle r3, #1
	strle r3, [r1]
	ble .LFiFreq
	
	mov r3, #0
	str r3, [r1]
	
	b .Lactualizar_divisor
	
.Lactualizar_divisor:
	ldr r1, =divFreq0
	rsb r0, r0, #0			@; volver a negar el valor del divisor de frecuencia
	strh r0, [r1]			@; actualizar variable global
	ldr r1, =0x04000100		@; R1 apunta al registro de datos del timer 0
	strh r0, [r1]			@; escribir divisor en registro

.LFiFreq:
	pop {r0-r3, pc}

	.global _gt_resetKB
	@; Rutina que resetea las variables de teclado.
_gt_resetKB:
	push {r0-r2, lr}
	
	ldr r1, = _gt_str_input

	mov r2, #0						@; Contador
.LResetString:
	mov r0, #200
	strb r0, [r1, r2]				@; Seteamos string a default (200)
	
	mov r0, #32						@; 32 = ASCII espacio
	
	cmp r2, #31						@; Vaciamos todas las baldosas menos lÃ­mites.
	subeq r3, r2, #31
	movne r3, r2
	
	cmp r3, #0
	blne _gt_bgPutChar				@; Baldosas todas vacÃ­as
	
	add r2, #1
	cmp r2, #32
	blo .LResetString			

.LResetCursor:
	ldr r0, =_gt_curr_pos			@; Cursor a 0
	ldr r2, [r0]					@; Cursor antiguo
	mov r1, #1
	str r1, [r0]
	
	mov r3, r1						@; Cursor nuevo
	bl _gt_bgPutCursor
	
	pop {r0-r2, pc}
	
	.global _gt_reset_timer
	@; Rutina que resetea la frecuencia del timer a la original.
_gt_reset_timer:
	push {r0-r1, lr}
	
	ldr r1, =divFreq0
	ldr r0, =20000 
	rsb r0, r0, #0			@; volver a negar el valor del divisor de frecuencia
	strh r0, [r1]			@; actualizar variable global
	ldr r1, =0x04000100		@; R1 apunta al registro de datos del timer 0
	strh r0, [r1]			@; escribir divisor en registro	

	pop {r0-r1, pc}
	
	.global _gt_timerKB
	@; Rutina que se ejecutarÃ¡ cuando haya una interrupciÃ³n IRQ_TIMER0.
_gt_timerKB:
	push {r0-r1, lr}
	
	ldr r0,=_gt_count_timer
	ldr r1, [r0]
	add r1, #1
	str r1, [r0]
		
	pop {r0-r1, pc}
	
	.global _gt_moveASCII
	@; Rutina de soporte para rotar los carÃ¡cteres ASCII segÃºn el tipo teclado.
	@;ParÃ¡metros:
	@; R4: A/B (0/1)
	@;Return:
	@; R0: nuevo ASCII
_gt_moveASCII:
	push {r0-r4, lr}
	
	ldr r1, =_gt_str_input
	ldr r2, =_gt_curr_pos
	ldr r2, [r2]
	ldrb r0, [r1, r2]				@; Cargar ASCII de la posiciÃ³n
	
	ldr r3, =_gt_typeKB
	ldr r3, [r3]
	cmp r3, #0
	beq .LKey_Str
	
	cmp r3, #1
	beq .LKey_Dec
	
	cmp r3, #2
	beq .LKey_Hexa
	
.LKey_Str:
	cmp r4, #1			
	beq .LKey_BStr
	
.LKey_AStr:
	cmp r0, #200
	moveq r0, #65					@; Primera letra 'A'
	beq .LFiASCII
	
	cmp r0, #127					@; Comprobar lÃ­mites ASCII: 32-127
	moveq r0, #32
	addne r0, #1					@; Sumar 1 al cÃ³digo ascii
	b .LFiASCII

.LKey_BStr:
	cmp r0, #200
	moveq r0, #65					@; Primera letra 'A'
	beq .LFiASCII
	
	cmp r0, #32						@; Comprobar lÃ­mites ASCII: 32-127
	moveq r0, #127
	subne r0, #1					@; Restar 1 al cÃ³digo ascii
	b .LFiASCII

.LKey_Dec:
	cmp r4, #1			
	beq .LKey_BDec
	
.LKey_ADec:
	cmp r2, #LIM_LEFT
	bne .LKey_ADecCont
	
	cmp r0, #45
	moveq r4, #32
	
	cmp r0, #32
	moveq r4, #45
	
	cmp r0, #200
	moveq r4, #45					@; Primera num '0'
	
	mov r0, r4
	
	b .LFiASCII
	
.LKey_ADecCont:
	cmp r0, #200
	moveq r0, #48					@; Primera num '0'
	beq .LFiASCII
	
	cmp r0, #57						@; Comprobar lÃ­mites ASCII num: 48-57
	moveq r0, #48
	addne r0, #1					@; Sumar 1 al cÃ³digo ascii
	b .LFiASCII

.LKey_BDec:
	cmp r2, #LIM_LEFT
	bne .LKey_BDecCont
	
	cmp r0, #45
	moveq r4, #32
	
	cmp r0, #32
	moveq r4, #45
	
	cmp r0, #200
	moveq r4, #45					@; Primera num '0'
	
	mov r0, r4
	
	b .LFiASCII
	
.LKey_BDecCont:
	cmp r0, #200
	moveq r0, #48					@; Primera num '0'
	beq .LFiASCII
	
	cmp r0, #48						@; Comprobar lÃ­mites ASCII: 32-127
	moveq r0, #57
	subne r0, #1					@; Restar 1 al cÃ³digo ascii
	b .LFiASCII
	
.LKey_Hexa:
	cmp r4, #1			
	beq .LKey_BHexa
	
.LKey_AHexa:
	cmp r0, #200
	moveq r0, #48					@; Primera num '0'
	beq .LFiASCII
	
	cmp r0, #57						@; Comprobar lÃ­mites ASCII hex: 48-57+65-70
	moveq r0, #65
	beq .LFiASCII
	
	cmp r0, #70
	moveq r0, #48
	addne r0, #1
	
	b .LFiASCII
	
.LKey_BHexa:
	cmp r0, #200
	moveq r0, #48					@; Primera num '0'
	beq .LFiASCII
	
	cmp r0, #65						@; Comprobar lÃ­mites ASCII hex: 48-57+65-70
	moveq r0, #57
	beq .LFiASCII
	
	cmp r0, #48
	moveq r0, #70
	subne r0, #1
	
	b .LFiASCII
	
.LFiASCII:
	strb r0, [r1, r2]
	bl _gt_bgPutChar
	
	pop {r0-r4, pc}
	
	.global _gt_rsiKB
	@; Rutina que se ejecutarÃ¡ cuando haya una interrupciÃ³n IRQ_KEYS.
	@; El objetivo es captar las teclas y almacenarlas en una string.
_gt_rsiKB:
	push {r0-r5, lr}
	
	ldr r0, =_gt_count_timer	@; Sincro con TIMER0: velocidad humana.
	ldr r1, [r0]
	cmp r1, #2
	blo .Lfin_rsi_KB
	mov r1, #0
	strb r1, [r0]

	ldr r0, =0x04000130			@; REG_KEYINPUT (sÃ³lo lectura)
	ldrh r0, [r0]				@; R0 = valor de las teclas pulsadas
	mvn r0, r0					@; invertir bits (0 -> 1, indica botÃ³n pulsado)
	
	@; COMPROBAR SI ALGUNA TECLA PULSADA (si FlagZ = 0)
	tst r0, #0x003F				@; comprobar si pulsados KEY_A, KEY_B, KEY_LEFT, 
	beq .Lfin_rsi_KB			@; KEY_RIGHT, KEY_SELECT o KEY_START
	
	@; TRATAMIENTO DE TECLAS ESPECÃFICO
	@; INCREMENTAR CODIGO ASCII DE POSICIÃ“N ACTUAL
	tst r0, #0x0001				@; test con KEY_A
	blne _gt_mod_freq_timer
	bne .LKey_A	
	
	tst r0, #0x0002				@; test con KEY_B
	blne _gt_mod_freq_timer
	bne .LKey_B
	
	@; MOVER POSICIÃ“N DE LA STRING
	tst r0, #0x0010				@; test con KEY_RIGHT
	bne .LKey_RIGHT
	tst r0, #0x0020				@; test con KEY_LEFT
	bne .LKey_LEFT
	
	@; BORRAR LA POSICIÃ“N DE LA STRING ACTUAL Y DESPLAZAR LA STRING 
	tst r0, #0x0004				@; test con KEY_SELECT
	bne .LKey_SELECT
	
	@; Termina la string (aÃ±adir centinela)
	tst r0, #0x0008				@; test con KEY_START
	bne .LKey_START
	
	b .Lfin_rsi_KB
	
.LKey_A:
	mov r4, #0
	bl _gt_moveASCII
	b .Lfin_rsi_KB

.LKey_B:
	mov r4, #1
	bl _gt_moveASCII
	b .Lfin_rsi_KB
	
.LKey_RIGHT:
	bl _gt_reset_timer
	
	ldr r0, =_gt_curr_pos
	ldr r1, [r0]
	
	ldr r3, =_gt_str_lenght
	ldr r3, [r3]
	
	cmp r1, r3					@; Comprobamos lÃ­mite derecho
	beq .Lfin_rsi_KB

	mov r2, r1					@; Cursor antiguo
	add r1, #1					@; Desplazar una posiciÃ³n a la derecha
	str r1, [r0]				
		
	mov r3, r1					@; Cursor nuevo
	bl _gt_bgPutCursor
	
	b .Lfin_rsi_KB
	
.LKey_LEFT:
	bl _gt_reset_timer

	ldr r0, =_gt_curr_pos
	ldr r1, [r0]
	
	cmp r1, #LIM_LEFT			@; Comprobamos lÃ­mite izquierdo
	beq .Lfin_rsi_KB

	mov r2, r1					@; Cursor antiguo
	sub r1, #1					@; Desplazar una posiciÃ³n a la izquierda
	str r1, [r0]				@; (2 bytes: halfword)
	
	mov r3, r1					@; Cursor nuevo
	bl _gt_bgPutCursor
	
	b .Lfin_rsi_KB

.LKey_SELECT:
	bl _gt_reset_timer

	ldr r1, =_gt_str_input
	ldr r2, =_gt_curr_pos 
	ldr r2, [r2]
	
.LKey_SELFor:
	add r2, #1
	ldrb r0, [r1, r2]			@; _gt_str_input[i] = _gt_str_input[i+1]
	sub r2, #1
	strb r0, [r1, r2]
	
	cmp r0, #200				@; Si es valor 200 = espacio.
	moveq r0, #32
	bl _gt_bgPutChar
	
	add r2, #1
	cmp r2, #LIM_RIGHT					
	bls .LKey_SELFor

	b .Lfin_rsi_KB
	
.LKey_START:
	bl _gt_reset_timer

	ldr r0, =_gd_kbwait				
	ldrb r0, [r0]					@; Cargamos num zÃ³calo actual
	ldr r1, =_gd_kbsignal			
	
	mov r5, #1
	mov r5, r5, lsl r0				@; Activamos el bit kbsignal del zÃ³calo
	str r5, [r1] 

.Lfin_rsi_KB:
    pop {r0-r5, pc}

	.global _gt_getnumber
	@; FunciÃ³n que recibe por parÃ¡metro el type 'x' o 'd', segÃºn se desee 
	@; interpretar el nÃºmero introducido por el usuario como valor hexadecimal 
	@; o decimal, respectivamente, o en caso de escoger 'd', se admitirÃ¡ un 
	@; signo menos delante del nÃºmero, o el usuario solo podrÃ¡ teclear dÃ­gitos 
	@; del subconjunto correspondiente, Ã©s decir, o bien dÃ­gitos hexa o bien 
	@; dÃ­gitos decimales mÃ¡s el sÃ­mbolo de menos '-', y no se permitirÃ¡ al 
	@; usuario rebasar el rango de los nÃºmeros de 32 bits.
	@;ParÃ¡metros:
	@; R0: type -> tipo de dato 'x' o 'd'
	@; R2: zocalo -> nÃºmero de zÃ³calo del proceso invocador
	@;Return
	@; R0: lenght string
_gt_getnumber:
	push {r1-r7, lr}
	
	@; Proceso de sincronizaciÃ³n igual a getstring.
	push {r0}
	bl _gt_kbwaitAdd				@; AÃ±adimos el proceso para solicitar teclado.

.LWaitForStartKB2:
	bl _gp_WaitForVBlank			@; Retroceso vertical para aliviar CPU
	
	ldr r3, =_gt_activeKB			@; Comprobamos si el teclado estÃ¡ activo
	ldr r3, [r3]
	
	cmp r3, #1						@; Si esta activo, esperar.
	beq .LWaitForStartKB2

	ldr r3, =_gd_kbwait				@; Comprobar si el propio proceso es el
	ldrb r3, [r3]					@; primero de la cola.
	
	cmp r3, r2
	bne .LWaitForStartKB2
	
.LShowKB2:	
	push {r0-r2}
	ldr r3, =_gt_str_lenght
	ldr r1, =_gt_typeKB				@; 'd': teclado decimal
	cmp r0, #'d'					@; 'x': teclado hexa
	moveq r0, #1
	streq r0, [r1]
	moveq r0, #11					@; LÃMITE 32 BITS 
	streq r0, [r3]

	cmp r0, #'x'
	moveq r0, #2
	streq r0, [r1]
	moveq r0, #8					@; LÃMITE 32 BITS 
	streq r0, [r3]
	
	bl _gt_showKB 					
	bl _gt_putPIDZ 				
	pop {r0-r2}
	
	mov r5, #1
	mov r5, r5, lsl r2
.LWaitForFinishKB2:
	bl _gp_WaitForVBlank			@; Retroceso vertical para aliviar CPU
	
	ldr r3, =_gd_kbsignal			@; Comprobamos si el teclado ha acabado
	ldr r4, [r3]
	
	tst r4, r5						@; Si bit zÃ³calo activo (AND), espera.
	beq .LWaitForFinishKB2
	
	mov r4, #0						@; Desactivamos el bit del zÃ³calo
	str r4, [r3]					@; Solo debe haber 1 bit, asÃ­ que todo a 0
	
	bl _gt_hideKB
	bl _gt_kbwaitRemove
	pop {r0}

	bl _gt_cpy_num
	bl _gt_resetKB
	
	pop {r1-r7, pc}

.end

