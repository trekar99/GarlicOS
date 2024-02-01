	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"FIZZ.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"-- Programa FIZZ  -  PID (%d) --\012\000"
	.align	2
.LC1:
	.ascii	"%d: FIZZ\012\000"
	.align	2
.LC2:
	.ascii	"%d: BUZZ\012\000"
	.align	2
.LC3:
	.ascii	"%d: %d\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #36
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	mov	r0, r3
	bl	GARLIC_nice
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L8
	bl	GARLIC_printf
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	ldr	r3, [sp, #4]
	add	r3, r3, #1
	mov	r2, #50
	mul	r3, r2, r3
	mov	r1, r3
	add	r3, sp, #8
	add	r2, sp, #12
	bl	GARLIC_divmod
	str	r0, [sp, #28]
	ldr	r3, [sp, #8]
	str	r3, [sp, #28]
	mov	r3, #1
	str	r3, [sp, #24]
	b	.L2
.L6:
	ldr	r0, [sp, #28]
	add	r3, sp, #8
	add	r2, sp, #12
	mov	r1, #3
	bl	GARLIC_divmod
	mov	r3, r0
	str	r3, [sp, #20]
	ldr	r3, [sp, #8]
	str	r3, [sp, #20]
	ldr	r0, [sp, #28]
	add	r3, sp, #8
	add	r2, sp, #12
	mov	r1, #5
	bl	GARLIC_divmod
	mov	r3, r0
	str	r3, [sp, #16]
	ldr	r3, [sp, #8]
	str	r3, [sp, #16]
	ldr	r3, [sp, #20]
	cmp	r3, #0
	bne	.L3
	ldr	r1, [sp, #24]
	ldr	r0, .L8+4
	bl	GARLIC_printf
	b	.L4
.L3:
	ldr	r3, [sp, #16]
	cmp	r3, #0
	bne	.L5
	ldr	r1, [sp, #24]
	ldr	r0, .L8+8
	bl	GARLIC_printf
	b	.L4
.L5:
	ldr	r2, [sp, #28]
	ldr	r1, [sp, #24]
	ldr	r0, .L8+12
	bl	GARLIC_printf
.L4:
	mov	r3, #3
	str	r3, [sp, #20]
	mov	r3, #5
	str	r3, [sp, #16]
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
	ldr	r3, [sp, #24]
	add	r3, r3, #1
	str	r3, [sp, #24]
.L2:
	ldr	r3, [sp, #24]
	cmp	r3, #100
	ble	.L6
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #36
	@ sp needed
	ldr	pc, [sp], #4
.L9:
	.align	2
.L8:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
