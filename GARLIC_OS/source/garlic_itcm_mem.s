@;==============================================================================
@;
@;	"garlic_itcm_mem.s":	código de rutinas de soporte a la carga de
@;							programas en memoria (version 1.0)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2

	.global _gm_reubicar
	@; rutina para interpretar los 'relocs' de un fichero ELF y ajustar las
	@; direcciones de memoria correspondientes a las referencias de tipo
	@; R_ARM_ABS32, restando la dirección de inicio de segmento y sumando
	@; la dirección de destino en la memoria;
	@;Parámetros:
	@; R0: dirección inicial del buffer de fichero (char *fileBuf)
	@; R1: dirección de inicio de segmento (unsigned int pAddr)
	@; R2: dirección de destino en la memoria (unsigned int *dest)
	@;Resultado:
	@; cambio de las direcciones de memoria que se tienen que ajustar
_gm_reubicar:
    push {r3-r12, lr}
    
    @; Obtenir els valors de l'encapçalament ELF
    
    @; Desplaçament de la taula de seccions (secció d'encapçalament)
    ldr r4, [r0, #32]			@; r4 = e_shoff (posició 32) = (Word de 4 bytes)
    
    @; Mida de cada entrada de la taula de seccions
    ldrh r5, [r0, #46]        	@; r5 = e_shentsize (posició 46) = (HalfWord de 2 bytes)  ldrh
    
    @; Nombre d'entrades de la taula de seccions
    ldrh r6, [r0, #48]       	@; r6 = e_shnum (posició 48) = (HalfWord de 2 bytes)  ldrh

    @; Inicialització del comptador del bucle de seccions
    mov r3, #0  
    
.For_taula_seccions:
    
    @; Recorregut de totes les seccions amb un bucle
    mul r7, r3, r5             	@; r7 = índex de seccions (r3) * mida de seccions e_shentsize (r5)
    add r8, r7, #4             	
    
    add r8, r8, r4            	@; r8 = (r7 + 4) + desplaçament en el buffer -> per obtenir el tipus 
    
    @; r8 = (índex de seccions * (mida de seccions + 4 (posició del tipus a la taula))) + r4 (e_shoff)
    
    add r3, r3, #1             	@; Actualització del comptador r3++
    cmp r3, r6                 	@; (r3 > r6) Final del bucle? 
    bgt .Fi
    
    ldr r9, [r0, r8]           	@; r9 = tipus secció 
    cmp r9, #9                 	@; sh_type: tipus de la secció; les seccions de reubicadors són de tipus 9 (SHT_REL),
    bne .For_taula_seccions    	@; (r9 != 9) --> continuem buscant
    
    add r8, r7, #20            	@; r8 = r7 (índex de seccions (r3) * mida de seccions e_shentsize (r5)) + 20 
    add r8, r8, r4             	@; r8 conté el desplaçament en el búfer de la mida de la secció + e_shoff (r4)
    
    @; (r7 + 20 + e_shoff)
    
    ldr r10, [r0, r8]          	@; r10 = sh_size 
    mov r10, r10, lsr #3       	@; r10 = nombre d'entrades a l'estructura de reubicadors 
								@; lsr #3 = dividir entre 8 bytes (2^3=8)
    
    add r8, r7, #16            	@; r8 = r7 (índex de seccions (r3) * mida de seccions e_shentsize (r5)) + 16
    add r8, r8, r4             	@; r8 = conté el desplaçament en el búfer per a la posició del primer byte de la secció (r7 + 16 + e_shoff (r4))
    ldr r11, [r0, r8]          	@; r11 = sh_offset 
    
    @; Analitzar quins reubicadors són de tipus R_ARM_ABS32 (tipus = 2)
    mov r9, #0 				   	@; índex bucle reubicadors 
    
.For_estructura_reubicadors:
    mov r8, #8                 	@; r8 = 8
    
    @; Moure's pel reubicador
    mul r7, r9, r8             	@; r7 = índex de reubicadors (r9) * mida estructura reubicadors (r8)
    add r7, r7, r11            	@; r11 = sh_offset
    add r8, r7, #4             	@; r8 = desplaçament pel búfer (r7 + 4 + sh_offset (r11))
    @; obtenir r_info
    
    add r9, r9, #1             	@; Actualització del comptador r9++
    cmp r9, r10                	@; (r9 > r10) -> fins processar totes les entrades
    bgt .For_taula_seccions
    
    ldrb r12, [r0, r8]         	@; r12 = r_info (volem obtenir els 8 bits baixos, indica el tipus)
    cmp r12, #2                	@; (r12 != 2) 
    bne .For_estructura_reubicadors
    
    ldr r12, [r0, r7]          	@; r12 = r_offset
    
    @; Obtenir adreça de memòria destinació --> adreça memòria corresponent a R_ARM_ABS32 - adreça inici segment (r1) + adreça destinació memòria (r2)
    sub r12, r12, r1
    add r12, r12, r2
    
    @; str r12, [r0, r7] guardem la nova adreça a r_offset
    ldr r8, [r12]              	@; Agafem el valor d'aquesta posició
    
    @; Obtenir el contingut de l'adreça destinació i realitzar el càlcul anterior
    sub r8, r8, r1 
    add r8, r8, r2
    
    str r8, [r12]              	@; Guardem el contingut actualitzat novament a la seva posició
    
    cmp r9, r10                	@; Comprovem el comptador si hem arribat a processar totes les entrades
    bge .For_taula_seccions
    
    b .For_estructura_reubicadors
    
.Fi:
    pop {r3-r12, pc}
	

.end