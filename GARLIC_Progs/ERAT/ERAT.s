	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"erat.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"-- Programa ERAT - PID (%d) --\012\000"
	.align	2
.LC1:
	.ascii	"Introduce un n\372mero para realizar la criba\012\000"
	.align	2
.LC2:
	.ascii	"Los n\372meros primos menores que %d son:\012\000"
	.align	2
.LC3:
	.ascii	"El numero %d es primo\012\000"
	.align	2
.LC4:
	.ascii	"-- FI Programa ERAT --\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, fp, lr}
	add	fp, sp, #24
	sub	sp, sp, #36
	str	r0, [fp, #-56]
	mov	r3, sp
	mov	r8, r3
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L15
	bl	GARLIC_printf
	ldr	r0, .L15+4
	bl	GARLIC_printf
	mov	r0, #100
	bl	GARLIC_getnumber
	str	r0, [fp, #-32]
	ldr	r3, [fp, #-32]
	cmp	r3, #0
	bge	.L2
	mov	r3, #0
	str	r3, [fp, #-32]
	b	.L3
.L2:
	ldr	r3, [fp, #-32]
	cmp	r3, #3
	ble	.L3
	mov	r3, #3
	str	r3, [fp, #-32]
.L3:
	ldr	r3, [fp, #-32]
	add	r2, r3, #1
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #2
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-44]
	add	r1, r3, #1
	sub	r3, r1, #1
	str	r3, [fp, #-48]
	mov	r3, r1
	mov	r2, r3
	mov	r3, #0
	lsl	r7, r3, #3
	orr	r7, r7, r2, lsr #29
	lsl	r6, r2, #3
	mov	r3, r1
	mov	r2, r3
	mov	r3, #0
	lsl	r5, r3, #3
	orr	r5, r5, r2, lsr #29
	lsl	r4, r2, #3
	mov	r3, r1
	add	r3, r3, #7
	lsr	r3, r3, #3
	lsl	r3, r3, #3
	sub	sp, sp, r3
	mov	r3, sp
	add	r3, r3, #0
	str	r3, [fp, #-52]
	mov	r3, #0
	str	r3, [fp, #-36]
	b	.L4
.L5:
	ldr	r2, [fp, #-52]
	ldr	r3, [fp, #-36]
	add	r3, r2, r3
	mov	r2, #1
	strb	r2, [r3]
	ldr	r3, [fp, #-36]
	add	r3, r3, #1
	str	r3, [fp, #-36]
.L4:
	ldr	r2, [fp, #-36]
	ldr	r3, [fp, #-44]
	cmp	r2, r3
	ble	.L5
	mov	r3, #2
	str	r3, [fp, #-36]
	b	.L6
.L10:
	ldr	r2, [fp, #-52]
	ldr	r3, [fp, #-36]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L7
	ldr	r3, [fp, #-36]
	ldr	r2, [fp, #-36]
	mul	r3, r2, r3
	str	r3, [fp, #-40]
	b	.L8
.L9:
	ldr	r2, [fp, #-52]
	ldr	r3, [fp, #-40]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
	ldr	r2, [fp, #-40]
	ldr	r3, [fp, #-36]
	add	r3, r2, r3
	str	r3, [fp, #-40]
.L8:
	ldr	r2, [fp, #-40]
	ldr	r3, [fp, #-44]
	cmp	r2, r3
	ble	.L9
.L7:
	ldr	r3, [fp, #-36]
	add	r3, r3, #1
	str	r3, [fp, #-36]
.L6:
	ldr	r2, [fp, #-36]
	ldr	r3, [fp, #-44]
	cmp	r2, r3
	ble	.L10
	ldr	r1, [fp, #-44]
	ldr	r0, .L15+8
	bl	GARLIC_printf
	mov	r3, #2
	str	r3, [fp, #-36]
	b	.L11
.L13:
	ldr	r2, [fp, #-52]
	ldr	r3, [fp, #-36]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L12
	ldr	r1, [fp, #-36]
	ldr	r0, .L15+12
	bl	GARLIC_printf
.L12:
	ldr	r3, [fp, #-36]
	add	r3, r3, #1
	str	r3, [fp, #-36]
.L11:
	ldr	r2, [fp, #-36]
	ldr	r3, [fp, #-44]
	cmp	r2, r3
	ble	.L13
	ldr	r0, .L15+16
	bl	GARLIC_printf
	mov	r3, #0
	mov	sp, r8
	mov	r0, r3
	sub	sp, fp, #24
	@ sp needed
	pop	{r4, r5, r6, r7, r8, fp, pc}
.L16:
	.align	2
.L15:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
