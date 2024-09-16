@;=== garlic_tecl_incl.i: definiciones auxiliares para programador teclado  ===

@; Variables para poner baldosas del input string
INPUT_LINE = 3
INPUT_COLS = 64					@; HALFWORD (32*2)
INPUT_SITE = INPUT_LINE * INPUT_COLS

@; Límites
LIM_LEFT = 1
LIM_RIGHT = 30

@; Colores
COLOR_WHITE = 0
COLOR_BLUE = 128
COLOR_PINK = 256
COLOR_SALMON = 384

@; Tiles
ASCII_TILE = 95

@; MÀSCARES per als camps de bits de valors 1:19:12
MASK_SIGN = 0x80000000				@; bit 31:		signe
MASK_INT  = 0x7FFFF000				@; bits 30..12:	part entera
MASK_FRAC =	0x00000FFF				@; bits 11..0:	part fraccionària

