# GarlicOS
En esta práctica de Estructura de Sistemas Operativos se implementará un sistema operativo
pedagógico capaz de realizar carga dinámica de programas en memoria y ejecución
concurrente de los procesos correspondientes.
Aparte del marco teórico de la asignatura, será necesario profundizar en los
conocimientos propios de la plataforma hardware sobre la que se tiene que implementar
este sistema operativo, es decir, procesadores ARM, zonas de memoria, procesadores
gráficos y otros controladores de E/S de la NDS.
Como objetivo metodológico se establece un modelo de trabajo en equipo basado en
el sistema de control de versiones git, en el que los componentes de cada grupo de
prácticas tienen que distribuirse las tareas y aprender a fusionar las distintas partes del
proyecto en un programa (sistema operativo) único.

## Resumen de la práctica
La práctica consistirá en realizar un microkernel de sistema operativo para la plataforma
NDS, que permita cargar y ejecutar concurrentemente hasta 15 procesos de usuario, más
un proceso específico de control del propio sistema operativo.
Dichos procesos podrán realizar cálculos y escribir información en una ventana de texto
dedicada a cada proceso (16 ventanas de 24 filas por 32 columnas cada una). También
podrán retardar su ejecución durante cierto tiempo.
Adicionalmente, se prevé la posibilidad de realizar entrada de información (lectura de
texto) por medio de un controlador de entrada/salida que permita simular un teclado.

## Autores
- ProgP: Albert Cañadilla 
- ProgM: Gerard Pascual
- ProgG: Jaume Tello
- ProgT: Germán Puerto
