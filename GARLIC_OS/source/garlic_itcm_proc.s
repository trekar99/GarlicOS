@;==============================================================================
@;
@;	"garlic_itcm_proc.s":	código de las funciones de control de procesos (1.0)
@;						(ver "garlic_system.h" para descripción de funciones)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2
	
	.global _gp_WaitForVBlank
	@; rutina para pausar el procesador mientras no se produzca una interrupción
	@; de retrazado vertical (VBL); es un sustituto de la "swi #5", que evita
	@; la necesidad de cambiar a modo supervisor en los procesos GARLIC
_gp_WaitForVBlank:
	push {r0-r1, lr}
	ldr r0, =__irq_flags
.Lwait_espera:
	mcr p15, 0, lr, c7, c0, 4	@; HALT (suspender hasta nueva interrupción)
	ldr r1, [r0]			@; R1 = [__irq_flags]
	tst r1, #1				@; comprobar flag IRQ_VBL
	beq .Lwait_espera		@; repetir bucle mientras no exista IRQ_VBL
	bic r1, #1
	str r1, [r0]			@; poner a cero el flag IRQ_VBL
	pop {r0-r1, pc}


	.global _gp_IntrMain
	@; Manejador principal de interrupciones del sistema Garlic
_gp_IntrMain:
	mov	r12, #0x4000000
	add	r12, r12, #0x208	@; R12 = base registros de control de interrupciones	
	ldr	r2, [r12, #0x08]	@; R2 = REG_IE (máscara de bits con int. permitidas)
	ldr	r1, [r12, #0x0C]	@; R1 = REG_IF (máscara de bits con int. activas)
	and r1, r1, r2			@; filtrar int. activas con int. permitidas
	ldr	r2, =irqTable
.Lintr_find:				@; buscar manejadores de interrupciones específicos
	ldr r0, [r2, #4]		@; R0 = máscara de int. del manejador indexado
	cmp	r0, #0				@; si máscara = cero, fin de vector de manejadores
	beq	.Lintr_setflags		@; (abandonar bucle de búsqueda de manejador)
	ands r0, r0, r1			@; determinar si el manejador indexado atiende a una
	beq	.Lintr_cont1		@; de las interrupciones activas
	ldr	r3, [r2]			@; R3 = dirección de salto del manejador indexado
	cmp	r3, #0
	beq	.Lintr_ret			@; abandonar si dirección = 0
	mov r2, lr				@; guardar dirección de retorno
	blx	r3					@; invocar el manejador indexado
	mov lr, r2				@; recuperar dirección de retorno
	b .Lintr_ret			@; salir del bucle de búsqueda
.Lintr_cont1:	
	add	r2, r2, #8			@; pasar al siguiente índice del vector de
	b	.Lintr_find			@; manejadores de interrupciones específicas
.Lintr_ret:
	mov r1, r0				@; indica qué interrupción se ha servido
.Lintr_setflags:
	str	r1, [r12, #0x0C]	@; REG_IF = R1 (comunica interrupción servida)
	ldr	r0, =__irq_flags	@; R0 = dirección flags IRQ para gestión IntrWait
	ldr	r3, [r0]
	orr	r3, r3, r1			@; activar el flag correspondiente a la interrupción
	str	r3, [r0]			@; servida (todas si no se ha encontrado el maneja-
							@; dor correspondiente)
	mov	pc,lr				@; retornar al gestor de la excepción IRQ de la BIOS


	.global _gp_rsiVBL
	@; Manejador de interrupciones VBL (Vertical BLank) de Garlic:
	@; se encarga de actualizar los tics, intercambiar procesos, etc.
_gp_rsiVBL:
	push {r4-r7, lr}
	ldr r4, =_gd_tickCount	@;Increase _gd_tickCount
	ldr r5, [r4]
	add r5, #1
	str r5, [r4]
	
	ldr r6, =_gd_pidz		@;Load the _gd_pidz
	ldr r4, =_gd_nReady		@;Check if there's any process in the ready queue
	ldr r5, [r4]			@;R5 contains nReady
	cmp r5, #0
	beq .LrsiVBLend			@;If there is none, end rsi
	
	ldr r7, [r6]			@;If actual process is the OS, skip to save its context
	cmp r7, #0
	beq .LrsiVBLsc
	
	mov r7, r7, lsr #4		@;Shift pidz 4 bits to the right to get the 28 upper ones (PID value)
	cmp r7, #0				@;If PID value of the process is 0, is finished and we must NOT save its context (skip to the end of rsi)
	beq .LrsiVBLend
	
	ldr r4, =_gd_NiceVector
	ldr r5, [r6]			@;Load PIDZ value
	and r5, #0xF			@;Get the lowest 4 bits (zocalo value)
	ldrb r6, [r4, r5]		@;Get the _gd_NiceVector[zocalo] value
	sub r6, #1				@;Decrease nice counter by 1
	and r7, r6, #0x3		@;Get the 3 lowest bits
	cmp r7, #3				@;If they are all set to 1 (value 3), it means we come from 0 remaining ticks, and we decrease -1
	beq .LrsiVBNoTicks		@;If that's the case, DO NOT SAVE to NiceVector (we'd lose nice_value) and make context change
	
	strb r6, [r4, r5]		@;Store updated value if that's NOT the case
	b .LrsiVBLskipAll		@;And if that's not the case skip salvarProc & restaurarProc
	
.LrsiVBNoTicks:	
	@;Recover old registers values for _gp_salvarProc and _gp_restaurarProc
	ldr r6, =_gd_pidz		@;Load the _gd_pidz
	ldr r7, [r6]			@;Get pidz value
	ldr r4, =_gd_nReady		@;Check if there's any process in the ready queue
	ldr r5, [r4]			@;R5 contains nReady	
	
.LrsiVBLsc:
	bl _gp_salvarProc		@;Jump to save context routine
	str r5, [r4]			@;Save new nReady value
.LrsiVBLend:
	bl _gp_restaurarProc	@;Restore context of the next ready process
.LrsiVBLskipAll:
	pop {r4-r7, pc}


	@; Rutina para salvar el estado del proceso interrumpido en la entrada
	@; correspondiente del vector _gd_pcbs
	@;Parámetros
	@; R4: dirección _gd_nReady
	@; R5: número de procesos en READY
	@; R6: dirección _gd_pidz
	@;Resultado
	@; R5: nuevo número de procesos en READY (+1)
_gp_salvarProc:
	push {r8-r11, lr}

	ldr r8, [r6]
	and r8, #0xF			@;Get the zocalo value of current proces' pidz
	ldr r9, =_gd_qReady		@;Store it in the last position of _gd_qReady
	strb r8, [r9, r5]
	
	add r5, #1				@;Increase number of processes in the ready queue
	
	ldr r9, =_gd_pcbs
	mov r10, #24
	mla r9, r8, r10, r9		@;Index = zocalo number * 24 bytes + base address (each pcb is 24 bytes)
	mov r8, sp
	ldr r10, [r8, #60]		@;Get the PC value of the current process (in the IRQ_mode stack, in the position SP_irq+60)
	str r10, [r9, #4]		@;Store it in PC field of current pcb (2nd index (base+1) * 4 bytes = 4 bytes) 
	
	mrs r10, SPSR			@;Load SPSR (contains CPSR of last execution mode, a.k.a. of the process)
	str r10, [r9, #12]		@;Store CPSR of the process in the Status field of current pcb (4th index (base+3) * 4 bytes = 12 bytes)
	
	@;Change execution mode to the interrumped process one
	mrs r10, CPSR			@;Load CPSR register
	orr r10, #0x1F			@;Modify execution mode value so all last 5 bits are set to 1 (System mode)
	msr CPSR, r10			@;Save changes (therefore, entering System mode)
	
	@;Stack registers R0-R12 + R14 on its own stack
	push {r14}				@;Keep pushing registers in order (first R14, then descending from R12 down to R0), stacking them to the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #56]		@;Load R12 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R12 stacking it on top of R14 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #12]		@;Load R11 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R11 stacking it on top of R12 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #8]		@;Load R10 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R10 stacking it on top of R11 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #4]		@;Load R9 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R9 stacking it on top of R10 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8]			@;Load R8 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R8 stacking it on top of R9 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #32]		@;Load R7 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R7 stacking it on top of R8 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #28]		@;Load R6 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R6 stacking it on top of R7 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #24]		@;Load R5 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R5 stacking it on top of R6 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #20]		@;Load R4 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R4 stacking it on top of R5 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #52]		@;Load R3 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R3 stacking it on top of R4 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #48]		@;Load R2 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R2 stacking it on top of R3 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #44]		@;Load R1 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R1 stacking it on top of R2 in the user stack
	@;----------------------------------------------------------------------------
	ldr r11, [r8, #40]		@;Load R0 from IRQ stack (SP_irq+56)
	push {r11}				@;Push R0 stacking it on top of R1 in the user stack
	@;----------------------------------------------------------------------------
	
	str r13, [r9, #8]		@;Store R13 in the SP field of current pcb (3rd index (base+2) * 4 bytes = 8 bytes)
	
	@;Change execution mdoe back to IRQ
	mrs r10, CPSR
	eor r10, #0xD			@;Set the negative of the 0x12 (since all 5 bits are already 1s, we want 0s to be 1s so they cancel out in the xor 
	msr CPSR, r10			@;and 1s to be 0s so they don't change anything

	pop {r8-r11, pc}


	@; Rutina para restaurar el estado del siguiente proceso en la cola de READY
	@;Parámetros
	@; R4: dirección _gd_nReady
	@; R5: número de procesos en READY
	@; R6: dirección _gd_pidz
_gp_restaurarProc:
	push {r8-r11, lr}
	sub r5, r5, #1
	str r5, [r4]			@;Decrease # of processes in ready queue by 1 and store the updated value
	
	ldr r8, =_gd_qReady
	ldrb r9, [r8]			@;Get the zocalo of the first element in the ready queue
	
	cmp r5, #0
	beq .LrpSQR				@;Once we get the first process, if there are no other processes, there is no need to reorder the ready queue.
	
	mov r11, #1				@;Index of the queue
.LrpQR:
	ldrb r10, [r8, r11]		@;Load one position ahead (n+1)
	sub r11, #1
	strb r10, [r8, r11]		@;And store it one position behind (n)
	add r11, #2				@;Jump 2 positions ahead.
	cmp r11, r5
	ble .LrpQR				@;Do it for all elements in nReady (value stored in R5)
	


.LrpSQR:
	ldr r8, =_gd_NiceVector	@;Get base address of _gd_NiceVector
	ldrb r10, [r8, r9]		@;Load the value in _gd_NiceVector[zocalo]				
	mov r11, r10, lsr #2	@;Put the amount of ticks per round value (or nice_value) in the lowest 2 bits (initial amount of ticks)
	add r11, r10			@;Add up those two together (ticks per round and new resetted ticks counter)
	strb r11, [r8, r9]		@;Store new value

	ldr r8, =_gd_pcbs
	mov r11, #24
	mla r10, r9, r11, r8	@;Address of the PCB is zocalo_number*24bytes+base_address
	ldr r11, [r10]			@;Get first value of the PCB (PID)
	mov r11, r11, lsl #4	@;Shift left 4 bits
	add r11, r9				@;Put the zocalo number in the 4 lowest bits
	
	str r11, [r6]			@;Save the new value of PIDZ
	
	ldr r11, [r10, #4]		@;Load the PC field of the pcb of the process we want to restore (2nd index (base+1) * 4 bytes = 4 bytes)
	
	mov r8, sp
	str r11, [r8, #60]		@;Store it in the corresponding position in the IRQ stack (SP_irq+60)
	
	ldr r11, [r10, #12]		@;Load the Status field of the pcb of the process we want to restore (containing
							@;its CPSR) (4th index (base+3) * 4 bytes = 12 bytes)
	msr SPSR, r11			@;Save it to the SPSR (containing the CPSR of the process after exiting the IRQ)
	
	mrs r11, CPSR			@;Load CPSR into R11
	orr r11, #0x1F			@;Switch to system mode setting lowest 5 bits to 1
	msr CPSR, r11			@;Save new value to CPSR
	
	ldr r13, [r10, #8]		@;Restore R13 from the SP field in the pcb (3rd index (base+2) * 4 bytes = 8 bytes)
	
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R0 from the process stack
	str r11, [r8, #40]		@;Store R0 into the IRQ stack (SP_irq+40)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R1 from the process stack
	str r11, [r8, #44]		@;Store R1 into the IRQ stack (SP_irq+44)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R2 from the process stack
	str r11, [r8, #48]		@;Store R2 into the IRQ stack (SP_irq+48)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R3 from the process stack
	str r11, [r8, #52]		@;Store R3 into the IRQ stack (SP_irq+52)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R4 from the process stack
	str r11, [r8, #20]		@;Store R4 into the IRQ stack (SP_irq+20)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R5 from the process stack
	str r11, [r8, #24]		@;Store R5 into the IRQ stack (SP_irq+24)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R6 from the process stack
	str r11, [r8, #28]		@;Store R6 into the IRQ stack (SP_irq+28)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R7 from the process stack
	str r11, [r8, #32]		@;Store R7 into the IRQ stack (SP_irq+32)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R8 from the process stack
	str r11, [r8, #12]		@;Store R8 into the IRQ stack (SP_irq+12)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R9 from the process stack
	str r11, [r8, #8]		@;Store R9 into the IRQ stack (SP_irq+8)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R10 from the process stack
	str r11, [r8, #4]		@;Store R10 into the IRQ stack (SP_irq+4)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R11 from the process stack
	str r11, [r8]			@;Store R11 into the IRQ stack (base SP_irq)
	@;----------------------------------------------------------------------------
	pop {r11}				@;Pop R12 from the process stack
	str r11, [r8, #56]		@;Store R12 into the IRQ stack (SP_irq+56)
	@;----------------------------------------------------------------------------
	pop {r14}				@;Pop R12 from the process stack
	
		
	@;Change execution mdoe back to IRQ
	mrs r10, CPSR
	eor r10, #0xD			@;Set the negative of the 0x12 (since all 5 bits are already 1s, we want 0s to be 1s so they cancel out in the xor 
	msr CPSR, r10			@;and 1s to be 0s so they don't change anything
	pop {r8-r11, pc}


	.global _gp_numProc
	@;Resultado
	@; R0: número de procesos total
_gp_numProc:
	push {lr}
	ldr r0, =_gd_nReady
	ldr r0, [r0]			@;We load nReady variable
	add r0, #1				@;Add +1 to its value (we must take into account the process in run)
	pop {pc}


	.global _gp_crearProc
	@; prepara un proceso para ser ejecutado, creando su entorno de ejecución y
	@; colocándolo en la cola de READY
	@;Parámetros
	@; R0: intFunc funcion,
	@; R1: int zocalo,
	@; R2: char *nombre
	@; R3: int arg
	@;Resultado
	@; R0: 0 si no hay problema, >0 si no se puede crear el proceso
_gp_crearProc:
	push {r4-r7, lr}
	cmp r1, #0				@;If zocalo is 0, exit (since it is reserved for the OS, it cannot be used by any other process) returning 1
	moveq r0, #1			
	beq .LcpE
	
	ldr r4, =_gd_pcbs
	mov r5, #24
	mla r4, r1, r5, r4		@;Address of the PCB is zocalo_number*24bytes+base_address
	
	ldr r5, [r4]			@;Get first value of the PCB (PID)
	cmp r5, #0			
	movne r0, #2			@;If it's different from 0 (meaning it is occupied) return 2
	bne .LcpE				@;Exit from routine
	
	ldr r5, =_gd_pidCount
	ldr r6, [r5]
	add r6, #1				@;Increment variable _gd_pidCount
	str r6, [r5]			@;Store updated variable
	
	str r6, [r4]			@;Store it in the PID field of the current PCB
	add r0, #4				@;Add 4 bytes to the address to compensate the decrement suffered in the first time being restored due to the IRQ BIOS exception handler
	str r0, [r4, #4]		@;Store R0 in the PC field of current PCB (2nd index (base+1) * 4 bytes = 4 bytes) 
	ldr r2, [r2]			@;We load the first 4 characters (1 char = 1 byte -> 4 chars = 4 bytes = 1 int) from the address where the process name is
	
	str r2, [r4, #16]		@;Store those 4 first characters in the KeyName field of current PCB (5th index (base+4) * 4 bytes = 16 bytes) 
	
	ldr r5, =_gd_stacks
	mov r6, #512			@;Each stack is 128 positions of 4 bytes each, a total of 512 bytes!!!
	mla r5, r1, r6, r5		@;Stack base address will be base_gd_stacks address + zocalo number * size of each process' stack
	sub r5, #4
	ldr r6, =_gp_terminarProc	@;First, we get address of _gd_terminarProc routine
	str r6, [r5]				@;Store it in R14 in the process stack


	
	mov r6, #0				@;We initialize #0 in R6 as to the value to be stored
	mov r7, #0				@;We initialize #0 in R7 as a counter
.LcpSL:
	sub r5, #4				@;We go to the next position of the stack (-4 bytes)
	str r6, [r5]			@;Store value #0 to that register
	add r7, #1				@;Increment counter
	cmp r7, #12				@;Repeat 12 times (from R12 to R11)
	bne .LcpSL				@;If this goes wrong, swap to bge instruction	

	sub r5, #4				@;We get the address of R0 in the stack
	str r3, [r5]			@;Then, store the arguments of the process in it
	
	str r5, [r4, #8]		@;Store R13 value in the SP field of current PCB (3rd index (base+2) * 4 bytes = 8 bytes) 
	
	mov r5, #0x1F			@;Lowest 5 bits are 1 (System mode) while all the others remain 0
	str r5, [r4, #12]		@;Store initial CPSR value in the Status field of current PCB (4th index (base+3) * 4 bytes = 12 bytes) 
	
	mov r5, #0
	str r5, [r4, #20]		@;Store #0 in the workticks field of current PCB (6th index (base+5) * 4 bytes = 20 bytes) 
	
	ldr r4, =_gd_nReady
	ldr r5, [r4]			@;Load nReady value
	
	ldr r6, =_gd_qReady
	add r6, r5				@;Since qReady elements are chars, mla instruction woud multiply nReady * 1 byte + queue base address, which would become queue base addr. + nReady
	
	strb r1, [r6]			@;Store zocalo number in the last position of the Ready queue
	add r5, #1
	str r5, [r4]			@;Increment nReady and store updated value
	
	ldr r4, =_gd_NiceVector	@;Get base address of the _gd_NiceVector
	mov r5, #0x0			@;Set value 0 (nice_value=3&emaining_ticks=0)
	strb r5, [r4, r1]		@;Store value in NiceVector[zocalo]
	
	
.LcpE:
	@;Return:
	@;	0 -> Process created correctly
	@;	1 -> Incorrect zocalo number (0 is forbidden)
	@;	2 -> Zocalo already in use
	pop {r4-r7, pc}


	@; Rutina para terminar un proceso de usuario:
	@; pone a 0 el campo PID del PCB del zócalo actual, para indicar que esa
	@; entrada del vector _gd_pcbs está libre; también pone a 0 el PID de la
	@; variable _gd_pidz (sin modificar el número de zócalo), para que el código
	@; de multiplexación de procesos no salve el estado del proceso terminado.
_gp_terminarProc:
	ldr r0, =_gd_pidz
	ldr r1, [r0]			@; R1 = valor actual de PID + zócalo
	and r1, r1, #0xf		@; R1 = zócalo del proceso desbancado
	str r1, [r0]			@; guardar zócalo con PID = 0, para no salvar estado			
	ldr r2, =_gd_pcbs
	mov r10, #24
	mul r11, r1, r10
	add r2, r11				@; R2 = dirección base _gd_pcbs[zocalo]
	mov r3, #0
	str r3, [r2]			@; pone a 0 el campo PID del PCB del proceso
.LterminarProc_inf:
	bl _gp_WaitForVBlank	@; pausar procesador
	b .LterminarProc_inf	@; hasta asegurar el cambio de contexto
	
.end

