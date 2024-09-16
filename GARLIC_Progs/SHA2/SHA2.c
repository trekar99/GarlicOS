/*------------------------------------------------------------------------------

	"SHA256.c" : programa usuari pel sistema operatiu GARLIC 1.0;
	
	Calcul del SHA256 d'un string d'usuari i aleatori, 10^arg iteracions

--------------------------------------------------------------------------------

Links referencies:

	Informacio basica 
		SHA_256 - FIPS 180-2, Secure Hash Standard (superseded Feb. 25, 2004)    https://csrc.nist.gov/files/pubs/fips/180-2/final/docs/fips180-2.pdf
		A Definitive Guide to Learn The SHA-256 (Secure Hash Algorithms) 		 https://www.simplilearn.com/tutorials/cyber-security-tutorial/sha-256-algorithm
	Eina util 
		10015 Tools - https://10015.io/tools/sha256-encrypt-decrypt
	Codi C 
		https://github.com/B-Con/crypto-algorithms/blob/master/sha256.c
		https://opensource.apple.com/source/clamav/clamav-158/clamav.Bin/clamav-0.98/libclamav/sha256.c.auto.html
		https://github.com/intel/tinycrypt/blob/master/lib/source/sha256.c
		https://codereview.stackexchange.com/questions/182812/self-contained-sha-256-implementation-in-c
 
------------------------------------------------------------------------------*/

#include <GARLIC_API.h>	 /* definicon de las funciones API de GARLIC */
#include <stdio.h>     
#include <string.h>    // Include de l'encapcalament per a la manipulacio de cadenes de caracters, que conte funcions com strlen.
#include <stdint.h>    // Include de l'encapcalament per a tipus de dades estandard d'amplada fixa, com uint32_t, que son utils per a operacions de baix nivell amb bytes i bits.


// Constants especi­fiques de l'algorisme SHA-256
static const uint32_t k[] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

#define SHA256_BLOCK_SIZE 64

// Funcio auxiliar per rotar bits a l'esquerra
#define ROTLEFT(x, c) ((x << c) | (x >> (32 - c)))

// Funcio auxiliar per fer l'aritmetica dels elements de l'array w
#define CH(x, y, z) ((x & y) ^ (~x & z))
#define MAJ(x, y, z) ((x & y) ^ (x & z) ^ (y & z))

// Funcions auxiliars per a les operacions bit a bit
#define SIGMA0(x) (ROTLEFT(x, 2) ^ ROTLEFT(x, 13) ^ ROTLEFT(x, 22))
#define SIGMA1(x) (ROTLEFT(x, 6) ^ ROTLEFT(x, 11) ^ ROTLEFT(x, 25))
#define sigma0(x) (ROTLEFT(x, 7) ^ ROTLEFT(x, 18) ^ (x >> 3))
#define sigma1(x) (ROTLEFT(x, 17) ^ ROTLEFT(x, 19) ^ (x >> 10))

// Funcio auxiliar per calcular el SHA-256 d'un bloc de dades
void sha256_block(const unsigned char *random_message, unsigned int *hash) {
    unsigned int w[64];
    unsigned int a, b, c, d, e, f, g, h;
    unsigned int i;

    for (i = 0; i < 16; i++)
        w[i] = ((unsigned int)random_message[i * 4] << 24) | ((unsigned int)random_message[i * 4 + 1] << 16) |
               ((unsigned int)random_message[i * 4 + 2] << 8) | ((unsigned int)random_message[i * 4 + 3]);

    for (; i < 64; i++)
        w[i] = sigma1(w[i - 2]) + w[i - 7] + sigma0(w[i - 15]) + w[i - 16];

    a = hash[0];
    b = hash[1];
    c = hash[2];
    d = hash[3];
    e = hash[4];
    f = hash[5];
    g = hash[6];
    h = hash[7];

    for (i = 0; i < 64; i++) {
        unsigned int temp1 = h + SIGMA1(e) + CH(e, f, g) + k[i] + w[i];
        unsigned int temp2 = SIGMA0(a) + MAJ(a, b, c);
        h = g;
        g = f;
        f = e;
        e = d + temp1;
        d = c;
        c = b;
        b = a;
        a = temp1 + temp2;
    }

    hash[0] += a;
    hash[1] += b;
    hash[2] += c;
    hash[3] += d;
    hash[4] += e;
    hash[5] += f;
    hash[6] += g;
    hash[7] += h;
}


int _start(int arg) {

	int i, j, num_iteracions;
	
	if (arg < 0) arg = 0;			// Limitar valor maximmm 
	else if (arg > 3) arg = 3;		// Limitar valor minim de l'argument
	
	// Escriure missatge inicial
	GARLIC_printf("-- Programa SHA2  -  PID (%d) --\n", GARLIC_pid());
	
	// Calcular el nombre d'iteracions 10 elevat a arg
	num_iteracions = 1;
    for (i = 0; i < arg; i++) {
        num_iteracions *= 10;
    }

    for (j = 0; j < num_iteracions; j++) {
        unsigned char random_message[SHA256_BLOCK_SIZE], predefined_message[SHA256_BLOCK_SIZE]; // Bloc de dades de 64 bytes per strings random i predefinit
        unsigned int hash[8]; // Valors inicials del hash
		
        // Inicialitzar els valors del hash
        hash[0] = 0x6a09e667;
        hash[1] = 0xbb67ae85;
        hash[2] = 0x3c6ef372;
        hash[3] = 0xa54ff53a;
        hash[4] = 0x510e527f;
        hash[5] = 0x9b05688c;
        hash[6] = 0x1f83d9ab;
        hash[7] = 0x5be0cd19;
		
        // Generar la string predefinida comencant amb l'alfabet i repetint-se fins que sigui de mida SHA256_BLOCK_SIZE
		for (i = 0; i < SHA256_BLOCK_SIZE; i++) {
			predefined_message[i] = 'a' + (i % 26); // Utilitza l'alfabet ciclicament
		}

        // Processar el bloc de dades amb la funcio SHA-256
		sha256_block(predefined_message, hash);

		// Imprimir el resultat amb la string predefinida
		GARLIC_printf("Iteracio (%d) String predefinida: \n", j);
		for (i = 0; i < 8; i++) {
			GARLIC_printf("(%d)\t %08x \n",i , hash[i]);
		}
		GARLIC_printf("\n");
		
		// Generar dades pseudoaleatories per al bloc de dades
		for (i = 0; i < SHA256_BLOCK_SIZE; i++) {
			random_message[i] = (unsigned char)(GARLIC_random() & 0xFF); // Utilitzar la funcio GARLIC_random()
		}

        // Processar el bloc de dades amb la funco SHA-256
        sha256_block(random_message, hash);

        // Imprimir el resultat
        GARLIC_printf("Dades aleatories: \n");
        for (i = 0; i < 8; i++) {
            GARLIC_printf("(%d)\t %08x \n",i , hash[i]);
        }
        GARLIC_printf("\n");
    }

    return 0;
}