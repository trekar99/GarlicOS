@;==============================================================================
@;
@;	"garlic_itcm_graf.s":	código de rutinas de soporte a la gestión de
@;							ventanas gráficas (versión 1.0)
@;
@;==============================================================================

NVENT	= 4					@; número de ventanas totales
PPART	= 2					@; número de ventanas horizontales o verticales
							@; (particiones de pantalla)
L2_PPART = 1				@; log base 2 de PPART

VCOLS	= 32				@; columnas y filas de cualquier ventana
VFILS	= 24
PCOLS	= VCOLS * PPART		@; número de columnas totales (en pantalla)
PFILS	= VFILS * PPART		@; número de filas totales (en pantalla)

WBUFS_LEN = 36				@; longitud de cada buffer de ventana (32+4)

.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gg_escribirLinea
	@; Rutina para escribir toda una linea de caracteres almacenada en el
	@; buffer de la ventana especificada;
	@;Parámetros:
	@;	R0: ventana a actualizar (int v)
	@;	R1: fila actual (int f)
	@;	R2: número de caracteres a escribir (int n)
_gg_escribirLinea:
	push {r0, r2-r12, lr}
	
	ldr r3, =L2_PPART		@;R3 es LOG2 PPART
	lsr r4, r0, r3			@;R4 = v / PPART
	
	ldr r5, =PPART			@;R5 es PPART
	mul r5, r4, r5			@;R5 = (v/PPART) * PPART
	sub r5, r0, r5			@;R5 = v % PPART
	
	ldr r10, =VFILS
	ldr r11, =VCOLS
	ldr r12, =PCOLS
	
	ldr r6, =_gd_wbfs		@;R6 es dir. de mem. dels buffers
	ldr r7, =WBUFS_LEN
	mla r6, r7, r0, r6		@;R6 = R6 + (36 * v)
	add r6, #4				@;R6 es la dir. del buffer per la finestra v
	
	ldr r7, =bg2Ptr
	ldr r7, [r7]			@;R7 es dir. de mem. del bg2
	
	mov r8, #0				@;R8 = 0 --> i=0
	
	@;Calculem la cantonada superior de la finestra i a partir d'alla farem tots els calculs
	mul r0, r4, r10			@;R0 = (v / PPART) * VFILS
	mul r0, r12				@;R0 = R0 * PCOLS
	mul r3, r5, r11			@;R3 = (v % PPART) * VCOLS
	add r0, r0, r3			@;R0 = (v / PPART) * VFILS * PCOLS + (v % PPART) * VCOLS
	ldr r3, =PPART			@;R3 = PPART temporalment
	mul r0, r3				@;R0 = R0 * PPART per tal d'ajustar el text a la finestra corresponent
	
	.while_linia:
		ldrb r9, [r6, r8]	@;R9 = _gd_wbfs[v].pChars[i]
		
		mla r3, r1, r12, r8	@;R3 = fila * PCOLS + columna
		add r3, r3			@;R3 = R3 * 2 ja que les baldoses son de 2B
		add r4, r0, r3		@;R4 = posicio del caracter a escriure
		
		sub r9, r9, #32		@;restem 32 al valor ASCII per obtenir la baldosa
		strh r9, [r7, r4]	@;bg2Ptr[R0] = _gd_wbfs[v].pChars[i]
							@;Utilitzem h perque les baldoses ocupen 2 Bytes (halfWord)
		
		add r8, #1			@;incrementem R8 en 1 (i++)
		
		sub r2, #1			@;decrementem numero de caracters a escriure en 1 (n--)
		cmp r2, #0			@;mirem si hem acabat d'escriure tots els caracters
		bhi .while_linia	@;decidim si seguim escribint
	.fiWhile_linia:
	
	pop {r0, r2-r12, pc}


	.global _gg_desplazar
	@; Rutina para desplazar una posición hacia arriba todas las filas de la
	@; ventana (v), y borrar el contenido de la última fila
	@;Parámetros:
	@;	R0: ventana a desplazar (int v)
_gg_desplazar:
	push {r0-r12, lr}
	
	ldr r1, =L2_PPART		@;R1 es LOG2 PPART
	lsr r2, r0, r1			@;R2 = v / PPART
	
	ldr r3, =PPART			@;R3 es PPART
	mul r3, r2, r3			@;R3 = (v/PPART) * PPART
	sub r3, r0, r3			@;R3 = v % PPART
	
	ldr r10, =VFILS
	ldr r11, =VCOLS
	ldr r12, =PCOLS
	
	ldr r4, =bg2Ptr
	ldr r4, [r4]			@;R4 es dir. de mem. del bg2
	
	@;Calculem la cantonada superior de la finestra i a partir d'alla farem tots els calculs
	mul r0, r2, r10			@;R0 = (v / PPART) * VFILS
	mul r0, r12				@;R0 = R0 * PCOLS
	mul r1, r3, r11			@;R1 = (v % PPART) * VCOLS
	add r0, r0, r1			@;R0 = (v / PPART) * VFILS * PCOLS + (v % PPART) * VCOLS
	ldr r1, =PPART			@;R1 = PPART
	mul r0, r1				@;R0 = R0 * PPART per tal d'ajustar el text a la finestra corresponent
	
	mov r5, #0				@;R5 = 0 --> fila-1 = 0
	mov r6, #1				@;R6 = 1 --> fila = 1
	
	.for23:
		mul r1, r5, r12		@;R1 = (fila-1) * PCOLS
		add r1, r1			@;R1 = R1 * 2 ja que les baldoses son de 2B
		mul r2, r6, r12		@;R2 = fila * PCOLS
		add r2, r2			@;R2 = R2 * 2 ja que les baldoses son de 2B
		mov r7, #0			@;R7 = 0 --> columna = 0
		
		.for32:
			add r8, r0, r2	@;R8 = posicio del caracter a moure
			ldrh r9, [r4, r8]@;R9 = caracter a moure
			add r8, r0, r1	@;R8 = posicio on escriure el caracter
			strh r9, [r4, r8]@;bg2Ptr[R0] = bg2Ptr[R0-fila]
							 @;Utilitzem h perque les baldoses ocupen 2 Bytes (halfWord)
			
			add r1, #2		@;incrementem la columna actual en el tamany de les baldoses (2)
			add r2, #2		@;incrementem la columna actual en el tamany de les baldoses (2)
			add r7, #1		@;incrementem la columna actual en 1
			cmp r7, #VCOLS
			blo .for32		@;iterem fins que arribem al final de la fila
		.fiFor32:
		
		add r5, #1			@;fila-1++
		add r6, #1			@;fila++
		cmp r6, #VFILS
		blo .for23			@;segueix mentre fila < 24
	.fiFor23:
	
	mul r1, r5, r12			@;R1 = (fila-1) * PCOLS
	add r1, r1
	mov r7, #0				@;R7 = 0 --> columna = 0
	mov r9, #0				@;R9 es ' '
	.eliminarFinal:
		add r8, r0, r1		@;R8 = posicio del caracter a sobreescriure
		strh r9, [r4, r8]	@;bg2Ptr[R0] = ' '
							@;Utilitzem h perque les baldoses ocupen 2 Bytes (halfWord)
							
		add r1, #2			@;incrementem la columna actual en el tamany de les baldoses (2)
		add r7, #1			@;incrementem la columna actual en 1
		cmp r7, #VCOLS
		blo .eliminarFinal	@;iterem fins que arribem al final de la fila
	.fiEliminarFinal:
	
	pop {r0-r12, pc}


.end

