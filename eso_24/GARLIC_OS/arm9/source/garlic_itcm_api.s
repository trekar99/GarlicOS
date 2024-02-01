@;==============================================================================
@;
@;	"garlic_itcm_api.s":	código de las rutinas del API de GARLIC 2.0
@;							(ver "GARLIC_API.h" para descripción de las
@;							 funciones correspondientes)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _ga_pid
	@;Resultado:
	@; R0 = identificador del proceso actual
_ga_pid:
	push {r1, lr}
	ldr r0, =_gd_pidz
	ldr r1, [r0]			@; R1 = valor actual de PID + zócalo
	mov r0, r1, lsr #0x4	@; R0 = PID del proceso actual
	pop {r1, pc}


	.global _ga_random
	@;Resultado:
	@; R0 = valor aleatorio de 32 bits
_ga_random:
	push {r1-r5, lr}
	ldr r0, =_gd_seed
	ldr r1, [r0]			@; R1 = valor de semilla de números aleatorios
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2	@; R5:R4 = _gd_seed * 0x19660D
	add r4, r3				@; R4 += 0x3C6EF35F
	str r4, [r0]			@; guarda la nueva semilla (R4)
	mov r0, r5				@; devuelve por R0 el valor aleatorio (R5)
	pop {r1-r5, pc}


	.global _ga_divmod
	@;Parámetros
	@; R0: unsigned int num,
	@; R1: unsigned int den,
	@; R2: unsigned int * quo,
	@; R3: unsigned int * mod
	@;Resultado
	@; R0: 0 si no hay problema, !=0 si hay error en la división
_ga_divmod:
	push {r4-r7, lr}
	cmp r1, #0				@; verificar si se está intentando dividir por cero
	bne .Ldiv_ini
	mov r0, #1				@; código de error
	b .Ldiv_fin2
.Ldiv_ini:
	mov r4, #0				@; R4 es el cociente (q)
	mov r5, #0				@; R5 es el resto (r)
	mov r6, #31				@; R6 es índice del bucle (de 31 a 0)
	mov r7, #0xff000000
.Ldiv_for1:
	tst r0, r7				@; comprobar si hay bits activos en una zona de 8
	bne .Ldiv_for2			@; bits del numerador, para evitar el rastreo bit a bit
	mov r7, r7, lsr #8
	sub r6, #8				@; 8 bits menos a buscar
	cmp r7, #0
	bne .Ldiv_for1
	b .Ldiv_fin1			@; caso especial (numerador = 0 -> q=0 y r=0)
.Ldiv_for2:
	mov r7, r0, lsr r6		@; R7 es variable de trabajo j;
	and r7, #1				@; j = bit i-ésimo del numerador; 
	mov r5, r5, lsl #1		@; r = r << 1;
	orr r5, r7				@; r = r | j;
	mov r4, r4, lsl #1		@; q = q << 1;
	cmp r5, r1
	blo .Ldiv_cont			@; si (r >= divisor), activar bit en cociente
	sub r5, r1				@; r = r - divisor;
	orr r4, #1				@; q = q | 1;
 .Ldiv_cont:
	sub r6, #1				@; decrementar índice del bucle
	cmp r6, #0
	bge .Ldiv_for2			@; bucle for-2, mientras i >= 0
.Ldiv_fin1:
	str r4, [r2]
	str r5, [r3]			@; guardar resultados en memoria (por referencia)
	mov r0, #0				@; código de OK
.Ldiv_fin2:
	pop {r4-r7, pc}


	.global _ga_divmodL
	@;Parámetros
	@; R0: long long * num,
	@; R1: unsigned int * den,
	@; R2: long long * quo,
	@; R3: unsigned int * mod
	@;Resultado
	@; R0: 0 si no hay problema, !=0 si hay error en la división
_ga_divmodL:
	push {r4-r6, lr}
	ldr r4, [r1]			@; R4 = denominador
	cmp r4, #0				@; verificar si se está intentando dividir por cero
	bne .LdivL_ini
	mov r0, #1				@; código de error
	b .LdivL_fin
.LdivL_ini:
	ldrd r0, [r0]			@; R1:R0 = numerador
	mov r5, r2				@; R5 apunta a quo
	mov r6, r3				@; R6 apunta a mod
	mov r2, r4
	mov r3, #0				@; R3:R2 = denominador
	bl __aeabi_ldivmod
	strd r0, [r5]
	str r2, [r6]			@; guardar resultados en memoria (por referencia)			
	mov r0, #0				@; código de OK
.LdivL_fin:
	pop {r4-r6, pc}


	.global _ga_printf
	@;Parámetros
	@; R0: char * format,
	@; R1: unsigned int val1 (opcional),
	@; R2: unsigned int val2 (opcional)
_ga_printf:
	push {r4-r6, lr}
	ldr r4, =_gd_pidz		@; R4 = dirección _gd_pidz
	ldr r3, [r4]
	and r3, #0x3			@; R3 = ventana de salida (zócalo actual MOD 4)
	bl _gg_escribir			@; llamada a la función definida en "garlic_graf.c"
	pop {r4-r6, pc}

	.global _ga_nice
	@;Parámetros
	@; R0: unsigned char n
_ga_nice:
	push {r1-r3, lr}
	cmp r0, #0				@;If value is too low, set to the lowest value possible (0)
	movlo r0, #0
	cmp r0, #3				@;If value is too high, set to the highest value possible (3)
	movgt r0, #3

	mov r1, #4
	sub r0, r1, r0			@;Number of quantums is 4-n
	sub r0, #1				@;Compensate (3 to 0, not 4 to 1)
	
	ldr r1, =_gd_pidz		@;Load PIDZ
	ldr r1, [r1]
	and r1, #0x3			@;Get zocalo number of running process (the one who called this routine)
	ldr r2, =_gd_NiceVector
	ldrb r3, [r2, r1]		@;Get the value of _gd_NiceVector[zocalo]
	and r3, #0x2			@;Get the two lowest bits (remaining ticks)
	
	mov r0, r0, lsl #2		@;Move 2 bits to the left the new nice value
	add r3, r0				@;Get the new value (nice_level+remaining ticks)
	
	strb r3, [r2, r1]		@;Sotre the new value into _gd_NiceVector[zocalo]
	
	pop {r1-r3, pc}

	
	.global _ga_printchar
	@;Par?metros
	@; R0: int vx
	@; R1: int vy
	@; R2: char c
	@; R3: int color
_ga_printchar:
	push {r4, lr}
	add r3, r2, #32			@; R3 = c + 32, se transforma el código de baldosa
							@;	en código ASCII, para que _gg_escribir lo vuelva
							@;	a transformar en código de baldosa; (R3 pierde
							@;	el código de color que se pasa por parámetro,
							@;	pero no importa porque el color no se utiliza)
	mov r2, r1				@; R2 = vy
	mov r1, r0				@; R1 = vx
	ldr r4, =_gd_pidz
	ldr r4, [r4]			@; R4 = _gd_pidz
	ldr r0, =_gi_message	@; R0 = @ string para visualizar con _gg_escribir
	strb r3, [r0, #22]		@; guardar codigo carácter en posición 22 del str.
	and r3, r4, #0x3		@; R3 = número de ventana (num. zócalo % 4)
	bl _gg_escribir
	pop {r4, pc}
	
_gi_message:
	.asciz "print char (%d, %d) :  \n"

	.align 2

	.global _ga_printmat
	@;Par?metros
	@; R0: int vx
	@; R1: int vy
	@; R2: char *m[]
	@; R3: int color
_ga_printmat:
	push {r4-r5, lr}
	ldr r5, =_gd_pidz		@; R5 = direcci?n _gd_pidz
	ldr r4, [r5]
	and r4, #0x3			@; R4 = ventana de salida (zócalo actual)
	push {r4}				@; pasar 4º parámetro (núm. ventana) por la pila	
	bl _gg_escribir
	add sp, #4				@; eliminar 4º parámetro de la pila
	pop {r4-r5, pc}

	.global _ga_delay
	@;Par?metros
	@; R0: int nsec
_ga_delay:
	push {r0, r2-r3, lr}
	ldr r3, =_gd_pidz		@; R3 = direcci?n _gd_pidz
	ldr r2, [r3]
	and r2, #0x3			@; R2 = zócalo actual
	cmp r0, #0
	bhi .Ldelay1
	bl _gp_WaitForVBlank	@; si nsec = 0, solo desbanca el proceso
	b .Ldelay2				@; y salta al final de la rutina
.Ldelay1:
	cmp r0, #600
	movhi r0, #600			@; limitar el número de segundos a 600 (10 minutos)
	@;bl _gp_retardarProc
.Ldelay2:
	pop {r0, r2-r3, pc}



	.global _ga_clear
_ga_clear:
	push {r0-r1, lr}
	ldr r1, =_gd_pidz
	ldr r0, [r1]
	and r0, #0xf			@; R0 = zócalo actual
	mov r1, #1				@; R1 = 0 -> 4 ventanas
	bl _gs_borrarVentana
	pop {r0-r1, pc}
	
	.global _ga_getstring
	@;Parámetros
	@; R0: char * string,
	@; R1: máximo de caracteres
_ga_getstring:
	push {r3, lr}
	ldr r3, =_gd_pidz		@; R4 = dirección _gd_pidz
	ldr r2, [r3]
	and r2, #0xF			@; R3 = ventana de salida (zócalo actual MOD 4)
	bl _gt_getstring		@; llamada a la función definida en "garlic_itcm_tecl.s"
	pop {r3, pc}
	
	.global _ga_getnumber
	@;Parámetros
	@; R0: char type,
_ga_getnumber:
	push {r3, lr}
	ldr r3, =_gd_pidz		@; R4 = dirección _gd_pidz
	ldr r2, [r3]
	and r2, #0xF			@; R3 = ventana de salida (zócalo actual MOD 4)
	bl _gt_getnumber		@; llamada a la función definida en "garlic_itcm_tecl.s"
	pop {r3, pc}
	
	.global _ga_getxybuttons
	@;
	@; Return R0: bit 0 = boton X pulsacion, bit 1 = boton Y pulsacion
_ga_getxybuttons:
	push {r1-r2, lr}
	
	push {r0-r12}
	bl _gt_enable_IPC_SYNC
	pop {r0-r12}
	
	ldr r1, =_gd_pidz		@; R1 = PID + zocalo
	ldr r1, [r1]			
	and r1, #0xF			@; R1 = zocalo
	ldr r0, =_gi_za			@; R0 = _gi_za
	ldr r0, [r0]			
	cmp r0, r1				@; Comprobar num zocalo en foco
	@;movne r0, #0			
	@;bne .Lxybuttonend		@; Devolvemos 0 si no es zocalo en foco.
	
	ldr r0, =_gt_xybuttons	
	ldr r0, [r0]			
.Lxybuttonend:

	pop {r1-r2, pc}
	
.end

