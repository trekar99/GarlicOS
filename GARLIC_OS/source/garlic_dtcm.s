@;==============================================================================
@;
@;	"garlic_dtcm.s":	zona de datos b�sicos del sistema GARLIC 1.0
@;						(ver "garlic_system.h" para descripci�n de variables)
@;
@;==============================================================================

.include "../include/garlic_tecl_incl.i"

.section .dtcm,"wa",%progbits

	.align 2

	.global _gd_pidz			@; Identificador de proceso + z�calo actual
_gd_pidz:	.word 0

	.global _gd_pidCount		@; Contador global de PIDs
_gd_pidCount:	.word 0

	.global _gd_tickCount		@; Contador global de tics
_gd_tickCount:	.word 0

	.global _gd_seed			@; Semilla para generaci�n de n�meros aleatorios
_gd_seed:	.word 0xFFFFFFFF

	.global _gd_nReady			@; N�mero de procesos en la cola de READY
_gd_nReady:	.word 0

	.global _gd_qReady			@; Cola de READY (procesos preparados)
_gd_qReady:	.space 16

	.global _gd_pcbs			@; Vector de PCBs de los procesos activos
_gd_pcbs:	.space 16 * 6 * 4

	.global _gd_wbfs			@; Vector de WBUFs de las ventanas disponibles
_gd_wbfs:	.space 4 * (4 + 32)

	.global _gd_stacks			@; Vector de pilas de los procesos activos
_gd_stacks:	.space 15 * 128 * 4

	.global _gd_NiceVector		@; Vector de nice de los procesos activos
_gd_NiceVector:	.space 16

@; Prog T Variables
@; Procesos
	.global _gd_num_kbwait		@; Vector de procesos esperando teclado.
_gd_num_kbwait: .word 0

	.global _gd_kbwait			@; N�mero de procesos esperando teclado.
_gd_kbwait: .space 16			
	
	.global _gd_kbsignal		@; Se�al para terminar uso teclado.
_gd_kbsignal: .word 0

@; String
	.global _gt_str_input		@; Variable que contiene la string.
_gt_str_input: .fill 32, 1, 200
	
	.global _gt_str_lenght		@; Lenght string
_gt_str_lenght: .word 0
	
	.global _gt_curr_pos		@; Posici�n actual en la string Input
_gt_curr_pos: .word LIM_LEFT

@; Gr�ficos
	.global _gt_mapbgKB			@; Direcci�n del mapa de baldosas
_gt_mapbgKB: .word 0

	.global _gt_mapbgCursorKB	@; Direcci�n mapa baldosas cursor.
_gt_mapbgCursorKB: .word 0

@; Otros
	.global _gt_activeKB		@; Indica si el teclado est� activo
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
	

.end

