	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"XF_5.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"-- Programa XF_5  -  PID (%d) --\012\000"
	.align	2
.LC1:
	.ascii	"FRASE DE EJEMPLO\000\000"
	.align	2
.LC2:
	.ascii	"AODHAOFNOJFPAWUD\000"
	.align	2
.LC3:
	.ascii	"IGKDNBPQKFKQKSHR\000"
	.align	2
.LC4:
	.ascii	"ESTOY DESEANDO COMER UN HELADO\000\000"
	.align	2
.LC5:
	.ascii	"IAJSDINKLASNDIASJDIASJDLADLJQO\000"
	.align	2
.LC6:
	.ascii	"CON DIEZ CANONES POR BANDA VIENTO EN POPA A TODA VE"
	.ascii	"LA\000\000"
	.align	2
.LC7:
	.ascii	"AJSJKIJOJIOPJIUHYUFAYTGYUDDG6GIUDJOIHOPOCHUFJPOMANJ"
	.ascii	"FH\000"
	.align	2
.LC8:
	.ascii	"(%d) MESS:\011%s\012\012\000"
	.align	2
.LC9:
	.ascii	"(%d) RES:\011%s\012\012\000"
	.align	2
.LC10:
	.ascii	"--         FINALIZADO        --\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 112
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #116
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	mov	r0, r3
	bl	GARLIC_nice
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L14
	bl	GARLIC_printf
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ldrls	pc, [pc, r3, asl #2]
	b	.L2
.L4:
	.word	.L3
	.word	.L5
	.word	.L6
	.word	.L7
.L3:
	ldr	r3, .L14+4
	str	r3, [sp, #108]
	ldr	r3, .L14+8
	str	r3, [sp, #104]
	b	.L8
.L5:
	ldr	r3, .L14+4
	str	r3, [sp, #108]
	ldr	r3, .L14+12
	str	r3, [sp, #104]
	b	.L8
.L6:
	ldr	r3, .L14+16
	str	r3, [sp, #108]
	ldr	r3, .L14+20
	str	r3, [sp, #104]
	b	.L8
.L7:
	ldr	r3, .L14+24
	str	r3, [sp, #108]
	ldr	r3, .L14+28
	str	r3, [sp, #104]
	b	.L8
.L2:
	ldr	r3, .L14+4
	str	r3, [sp, #108]
	ldr	r3, .L14+8
	str	r3, [sp, #104]
.L8:
	mov	r3, #0
	str	r3, [sp, #100]
	b	.L9
.L12:
	ldr	r3, [sp, #100]
	ldr	r2, [sp, #108]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #32
	bne	.L10
	add	r2, sp, #8
	ldr	r3, [sp, #100]
	add	r3, r2, r3
	mov	r2, #32
	strb	r2, [r3]
	b	.L11
.L10:
	ldr	r3, [sp, #100]
	ldr	r2, [sp, #108]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	sub	r3, r3, #65
	str	r3, [sp, #96]
	ldr	r3, [sp, #100]
	ldr	r2, [sp, #104]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	sub	r3, r3, #65
	str	r3, [sp, #92]
	ldr	r2, [sp, #96]
	ldr	r3, [sp, #92]
	add	r2, r2, r3
	ldr	r3, .L14+32
	smull	r1, r3, r2, r3
	asr	r1, r3, #3
	asr	r3, r2, #31
	sub	r3, r1, r3
	mov	r1, #26
	mul	r3, r1, r3
	sub	r3, r2, r3
	add	r3, r3, #65
	str	r3, [sp, #88]
	ldr	r3, [sp, #88]
	and	r1, r3, #255
	add	r2, sp, #8
	ldr	r3, [sp, #100]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
.L11:
	ldr	r3, [sp, #100]
	add	r3, r3, #1
	str	r3, [sp, #100]
.L9:
	ldr	r3, [sp, #100]
	ldr	r2, [sp, #108]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L12
	add	r2, sp, #8
	ldr	r3, [sp, #100]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
	bl	GARLIC_pid
	mov	r3, r0
	ldr	r2, [sp, #108]
	mov	r1, r3
	ldr	r0, .L14+36
	bl	GARLIC_printf
	bl	GARLIC_pid
	mov	r1, r0
	add	r3, sp, #8
	mov	r2, r3
	ldr	r0, .L14+40
	bl	GARLIC_printf
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L14
	bl	GARLIC_printf
	ldr	r0, .L14+44
	bl	GARLIC_printf
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #116
	@ sp needed
	ldr	pc, [sp], #4
.L15:
	.align	2
.L14:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	1321528399
	.word	.LC8
	.word	.LC9
	.word	.LC10
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
