# Decodificador de codigo de gray

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.0 Descripción general del sistema

### 3.1 Subsistema 1
#### 1. Gray to binary
```SystemVerilog
module gray_to_binary_leds(
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

    //asignacion de leds de acuerdo al bit

    assign leds[3] = ~binary[3];
    assign leds[2] = ~binary[2];
    assign leds[1] = ~binary[1];
    assign leds[0] = ~binary[0];

endmodule
```
#### 2. Parámetros
- Para el parámetro de entrada se utilizo `input  logic [3 : 0] gray` el cual representa la entrada en codigo gray.
- Para los parámetros de salida se usó `output logic [3 : 0] binary` y `output logic [3 : 0] leds` ya que estos representan el código een binario y las luces de la FPGA

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

### 3.3 Subsistema 3
#### 1. Encendido de los 7 segmentos
```SystemVerilog 
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


#### 3. Entradas y salidas
Se utilizaron varios I/O para este subsistema, `input logic btn` es la entrada del botón implementado para mostrar las decenas o las unidades para cuando se apreta o no el boton, respectivamente. `output logic [3 : 0] binary` es son los bits en binario usados para saber el número a mostrar. `output wire a, b, c, d, e,` son variables internas, usadas para simplificar y acortar un poco las ecuaciones booleanas, basicamente se usan para poner una letra, en lugar de `binary[x]`. `output logic SegX` son las salidas que van a cada led de los 7 segmentos. Por último, `output logic uni` y `output logic dec` son las salidas que van a la base de los transistores, estos determinan si se enciende el display de las unidades o de las decenas, respectivamente.
### Otros modulos

- agregar informacion siguiendo el ejemplo anterior.


## 4. Consumo de recursos

## 5. Problemas encontrados durante el proyecto
Se puede hablar de varios problemas que se encontraron, la mayoría no demasiado exigentes, pero más que problemas fueron retos que pusieron a prueba la genialidad del grupo de trabajo. El principal reto que se presentó fue transformar la entada binaria en señales capaces de encender o apagar los segmentos del display, también la implementación del botón sin hacer uso de funciones como `case` o `if`, probó ser dificultoso. Al final se logró usando unicamente ecuaciones booleanas, pero presentó la necesiadad de usar tablas de verdad con 5 bits de entrada, y esto a su vez 16 veces, una para cada número a mostar, lo que hace más compleja la resolución y simplificación de las ecuaciones obtenidas. Por otro lado, en cuanto a las salidas de la tabla de verdad, tener 7 posibles estados para cada combinación hizo más tedioso el proceso, debido a la gran cantidad de información que se debía tomar en cuenta. 


## Apendices:
### Apendice 1:
texto, imágen, etc
