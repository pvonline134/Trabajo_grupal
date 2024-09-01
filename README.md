# Tarea I: Introducción a diseño digital en HDL

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays
- **LUT4**: "look up table" de 4 bits de entrada
- **LUT5**: "look up table" de 5 bits de entrada

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.0 Descripción general del sistema

### 3.1 Subsistema 1
#### 1. Gray to binary
```SystemVerilog
module gray_to_binary(
     input  logic [3 : 0] gray,  // Entrada: Código Gray (4 bits)      
     output logic [3 : 0] binary, // Salida: Código Binario (N bits)
     output logic [3 : 0] leds // Salida: leds
    );

     // Lógica combinacional para la decodificació
    // gray_code a binary_code usando compuertas lógicas

    assign binary[3] = gray [3];
    assign binary[2] = gray [3] ^ gray [2];
    assign binary[1] = binary [2] ^ gray [1];
    assign binary[0] = binary [1] ^ gray [0];

endmodule
```
#### 2. Parámetros
`    gray_to_binary g2b (
        .gray(gray),
        .binary(binary)
     `
Se usó g2b como nombre de instancia.

#### 3. Entradas y salidas:
- `input  logic [3 : 0] gray`: La entrada de este subsistema son los 4 bits en gray (vienen del dip switch)
- `output logic [3 : 0] binary`: Para la salida se tienen los 4 bits  en binario (La salida "leds" es simplemente
  la negación de la salida "binary", esto debido a que la FPGA enciende los leds con 0)

#### 4. Criterios de diseño
Primeramente, se debe de comprender el algoritmo que transforma un número de 4 bits en gray a un número de 4 bits en binario, este algoritmo consiste en mantener el MSB y a cada bit del código binario generado se le suma en binario el siguiente bit adyacente del código gray y el acarreo se descarta.

Para 2 bits, dicha suma tiene un comportamiento de XOR ya que se tiene:

0+0=0

0+1=1

1+0=1

1+1=0

Es decir, por 2 bits en gray de entrada se recibe un bit de salida en binario, sin embargo, se ocupan 4 salidas en binario. Como se dijo con anterioridad, la salida en binario se le suma de manera binaria el siguiente bit en gray (partiendo desde el MSB hacia la derecha) es por eso que simplemente para lograr tener los 4 bits en binario de salida se colocan XORs con una patilla saliendo del resultado del XOR anterior y la otra con el bit en gray adyacente. Cabe destacar que como el MSB se mantiene en ambos códigos (Gray y Binario) la entrada en gray del MSB es igual a la salida del MSB del binario. a continuación, se ejemplifica en el siguiente diagrama:

![image](https://github.com/user-attachments/assets/d50cb5aa-92d4-42a6-82a7-fbfb3cd26835)

Como se puede observar se recibe una entrada en gray (en este caso 1010) y al pasarlo por el convertidor de gray a binario mencionado anteriormente, se obtiene el resultado en binario (1100) dicho resultado en binario se ve reflejado en los leds, donde un led rojo representa un 1 y un led apagado representa un 0.

#### 5. Testbench
Una vez codificada la función que convierte de gray a binary se procedieron a hacer las pruebas en el Testbench y probar su funcionamiento. 
```SystemVerilog
module tb_gray_to_binary_leds;

    // señales Testbench 
    logic [3:0] gray;    // Test input: Gray coe
    logic [3:0] binary;  // Test output: Binary 

    // Inicializando el modulo
    gray_to_binary_leds dut (
        .gray(gray),
        .binary(binary)
    );

    // iniciando simulaciones
    initial begin
        // Display con el nombre de la entrada y salida
        $display("Gray Code | Binary Code ");
        $display("----------|-------------");

        // se testean los valores de la tabla brindada en el enunciado
        //así mismo se imprimen en pantalla para observar los resultados.
        gray = 4'b0000; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0001; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0011; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0010; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0110; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0111; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0101; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0100; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1100; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1101; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1111; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1110; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1010; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1011; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1001; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1000; #10;
        $display("%b   | %b", gray, binary);

        $finish;  //fin de la simulación
    end

    initial begin
        $dumpfile("tb_gray_to_binary_leds.vcd");
        $dumpvars(0,tb_gray_to_binary_leds);
    end

endmodule
```
En este Testbench basicamente se declaran las entradas y salidas y se procede a probar cada posible caso (para 4 bits) y se realiza un display por cada caso con el fin de observar la entrada y la salida y así comparar los resultados con la tabla brindada.

Dichos resultados se muestran a continuación:

![image](https://github.com/user-attachments/assets/9c14dbc7-889b-4a10-83db-755040e7ee91)

### 3.2 Subsistema 2
#### 1. Encendido de los leds de la FPGA
````
module control_led (
    input  logic [3 : 0] binary, // Entrada: Código Binario (4 bits)
    output logic [3 : 0] leds  // Salida: LEDs
    
);
    assign leds[3] = ~binary[3];
    assign leds[2] = ~binary[2];
    assign leds[1] = ~binary[1];
    assign leds[0] = ~binary[0];

endmodule 
````
#### 2. Parámetros
`    control_led cl (
        .binary(binary),
        .leds(leds)
    );
    `
Estos fueron los parámteros utilizados para llamar al módulo, se usó el nombre de instancia "cl".

#### 3. Entradas y salidas
Se observa que en la definición del módulo solo se declaran una entrada y una salida. `input logic [3:0] binary` viene del subsistema 1. Este son los valores de cada bits de la conversión gray a binario. `output logic [3:0] leds` es la salida que va a los leds de la FPGA. Estos son la negación del bit de entrada, esto debido a que los leds se encienden cuando estos son conectados a tierra.

#### 4. Criterios de diseño
En cuanto al diseño de este subsistema, solo se observo el "pinout" de la FPGA TangNano 9k y se observó que los leds ya están conectados a la alimentación de la placa, se determinó que debían se conectados a tierra para que estos funcionaran. En cuanto al diseño como un circuito, este consistiría en conectar al cátodo de cada led un inversor CMOS y los ánodos a una tensión común. Si no se hiciera de este modo, los leds se encenderían cuando el bit es "0" y se apagarían cuando el bit es "1".

#### 5. Testbench
El testbench de este circuito es el mismo del subsistema 1. Dado que este solo consiste en un inversor CMOS a nivel circuito, se toman los valores de los bits en binarios que aparecen en el testbench y cuando un bit es "0" el led debe estar apagado y cuando es "1" el led encendido. 

### 3.3 Subsistema 3
#### 1. Encendido de los 7 segmentos
```
SystemVerilog 
Module seg7_disp (
     //Entradas
     input  logic btn, // Entrada: Boton
    //Salidas
     output logic [3 : 0] binary, // Salida: Código Binario (N bits)
    //Variables intermedias
    output wire a, b, c, d, e,
    //segmentos
    output logic segA,
    output logic segB,
    output logic segC,
    output logic segD,
    output logic segE,
    output logic segF,
    output logic segG,
    //Transistores
    output logic uni,  // Salida : transistor unidades
    output logic dec // Salida: transistor decenas
);
     //Se les asigna un nuevo valor a, b, c, d a las variables para facilitar escritura de ecuaciones booleanas
    assign a = binary[3];
    assign b = binary[2];
    assign c = binary[1];
    assign d = binary[0];
    assign e = btn; //boton de cambio de display

    //Salida para controlar transistores
    assign uni = btn;
    assign dec = ~btn;

//Ecuaciones booleanas de los 7 segmentos
    assign segA = ~((~b & ~d & ~e) | (~a & c & ~e) | (b & d & ~e) | (a & ~c & ~e)); 
    assign segB = ~((~b & ~e) | (~c & ~d & ~e) | (~a & c & d & ~e) | (a & c & e) | (a & b & ~c) | (a & ~d & ~e));
    assign segC = ~((d & ~e) | (a & c) | (a & b & e) | (~b & ~c & ~e) | (~a & b & ~e));
    assign segD = ~((~b & ~d & ~e) | (~a & ~b & c & ~e) | (b & ~c & d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~e) | (a & b & d & ~e));
    assign segE = ~((~b & ~d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~d & ~e));
    assign segF = ~((~a & b & ~c & ~e) | (a & ~b & ~c & ~e) | (a & b & c & ~e) | (~a & ~c & ~d & ~e) | (~a & b & ~d & ~e) | (a & ~b & ~d & ~e));
    assign segG = ~((~a & ~b & c & ~e) | (b & ~c & ~e) | (a & ~c & ~e) | (a & b & ~e) | (~a & c & ~d & ~e));

endmodule

````
#### 2. Parámetros
`seg7_disp s7d (
        .binary(binary),
        .btn(btn),
        .uni(uni),
        .dec(dec),
        .segA(segA),
        .segB(segB),
        .segC(segC),
        .segD(segD),
        .segE(segE),
        .segF(segF),
        .segG(segG)
    );`
Los parámetros se llaman igual que las variables usadas para evitar confusiones. La instancia del módulo se le dió el nombre de s7d.

#### 3. Entradas y salidas
Se utilizaron varios I/O para este subsistema, `input logic btn` es la entrada del botón implementado para mostrar las decenas o las unidades para cuando se apreta o no el boton, respectivamente. `output logic [3 : 0] binary` es son los bits en binario usados para saber el número a mostrar. `output wire a, b, c, d, e,` son variables internas, usadas para simplificar y acortar un poco las ecuaciones booleanas, basicamente se usan para poner una letra, en lugar de `binary[x]`. `output logic SegX` son las salidas que van a cada led de los 7 segmentos. Por último, `output logic uni` y `output logic dec` son las salidas que van a la base de los transistores, estos determinan si se enciende el display de las unidades o de las decenas, respectivamente.

#### 4. Criterios de diseño
Para el diseño de este subsistema se usaron diferentes entradas las cuales fueron necesarias para obtener las ecuaciones necesarias para cada segmento de los 7 segmentos. Las entradas y salidas ya fueron analizadas en el punto 3 de este subsistema, por lo que se procederá a explicar el uso que se le dió en el desarrollo del código necesario.
Para apegarse a las especificaciones del proyecto, se usaron estrictamente tablas de verdad y con estas, se encontraron las ecuaciones booleanas necesarias. No se usaron funciones if o case por esta misma razón. A continuación se muestra la tabla de verdad utilizada en este caso:

![Tabla_de_verdad](https://github.com/user-attachments/assets/3eeb7818-b3d7-4b92-b9c5-04b2d347b5ab)

Nótese que de los número del 0 a 9 los segmentos que aparecen encendidos en la salida corresponden a los que aparecerían en cualquier siete segmentos para representar estos números, vease que el bit "e" se encuentra en cero, esta variable corresponde al botón con el que se selecciona que "display" se enciende, al estar en cero indica que se muestran las unidades. Del 10 a 15 existen dos posibilidades a mostrar, las unidades o las decenas, cuando "e" es 0 se muestran las unidades por lo que la salida es la misma que con los números del 0 a 5. Al apretar el botón se muestran las decenas, para este caso solo se tiene que mostrar un "1" en el otro siete segmentos. Mediante esta variable "e" se consigue obtener dos estados distintos para un mismo número. Si se llega a apretar el botón en un número que solo tiene unidades, al no estar definido este caso, la salida no enciende los siete segmentos y no aparece nada en el "display" de las decenas.

A partir de la tabla de verdad se obtuvieron los minterminos necesarios para simplificar las ecuaciones, se usó el método de los mapas de karnaugh de 5 variables para simplificar las ecuaciones. Aquí se usaron los "wire" como variables intermedias para faciliar la escritura las ecuaciones. Los mapas que llevaron a las ecuaciones booleanas se muestran a continuación:

Segmento A:

![1](https://github.com/user-attachments/assets/ec58b372-2507-4da3-b99a-fadb42630d51)

Segmento B:

![2](https://github.com/user-attachments/assets/60b991d5-15de-4658-89a3-c6692c867cc6)

Segmento C:

![image](https://github.com/user-attachments/assets/627eb57e-f0d6-4287-be4a-ca17d0a3cfc4)

Segmento D:

![image](https://github.com/user-attachments/assets/d8845df7-28dd-462b-8491-6c1f302d4af3)

Segmento E:

![image](https://github.com/user-attachments/assets/414952f2-0a08-4d27-a04b-281b420a62b4)

Segmento F:

![3](https://github.com/user-attachments/assets/035b4614-f1cb-493f-8268-d1b105cc73b5)

Segmento G:

![4](https://github.com/user-attachments/assets/7e4d46e4-8fa9-4a06-b389-67950d0ce2f4)


Al final estas ecuaciones se niegan, esto porque se usaron siete segmentos del tipo ánodo común, por lo que se necesita ofrecer un camino a tierra para que estos se enciendan, esto se consigue poniendo un "0" en el cátodo de cada segmento.

Por último `output uni` y `output dec` son las salidas que van a las bases de los transistores. El botón cuando no está apretado está conectado a tierra, haciendo que el transistor PNP de las unidades deje pasar corriente. "dec" tiene el mismo estado pero negado, por lo que mantiene el transistor de las decenas apagado. Cuando el botón es apretado se conecta a 3,3 V, cuando esto ocurre, el transistor de las unidades se apaga y el de las decenas permite el paso de la corriente.

#### 5. Testbench

````
timescale 1ns/1ps

module tb_gray_to_binary_leds;

    // Testbench signals
    logic [3:0] gray;    // Test input: Gray code
    logic [3:0] binary;  // Test output: Binary code
    logic btn;
    logic dec;
    logic uni;
    logic segA;
    logic segB;
    logic segC;
    logic segD;
    logic segE;
    logic segF;
    logic segG;

    // Instantiate the module under test (MUT)
     call mc (
        .gray(gray),
        .binary(binary),
        .btn(btn),
        .dec(dec),
        .uni(uni),
        .segA(segA),
        .segB(segB),
        .segC(segC),
        .segD(segD),
        .segE(segE),
        .segF(segF),
        .segG(segG)
    );

    // Test stimulus
    initial begin
        // Display header

        $display("boton no apretado");

        btn = 1'b0;
        $display (dec);
        btn = 1'b0;
        $display (uni);

        $display("boton apretado");
        btn = 1'b1;
        $display (dec);
        btn = 1'b1;
        $display (uni);

        btn = 1'b0; //modificar valor 0 o 1 para simular tocar el boton
        $display ("btn :" , btn);

        $display("Decodificación y estado de segmento");
        $display("Nota: 0 enciende los segementos"); 
        $display("Gray Code | Binary Code ");
        $display("----------|-------------");

        // Test each Gray code and display the result
        gray = 4'b0000; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0001; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0011; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0010; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);

        gray = 4'b0110; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0111; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0101; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0100; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1100; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1101; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1111; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1110; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);

        gray = 4'b1010; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1011; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1001; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1000; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);

        $finish;  // Stop the simulation
    end

    initial begin
        $dumpfile("tb_gray_to_binary_leds.vcd");
        $dumpvars(0,tb_gray_to_binary_leds);
    end

endmodule
````
Este testbench tiene como base el que se usó para el subcircuito 1, pero se le agregó los estados de cada segmento de los "display" para saber que cual está encendido y cual no (al hacer la prueba, los segmentos en "0" están encendidos y los que están en "1" apagados. En este código hay un `btn = 1'b0` con un comentario al lado que indica que el valor de este bit debe ser modificado ("1" o "0") para probar cuando el botón es apretado.

A continuación se puede ver lo que aparece en el testbench para los números 14 y 15, la primera imagen muestra cuando el botón no es apretado y la segunda con el botón apretado.

Sin apretar el botón:

![test_seg1](https://github.com/user-attachments/assets/2c521667-66b6-497e-bbd7-613e74c6adff)


Con el botón apretado:

![test_seg2](https://github.com/user-attachments/assets/0c65ce4d-17aa-4689-ac4b-245163d9b4fc)

Aquí se muestra que ocurre cuando se apreta el botón con un número que solo tiene unidades:

![test_seg](https://github.com/user-attachments/assets/581212a7-e2dc-4147-8d85-09e721706d81)

Vease que todos los segmentos están en 1, esto indica que todos están apagados.

## 4. Consumo de recursos
En consumo de recursos de la FPGA se encuentra en el archivo generado por el "make pnr". Se están usando 21 de 8640 "Look up tables" (LUT) de 4 bits (LUT4) y 6 de 4320 LUT5. Estos son las tablas de verdad, las cuales se llenan al cargar la información a la FPGA. Se implementan 22 de 274 "Input output block" (IOB). Estas son la interfaz entre la FPGA y las salidas y entradas físicas.


## 5. Problemas encontrados durante el proyecto
Se puede hablar de varios problemas que se encontraron, la mayoría no demasiado exigentes, pero más que problemas fueron retos que pusieron a prueba la genialidad del grupo de trabajo. El principal reto que se presentó fue transformar la entada binaria en señales capaces de encender o apagar los segmentos del display, también la implementación del botón sin hacer uso de funciones como `case` o `if`, probó ser dificultoso. Al final se logró usando unicamente ecuaciones booleanas, pero presentó la necesiadad de usar tablas de verdad con 5 bits de entrada, y esto a su vez 16 veces, una para cada número a mostar, lo que hace más compleja la resolución y simplificación de las ecuaciones obtenidas. Por otro lado, en cuanto a las salidas de la tabla de verdad, tener 7 posibles estados para cada combinación hizo más tedioso el proceso, debido a la gran cantidad de información que se debía tomar en cuenta. 

