@;==============================================================================
@;
@;	"garlic_dtcm.s":	zona de datos básicos del sistema GARLIC 2.0
@;						(ver "garlic_system.h" para descripción de variables)
@;
@;==============================================================================

.include "../include/garlic_tecl_incl.i"

.section .dtcm,"wa",%progbits

	.align 2
	
	.global _gi_za			@; Foco
_gi_za:	.word 0

	.global _gd_pidz			@; Identificador de proceso + zócalo actual
_gd_pidz:	.word 0

	.global _gd_pidCount		@; Contador global de PIDs
_gd_pidCount:	.word 0

	.global _gd_tickCount		@; Contador global de tics
_gd_tickCount:	.word 0

	.global _gd_sincMain		@; Sincronismos con programa principal
_gd_sincMain:	.word 0

	.global _gd_seed			@; Semilla para generación de números aleatorios
_gd_seed:	.word 0xFFFFFFFF

	.global _gd_nReady			@; Número de procesos en la cola de READY
_gd_nReady:	.word 0

	.global _gd_qReady			@; Cola de READY (procesos preparados)
_gd_qReady:	.space 16

	.global _gd_nDelay			@; Número de procesos en la cola de DELAY
_gd_nDelay:	.word 0

	.global _gd_qDelay			@; Cola de DELAY (procesos retardados)
_gd_qDelay:	.space 16 * 4

	.global _gd_pcbs			@; Vector de PCBs de los procesos activos
_gd_pcbs:	.space 16 * 6 * 4	@; 96 words

	.global _gd_wbfs			@; Vector de WBUFs de las ventanas disponibles
_gd_wbfs:	.space 16 * (4 + 64)

	.global _gd_stacks			@; Vector de pilas de los procesos activos
_gd_stacks:	.space 15 * 128 * 4 @; 1920 words

	.global _gd_NiceVector		@; Vector de nice de los procesos activos
_gd_NiceVector:	.space 16

	.global _gd_timerMod		@; Variable to store the mod when dividing
_gd_timerMod:	.word 0

	.global _gd_numString		@; Variable to save the conversion from number to string
_gd_numString:	.space 4 * 1


@; Prog T Variables
@; Procesos
	.global _gd_num_kbwait		@; Vector de procesos esperando teclado.
_gd_num_kbwait: .word 0

	.global _gd_kbwait			@; Número de procesos esperando teclado.
_gd_kbwait: .space 16	
	
	.global _gd_kbsignal		@; QUITAR Señal para terminar uso teclado.
_gd_kbsignal: .word 0			

@; String
	.global _gt_str_input		@; Variable que contiene la string.
_gt_str_input: .fill 32, 1, 200
	
	.global _gt_str_lenght		@; Lenght string
_gt_str_lenght: .word 0
	
	.global _gt_str_lenght_buf	@; Buffer lenght string
_gt_str_lenght_buf: .space 16
	
	.global _gt_curr_pos		@; Posición actual en la string Input
_gt_curr_pos: .word LIM_LEFT

@; Gráficos
	.global _gt_mapbgKB			@; Dirección del mapa de baldosas
_gt_mapbgKB: .word 0

	.global _gt_mapbgCursorKB	@; Dirección mapa baldosas cursor.
_gt_mapbgCursorKB: .word 0

	.global _gt_mapbgColors		@; Dirección mapa fondo colores.
_gt_mapbgColors: .word 0

	.global _gt_bgtable
_gt_bgtable:	.space 4	@; Dirección del mapa de baldosas de la tabla de procesos

@; Otros
	.global _gt_activeKB		@; Indica si el teclado está activo
_gt_activeKB: .word 0

	.global _gt_aux				@; Variable auxiliar
_gt_aux: .word 0

	.global _gt_curr_key		@; Variable que guarda la tecla anterior pulsada.
_gt_curr_key: .word 0

	.global _gt_curr_key_tics	@; Variable que guarda la tecla anterior pulsada.
_gt_curr_key_tics: .word 0

	.global _gt_count_timer
_gt_count_timer: .word 0

	.global _gt_typeKB			@; Variable que indica tipo teclado
_gt_typeKB: .word 0				@; 0: string, 1: dec, 2: hexa

	.global _gt_typeKB_buf			@; Variable que indica tipo teclado
_gt_typeKB_buf: .space 16				@; 0: string, 1: dec, 2: hexa

	.global _gt_capsKB			@; Variable que indica si están las teclas
_gt_capsKB: .word 0				@; especiales activadas.
	
	.global _gt_xybuttons
_gt_xybuttons: .word 0
	
	.global _gt_FIFO_RECV
_gt_FIFO_RECV: .word 0

	.global _gt_FIFO_RECV_status
_gt_FIFO_RECV_status: .word 0

.end

