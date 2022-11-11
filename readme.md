# Práctico 9 - Electrónica II 2022 para ingeniería electrónica - Circuitos secuenciales

El objetivo de este práctico es familiarizarse con los circuitos lógicos combinacionales sincrónicos y su implementación en VHDL. Deberás implementar los siguientes circuitos:

- Flip-flop D.
- Contador Jhonson.
- Contador sincrónico ascendente con carga.
- Detector de flanco ascendente.
- Medidor de distancia entre pulsos.
- Registro de desplazamiento.

**Importante: El único elemento de memoria permitido es el FFD, que deberá ser resuelto en primer lugar**. En el archivo `ffd.vhd` se define además el paquete `work.ffd` que incluye el componente ffd, y este paquete es usado en todos los otros puntos, así que no es necesario
definir el componente ffd sino solamente usarlo (`u1 : ffd generic map(ancho=>...) port map (rst=>...,hab=>...,D=>...,clk=>...,Q=>...);`)

## Visualisación de formas de onda

Este práctico incluye previsión para visualización de formas de onda de la simulación. Para ello debes instalar *en msys2* el programa gtkwave.
Para ello recomiendo que en primer lugar actualices el sistema msys2 a su última versión. Abre la consola de msys2 (MSYS2 MSYS) desde el menú inicio o el cuadro de búsqueda (⊞+Q, msys2 y elegir entre las coincidencias). Luego ejecuta el siguiente comando para actualizar los paquetes instalados a su última version (debes aceptar la actualización). Repite este comando hasta que diga que no hay más que actualizar.
```
pacman -Syu
```
Luego instala gtkwave con el comando
```
pacman -S mingw-w64-i686-gtkwave
```

Podrás ver la simulación aún cuando el banco de prueba detecte errores, pero en ese caso podrá terminar en forma prematura. Para ver las ondas del banco de pruebas del flip-flop D por ejemplo usa `mingw32-make wav-ffd`.

## Flip-flop tipo D (ffd.vhd).

Debes implementar un flip-flop tipo D (FFD) de ancho variable (N) activado por flanco ascendente con habilitación y reset asincrónico.

```
   ┌──────────────────────────┐
───┤rst                       │
   │                          │
═══╡D(N-1 .. 0)    Q(N-1 .. 0)╞═══
   │                          │
───┤hab                       │
   │                          │
───┤> clk                     │
   └──────────────────────────┘


╔════════════════ Diagrama de tiempo. Ejemplo para ancho = 4. ════════════════╗
║      ┌──────┬──────────────┬─────┬─────────────────┬─────┬─────┬─────┬────  ║
║ Q    ┤ UUUU │    0000      │1010 │      1011       │1101 │1110 │1111 │0000  ║
║      └──────┴──────────────┴─────┴─────────────────┴─────┴─────┴─────┴────  ║
║         ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐    ║
║ Clk  ┐  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │    ║
║      └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──  ║
║      ┌───────────────────────┬─────┬─────┬─────┬─────┬─────┬─────┬────────  ║
║ D    ┤      1010             │1011 │0101 │1100 │1101 │1110 │1111 │  0000    ║
║      └───────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴────────  ║
║            ┌──────────┐                                                     ║
║ Rst  ┐     │          │                                                     ║
║      └─────┘          └───────────────────────────────────────────────────  ║
║                   ┌─────────────────┐          ┌──────────────────────────  ║
║ Hab  ┐            │                 │          │                            ║
║      └────────────┘                 └──────────┘                            ║
╚═════════════════════════════════════════════════════════════════════════════╝
```

Nota: El ancho del FFD es *un parámetro* y puede tomar cualquier valor, no necesariamente el valor dado en el ejemplo.
 
Para correr las pruebas correspondientes al FFD usar `mingw32-make ffd` (windows) o `make ffd` (linux). Para ver las ondas de la simulación `mingw32-make wav-ffd`.

## Contador Johnson (johnson.vhd)

El contador johnson es un tipo de contador de anillo (porque consiste en una cadena de FFD realimentada) en el cual se produce una sola transición por ciclo de reloj. Es un más rápido y simple que un contador binario al costo de usar $N$ FF para $2N$ estados, cuando un contador binario de $N$ FF tiene $2^N$ estados. Las entradas son reset asincrónico (rst), habilitación (hab) y reloj (clk). Las salidas son cuenta (Q, en código Johnson) y desborde (Co). La salida de desborde Co='1' para el último código ("10..0"). 

```
   ┌──────────────────────────┐
───┤rst                       │
   │                        Co├───
═══╡D(N-1 .. 0)               │
   │                          │
───┤carga                     │
   │                          │
───┤hab                       │
   │               Q(N-1 .. 0)╞═══
───┤> clk                     │
   └──────────────────────────┘


╔═════════════════ Diagrama de tiempo. Ejemplo para ancho = 4. ══════════════════╗
║                                                                   ┌─────┐      ║
║ Co      ┐                                                         │     │      ║
║         └─────────────────────────────────────────────────────────┘     └────  ║
║         ┌──────┬──────────────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───── ║
║ Q       ┤ UUUU │        0000  │0001 │0011 │0111 │1111 │1110 │1100 │1000 │0000  ║
║         └──────┴──────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴───── ║
║            ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐    ║
║ clk     ┐  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │    ║
║         └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──  ║
║                             ┌────────────────────────────────────────────────  ║
║ hab     ┐                   │                                                  ║
║         └───────────────────┘                                                  ║
║               ┌─────┐                                                          ║
║ rst     ┐     │     │                                                          ║
║         └─────┘     └────────────────────────────────────────────────────────  ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

Para correr las pruebas correspondientes al FFD usar `mingw32-make johnson` (windows) o `make johnson` (linux). Para ver las ondas de la simulación `mingw32-make wav-johnson`.


## Contador (contador.vhd)

Es un contador sincrónico ascendente con tamaño de palabra (N) configurable. Sus entradas son reset asincrónico (rst), reloj (clk), habilitación de cuenta (hab) y carga sincrónica (carga, D). Sus salidas son cuenta (Q) y desborde (Co). Siempre que rst='1' la cuenta permanecerá en 0 y las demás señales carecerán de efecto. Si hab='1' y carga='1', con el siguiente flanco ascendente la cuenta actual Q pasará a tomar el valor de la entrada D. Si hab='1' y carga='0', con cada flanco ascendente la cuanta Q tomará el valor Q+1 hasta llegar al valor máximo $2^N-1$, pasando en el siguiente flanco a tomar el valor '0'. La salida de desborde Co tomará el valor '1' cuando la cuenta tome al valor máximo.


```
   ┌──────────────────────────┐
───┤rst                       │
   │                        Co├───
═══╡D(N-1 .. 0)               │
   │                          │
───┤carga                     │
   │                          │
───┤hab                       │
   │               Q(N-1 .. 0)╞═══
───┤> clk                     │
   └──────────────────────────┘


╔═════════════════ Diagrama de tiempo. Ejemplo para ancho = 4. ══════════════════╗
║                                                                   ┌─────┐      ║
║ Co      ┐                                                         │     │      ║
║         └─────────────────────────────────────────────────────────┘     └────  ║
║         ┌──────┬────────────────────┬─────┬─────┬─────┬─────┬─────┬─────┬───── ║
║ Q       ┤ UUUU │        0000        │0001 │0010 │0011 │1101 │1110 │1111 │0000  ║
║         └──────┴────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴───── ║
║            ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐    ║
║ clk     ┐  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │    ║
║         └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──  ║
║                                ┌─────────────────────────────────────────────  ║
║ hab     ┐                      │                                               ║
║         └──────────────────────┘                                               ║
║         ┌────────────────────────────────────────────────────────────────────  ║
║ D       ┤                                1101                                  ║
║         └────────────────────────────────────────────────────────────────────  ║
║                                                  ┌─────┐                       ║
║ carga   ┐                                        │     │                       ║
║         └────────────────────────────────────────┘     └─────────────────────  ║
║               ┌─────┐                                                          ║
║ rst     ┐     │     │                                                          ║
║         └─────┘     └────────────────────────────────────────────────────────  ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

Para correr las pruebas correspondientes al timer usar `mingw32-make contador` (windows) o `make contador` (linux). Para ver las ondas de la simulación `mingw32-make wav-contador`.

## Registro de desplazamiento de entrada serie y salida paralela (sipo.vhd).

Es un registro de desplazamiento a la derecha sincrónico de ancho configurable con entrada serie y salida paralela. Cuenta con entradas de reset asincrónica y habilitación de reloj. Cuando la habilitación es '1', con cada flanco ascendente de reloj el bit 0 del registro toma el valor que tenía el bit 1, en general el bit *k* toma el valor que tenía el bit *k+1* y el bit más significativo toma el valor presente en la entrada serie. 

Nota: Usar como elemento de memoria el FFD definido en el primer apartado, instanciado como componente. No se admite ninguna otra memoria, únicamente se admiten procesos que generen lógica combinacional.

```
   ┌──────────────────────────┐
───┤rst                       │
   │                          │
───┤entrada                   │
   │               Q(N-1 .. 0)╞═══
───┤hab                       │
   │                          │
───┤> clk                     │
   └──────────────────────────┘


╔══════════════════ Diagrama de tiempo. Ejemplo para ancho = 4. ═════════════════╗
║         ┌──────┬────────┬─────┬─────┬─────┬──────────────────────────────────  ║
║ Q       ┤ UUUU │0000    │1000 │0100 │0010 │               1001                 ║
║         └──────┴────────┴─────┴─────┴─────┴──────────────────────────────────  ║
║            ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐    ║
║ Clk     ┐  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │    ║
║         └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──  ║
║                    ┌────┐            ┌────┐                                    ║
║ entrada ┐          │    │            │    │                                    ║
║         └──────────┘    └────────────┘    └──────────────────────────────────  ║
║               ┌──────┐                                                         ║
║ Rst     ┐     │      │                                                         ║
║         └─────┘      └───────────────────────────────────────────────────────  ║
║                      ┌────────────────────┐                                    ║
║ Hab     ┐            │                    │                                    ║
║         └────────────┘                    └──────────────────────────────────  ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

Para correr las pruebas correspondientes al timer usar `mingw32-make sipo` (windows) o `make sipo` (linux). Para ver las ondas de la simulación `mingw32-make wav-sipo`.

## Detector sincrónico de flanco ascendente (det_flanco.vhd).

El detector sincrónico de flanco genera un pulso en su salida en el primer flanco ascendente de reloj luego que su entrada cambia de '0' a '1'. Sus entradas son señal (D), reloj (clk), habilitación de reloj sincrónica (hab) y reset asincrónico (rst). Sus salidas son detección de flanco (flanco) y detección de flanco asincrónica (flanco_asinc).
La detección de flanco sincrónica depende solo del estado del detector y por lo tanto cambia solo en el flanco ascendente de reloj. La salida flanco_asinc toma el valor '1' cuando la salida sincrónica es '1', pero además toma el valor '1' si la señal de entrada toma el valor '1' y su valor el flanco de reloj anterior fue '0'.

```
   ┌──────────────────────────┐
───┤rst                       │
   │                          │
───┤D                   flanco├───
   │                          │
───┤hab           flanco_asinc├───
   │                          │
───┤> clk                     │
   └──────────────────────────┘


╔════════════════════════════════ Diagrama de tiempo. ═════════════════════════════════╗
║               ┌──────┐    ┌──────────┐      ┌─────────┐                ┌──────┐      ║
║ flanco_async  ┤  U   │    │          │      │         │                │      │      ║
║               └──────┴────┘          └──────┘         └────────────────┘      └────  ║
║               ┌──────┐                          ┌─────┐                 ┌─────┐      ║
║ flanco        ┤  U   │                          │     │                 │     │      ║
║               └──────┴──────────────────────────┘     └─────────────────┘     └────  ║
║                  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐    ║
║ clk           ┐  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │    ║
║               └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──  ║
║                                      ┌─────────────────────────────────────────────  ║
║ hab           ┐                      │                                               ║
║               └──────────────────────┘                                               ║
║                          ┌──────────┐      ┌────────────────────┐     ┌───┐          ║
║ D             ┐          │          │      │                    │     │   │          ║
║               └──────────┘          └──────┘                    └─────┘   └────────  ║
║                    ┌───┐                                                             ║
║ rst           ┐    │   │                                                             ║
║               └────┘   └───────────────────────────────────────────────────────────  ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
```

Para correr las pruebas correspondientes al timer usar `mingw32-make det_flanco` (windows) o `make det_flanco` (linux). Para ver las ondas de la simulación `mingw32-make wav-det_flanco`.


## Detector de tiempo entre pulsos (det_tiempo.vhd).

Es un detector que cuenta los flancos ascendentes de reloj desde el fin de un pulso positivo al inicio del siguiente. El tamaño de palabra del contador (N) es un parámetro genérico. Las entradas son reset asincrónico (rst), pulsos (D), reloj (clk) y habilitación de reloj (hab). Las salidas son tiempo (tiempo) y medición completa (med). El tiempo medido es el número de flancos ascendentes desde que D pasa de '1' a '0' hasta su regreso a '1'.

Mientras rst='1' la cuenta interna se mantiene en 0 al igual que las salida tiempo y med. Solo se aceptan flancos de reloj si hab='1'. En el flanco de reloj siguiente a la transición descendente de D un contador interno se inicializará en 1, incrementándose en cada flanco de reloj en que D='0'. Si se produce un desborde del contador entonces permanecerá en 0 hasta que D='1'. Al primer flanco de reloj con D='1' el valor del contador pasa a la salida tiempo y la salida med toma el valor '1'.   

```
   ┌──────────────────────────┐
───┤rst                       │
   │                       med├───
───┤pulso                     │
   │          tiempo(N-1 .. 0)╞═══
───┤hab                       │
   │                          │
───┤> clk                     │
   └──────────────────────────┘


╔══════════════════ Diagrama de tiempo. Ejemplo para ancho = 4. ═════════════════╗
║         ┌──────┬────────────────────────────────┬───────────────────────┬────  ║
║ tiempo  ┤ UUUU │              0000              │         0100          │0010  ║
║         └──────┴────────────────────────────────┴───────────────────────┴────  ║
║         ┌──────┐                                ┌─────┐                 ┌────  ║
║ med     ┤  U   │                                │     │                 │      ║
║         └──────┴────────────────────────────────┘     └─────────────────┘      ║
║            ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐    ║
║ clk     ┐  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │    ║
║         └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──  ║
║              ┌──────────┐                 ┌────────┐              ┌────────┐   ║
║ pulso   ┐    │          │                 │        │              │        │   ║
║         └────┘          └─────────────────┘        └──────────────┘        └─  ║
║               ┌┐                                                               ║
║ rst     ┐     ││                                                               ║
║         └─────┘└─────────────────────────────────────────────────────────────  ║
║         ──────────────────────────────────────────────┐     ┌────────────────  ║
║ hab                                                   │     │                  ║
║                                                       └─────┘                  ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

Para correr las pruebas correspondientes al timer usar `mingw32-make det_tiempo` (windows) o `make det_tiempo` (linux). Para ver las ondas de la simulación `mingw32-make wav-det_tiempo`.


## Entrega

Una vez los bloques pasen las pruebas y no existan elementos de memoria implícitos en procesos (excepto en los FFD) ejecutar el comando `mingw32-make entrega` (windows) o `make entrega` (linux). Si tiene éxito se generará el archivo para entregar `entrega-tp9.tar.gz` que deberás subir en la correspondiente tarea del aula virtual.

