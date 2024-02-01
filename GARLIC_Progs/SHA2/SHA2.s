	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"sha2.c"
	.section	.rodata
	.align	2
	.type	k, %object
	.size	k, 256
k:
	.word	1116352408
	.word	1899447441
	.word	-1245643825
	.word	-373957723
	.word	961987163
	.word	1508970993
	.word	-1841331548
	.word	-1424204075
	.word	-670586216
	.word	310598401
	.word	607225278
	.word	1426881987
	.word	1925078388
	.word	-2132889090
	.word	-1680079193
	.word	-1046744716
	.word	-459576895
	.word	-272742522
	.word	264347078
	.word	604807628
	.word	770255983
	.word	1249150122
	.word	1555081692
	.word	1996064986
	.word	-1740746414
	.word	-1473132947
	.word	-1341970488
	.word	-1084653625
	.word	-958395405
	.word	-710438585
	.word	113926993
	.word	338241895
	.word	666307205
	.word	773529912
	.word	1294757372
	.word	1396182291
	.word	1695183700
	.word	1986661051
	.word	-2117940946
	.word	-1838011259
	.word	-1564481375
	.word	-1474664885
	.word	-1035236496
	.word	-949202525
	.word	-778901479
	.word	-694614492
	.word	-200395387
	.word	275423344
	.word	430227734
	.word	506948616
	.word	659060556
	.word	883997877
	.word	958139571
	.word	1322822218
	.word	1537002063
	.word	1747873779
	.word	1955562222
	.word	2024104815
	.word	-2067236844
	.word	-1933114872
	.word	-1866530822
	.word	-1538233109
	.word	-1090935817
	.word	-965641998
	.text
	.align	2
	.global	sha256_block
	.syntax unified
	.arm
	.fpu softvfp
	.type	sha256_block, %function
sha256_block:
	@ args = 0, pretend = 0, frame = 312
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #312
	str	r0, [sp, #4]
	str	r1, [sp]
	mov	r3, #0
	str	r3, [sp, #276]
	b	.L2
.L3:
	ldr	r3, [sp, #276]
	lsl	r3, r3, #2
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsl	r2, r3, #24
	ldr	r3, [sp, #276]
	lsl	r3, r3, #2
	add	r3, r3, #1
	ldr	r1, [sp, #4]
	add	r3, r1, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsl	r3, r3, #16
	orr	r2, r2, r3
	ldr	r3, [sp, #276]
	lsl	r3, r3, #2
	add	r3, r3, #2
	ldr	r1, [sp, #4]
	add	r3, r1, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsl	r3, r3, #8
	orr	r3, r2, r3
	ldr	r2, [sp, #276]
	lsl	r2, r2, #2
	add	r2, r2, #3
	ldr	r1, [sp, #4]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	orr	r2, r3, r2
	ldr	r3, [sp, #276]
	lsl	r3, r3, #2
	add	r1, sp, #312
	add	r3, r1, r3
	str	r2, [r3, #-300]
	ldr	r3, [sp, #276]
	add	r3, r3, #1
	str	r3, [sp, #276]
.L2:
	ldr	r3, [sp, #276]
	cmp	r3, #15
	bls	.L3
	b	.L4
.L5:
	ldr	r3, [sp, #276]
	sub	r3, r3, #2
	lsl	r3, r3, #2
	add	r2, sp, #312
	add	r3, r2, r3
	ldr	r3, [r3, #-300]
	ror	r2, r3, #15
	ldr	r3, [sp, #276]
	sub	r3, r3, #2
	lsl	r3, r3, #2
	add	r1, sp, #312
	add	r3, r1, r3
	ldr	r3, [r3, #-300]
	ror	r3, r3, #13
	eor	r2, r2, r3
	ldr	r3, [sp, #276]
	sub	r3, r3, #2
	lsl	r3, r3, #2
	add	r1, sp, #312
	add	r3, r1, r3
	ldr	r3, [r3, #-300]
	lsr	r3, r3, #10
	eor	r2, r2, r3
	ldr	r3, [sp, #276]
	sub	r3, r3, #7
	lsl	r3, r3, #2
	add	r1, sp, #312
	add	r3, r1, r3
	ldr	r3, [r3, #-300]
	add	r2, r2, r3
	ldr	r3, [sp, #276]
	sub	r3, r3, #15
	lsl	r3, r3, #2
	add	r1, sp, #312
	add	r3, r1, r3
	ldr	r3, [r3, #-300]
	ror	r1, r3, #25
	ldr	r3, [sp, #276]
	sub	r3, r3, #15
	lsl	r3, r3, #2
	add	r0, sp, #312
	add	r3, r0, r3
	ldr	r3, [r3, #-300]
	ror	r3, r3, #14
	eor	r1, r1, r3
	ldr	r3, [sp, #276]
	sub	r3, r3, #15
	lsl	r3, r3, #2
	add	r0, sp, #312
	add	r3, r0, r3
	ldr	r3, [r3, #-300]
	lsr	r3, r3, #3
	eor	r3, r3, r1
	add	r2, r2, r3
	ldr	r3, [sp, #276]
	sub	r3, r3, #16
	lsl	r3, r3, #2
	add	r1, sp, #312
	add	r3, r1, r3
	ldr	r3, [r3, #-300]
	add	r2, r2, r3
	ldr	r3, [sp, #276]
	lsl	r3, r3, #2
	add	r1, sp, #312
	add	r3, r1, r3
	str	r2, [r3, #-300]
	ldr	r3, [sp, #276]
	add	r3, r3, #1
	str	r3, [sp, #276]
.L4:
	ldr	r3, [sp, #276]
	cmp	r3, #63
	bls	.L5
	ldr	r3, [sp]
	ldr	r3, [r3]
	str	r3, [sp, #308]
	ldr	r3, [sp]
	ldr	r3, [r3, #4]
	str	r3, [sp, #304]
	ldr	r3, [sp]
	ldr	r3, [r3, #8]
	str	r3, [sp, #300]
	ldr	r3, [sp]
	ldr	r3, [r3, #12]
	str	r3, [sp, #296]
	ldr	r3, [sp]
	ldr	r3, [r3, #16]
	str	r3, [sp, #292]
	ldr	r3, [sp]
	ldr	r3, [r3, #20]
	str	r3, [sp, #288]
	ldr	r3, [sp]
	ldr	r3, [r3, #24]
	str	r3, [sp, #284]
	ldr	r3, [sp]
	ldr	r3, [r3, #28]
	str	r3, [sp, #280]
	mov	r3, #0
	str	r3, [sp, #276]
	b	.L6
.L7:
	ldr	r3, [sp, #292]
	ror	r2, r3, #26
	ldr	r3, [sp, #292]
	ror	r3, r3, #21
	eor	r2, r2, r3
	ldr	r3, [sp, #292]
	ror	r3, r3, #7
	eor	r2, r2, r3
	ldr	r3, [sp, #280]
	add	r2, r2, r3
	ldr	r1, [sp, #292]
	ldr	r3, [sp, #288]
	and	r1, r1, r3
	ldr	r3, [sp, #292]
	mvn	r0, r3
	ldr	r3, [sp, #284]
	and	r3, r3, r0
	eor	r3, r3, r1
	add	r2, r2, r3
	ldr	r1, .L8
	ldr	r3, [sp, #276]
	ldr	r3, [r1, r3, lsl #2]
	add	r2, r2, r3
	ldr	r3, [sp, #276]
	lsl	r3, r3, #2
	add	r1, sp, #312
	add	r3, r1, r3
	ldr	r3, [r3, #-300]
	add	r3, r2, r3
	str	r3, [sp, #272]
	ldr	r3, [sp, #308]
	ror	r2, r3, #30
	ldr	r3, [sp, #308]
	ror	r3, r3, #19
	eor	r2, r2, r3
	ldr	r3, [sp, #308]
	ror	r3, r3, #10
	eor	r2, r2, r3
	ldr	r1, [sp, #308]
	ldr	r3, [sp, #304]
	and	r1, r1, r3
	ldr	r0, [sp, #308]
	ldr	r3, [sp, #300]
	and	r3, r3, r0
	eor	r1, r1, r3
	ldr	r0, [sp, #304]
	ldr	r3, [sp, #300]
	and	r3, r3, r0
	eor	r3, r3, r1
	add	r3, r2, r3
	str	r3, [sp, #268]
	ldr	r3, [sp, #284]
	str	r3, [sp, #280]
	ldr	r3, [sp, #288]
	str	r3, [sp, #284]
	ldr	r3, [sp, #292]
	str	r3, [sp, #288]
	ldr	r2, [sp, #296]
	ldr	r3, [sp, #272]
	add	r3, r2, r3
	str	r3, [sp, #292]
	ldr	r3, [sp, #300]
	str	r3, [sp, #296]
	ldr	r3, [sp, #304]
	str	r3, [sp, #300]
	ldr	r3, [sp, #308]
	str	r3, [sp, #304]
	ldr	r2, [sp, #272]
	ldr	r3, [sp, #268]
	add	r3, r2, r3
	str	r3, [sp, #308]
	ldr	r3, [sp, #276]
	add	r3, r3, #1
	str	r3, [sp, #276]
.L6:
	ldr	r3, [sp, #276]
	cmp	r3, #63
	bls	.L7
	ldr	r3, [sp]
	ldr	r2, [r3]
	ldr	r3, [sp, #308]
	add	r2, r2, r3
	ldr	r3, [sp]
	str	r2, [r3]
	ldr	r3, [sp]
	add	r3, r3, #4
	ldr	r2, [sp]
	add	r2, r2, #4
	ldr	r1, [r2]
	ldr	r2, [sp, #304]
	add	r2, r1, r2
	str	r2, [r3]
	ldr	r3, [sp]
	add	r3, r3, #8
	ldr	r2, [sp]
	add	r2, r2, #8
	ldr	r1, [r2]
	ldr	r2, [sp, #300]
	add	r2, r1, r2
	str	r2, [r3]
	ldr	r3, [sp]
	add	r3, r3, #12
	ldr	r2, [sp]
	add	r2, r2, #12
	ldr	r1, [r2]
	ldr	r2, [sp, #296]
	add	r2, r1, r2
	str	r2, [r3]
	ldr	r3, [sp]
	add	r3, r3, #16
	ldr	r2, [sp]
	add	r2, r2, #16
	ldr	r1, [r2]
	ldr	r2, [sp, #292]
	add	r2, r1, r2
	str	r2, [r3]
	ldr	r3, [sp]
	add	r3, r3, #20
	ldr	r2, [sp]
	add	r2, r2, #20
	ldr	r1, [r2]
	ldr	r2, [sp, #288]
	add	r2, r1, r2
	str	r2, [r3]
	ldr	r3, [sp]
	add	r3, r3, #24
	ldr	r2, [sp]
	add	r2, r2, #24
	ldr	r1, [r2]
	ldr	r2, [sp, #284]
	add	r2, r1, r2
	str	r2, [r3]
	ldr	r3, [sp]
	add	r3, r3, #28
	ldr	r2, [sp]
	add	r2, r2, #28
	ldr	r1, [r2]
	ldr	r2, [sp, #280]
	add	r2, r1, r2
	str	r2, [r3]
	nop
	add	sp, sp, #312
	@ sp needed
	bx	lr
.L9:
	.align	2
.L8:
	.word	k
	.size	sha256_block, .-sha256_block
	.section	.rodata
	.align	2
.LC0:
	.ascii	"-- Programa SHA2  -  PID (%d) --\012\000"
	.align	2
.LC1:
	.ascii	"Iteracio (%d) String predefinida: \012\000"
	.align	2
.LC2:
	.ascii	"(%d)\011 %x \012\000"
	.align	2
.LC3:
	.ascii	"\012\000"
	.align	2
.LC4:
	.ascii	"Dades aleatories: \012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 184
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #188
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	mov	r0, r3
	bl	GARLIC_nice
	ldr	r3, [sp, #4]
	cmp	r3, #0
	bge	.L11
	mov	r3, #0
	str	r3, [sp, #4]
	b	.L12
.L11:
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ble	.L12
	mov	r3, #3
	str	r3, [sp, #4]
.L12:
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L26
	bl	GARLIC_printf
	mov	r3, #1
	str	r3, [sp, #172]
	mov	r3, #0
	str	r3, [sp, #180]
	b	.L13
.L14:
	ldr	r2, [sp, #172]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #1
	str	r3, [sp, #172]
	ldr	r3, [sp, #180]
	add	r3, r3, #1
	str	r3, [sp, #180]
.L13:
	ldr	r2, [sp, #180]
	ldr	r3, [sp, #4]
	cmp	r2, r3
	blt	.L14
	mov	r3, #0
	str	r3, [sp, #176]
	b	.L15
.L24:
	ldr	r3, .L26+4
	str	r3, [sp, #12]
	ldr	r3, .L26+8
	str	r3, [sp, #16]
	ldr	r3, .L26+12
	str	r3, [sp, #20]
	ldr	r3, .L26+16
	str	r3, [sp, #24]
	ldr	r3, .L26+20
	str	r3, [sp, #28]
	ldr	r3, .L26+24
	str	r3, [sp, #32]
	ldr	r3, .L26+28
	str	r3, [sp, #36]
	ldr	r3, .L26+32
	str	r3, [sp, #40]
	mov	r3, #0
	str	r3, [sp, #180]
	b	.L16
.L17:
	ldr	r2, [sp, #180]
	ldr	r3, .L26+36
	smull	r1, r3, r2, r3
	asr	r1, r3, #3
	asr	r3, r2, #31
	sub	r3, r1, r3
	mov	r1, #26
	mul	r3, r1, r3
	sub	r3, r2, r3
	and	r3, r3, #255
	add	r3, r3, #97
	and	r1, r3, #255
	add	r2, sp, #108
	ldr	r3, [sp, #180]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	ldr	r3, [sp, #180]
	add	r3, r3, #1
	str	r3, [sp, #180]
.L16:
	ldr	r3, [sp, #180]
	cmp	r3, #63
	ble	.L17
	add	r2, sp, #12
	add	r3, sp, #108
	mov	r1, r2
	mov	r0, r3
	bl	sha256_block
	ldr	r1, [sp, #176]
	ldr	r0, .L26+40
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #180]
	b	.L18
.L19:
	ldr	r3, [sp, #180]
	lsl	r3, r3, #2
	add	r2, sp, #184
	add	r3, r2, r3
	ldr	r3, [r3, #-172]
	mov	r2, r3
	ldr	r1, [sp, #180]
	ldr	r0, .L26+44
	bl	GARLIC_printf
	ldr	r3, [sp, #180]
	add	r3, r3, #1
	str	r3, [sp, #180]
.L18:
	ldr	r3, [sp, #180]
	cmp	r3, #7
	ble	.L19
	ldr	r0, .L26+48
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #180]
	b	.L20
.L21:
	bl	GARLIC_random
	mov	r3, r0
	and	r1, r3, #255
	add	r2, sp, #44
	ldr	r3, [sp, #180]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	ldr	r3, [sp, #180]
	add	r3, r3, #1
	str	r3, [sp, #180]
.L20:
	ldr	r3, [sp, #180]
	cmp	r3, #63
	ble	.L21
	add	r2, sp, #12
	add	r3, sp, #44
	mov	r1, r2
	mov	r0, r3
	bl	sha256_block
	ldr	r0, .L26+52
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #180]
	b	.L22
.L23:
	ldr	r3, [sp, #180]
	lsl	r3, r3, #2
	add	r2, sp, #184
	add	r3, r2, r3
	ldr	r3, [r3, #-172]
	mov	r2, r3
	ldr	r1, [sp, #180]
	ldr	r0, .L26+44
	bl	GARLIC_printf
	ldr	r3, [sp, #180]
	add	r3, r3, #1
	str	r3, [sp, #180]
.L22:
	ldr	r3, [sp, #180]
	cmp	r3, #7
	ble	.L23
	ldr	r0, .L26+48
	bl	GARLIC_printf
	ldr	r3, [sp, #176]
	add	r3, r3, #1
	str	r3, [sp, #176]
.L15:
	ldr	r2, [sp, #176]
	ldr	r3, [sp, #172]
	cmp	r2, r3
	blt	.L24
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #188
	@ sp needed
	ldr	pc, [sp], #4
.L27:
	.align	2
.L26:
	.word	.LC0
	.word	1779033703
	.word	-1150833019
	.word	1013904242
	.word	-1521486534
	.word	1359893119
	.word	-1694144372
	.word	528734635
	.word	1541459225
	.word	1321528399
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
