# Multiplicador con teclado 

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.0 Descripción general del sistema

El proyecto consiste de una maquina de estados de gran tamaño con módulos interconectados entre sí que permiten el funcionamiento deseado. Inicialmente se da el funcionamiento ideal del teclado, en este se digitan números que una vez presionado el botón del signo de multiplicación se guarda en una variable "A" y además se pasa a esperar dígitos para una variable "B". Una vez digitados los valores en la variable "B", se presiona el botón de resultado, esto hace que las variables "A" y "B" pasen al módulo de multiplicación, donde se hace la multiplicación entre las 2 variables y da como salida el resultado. Todo este proceso se va registrando y mostrando en los 4 displays de 7 segmentos, además, hay un 5to display que permite trabajar con número negativos, este funciona con una bandera fuera del proceso de multiplicación, y al ser activada en el proceso de digitación de las variables "A" y "B", entra en cuenta para un XOR que a la hora de mostrar el resultado determina si este 5to display estará activo o no. Además, para que se cumpla el proceso una serie de cambios de formato de números fueron necesarios, estos se explicaran más a detalle en el desarrollo de este informe. 

### 3.1 Cotrol de 7 segmentos 
#### 1. Código
```SystemVerilog
module seg7_disp (
    input logic clk,
    input logic reset,
    output logic segA,
    output logic segB,
    output logic segC,
    output logic segD,
    output logic segE,
    output logic segF,
    output logic segG,
    output logic dispuni,     
    output logic dispdec,
    output logic dispcen,
    output logic dispmil,
    input logic [15:0] bcd

);

    logic [1:0] disp;
    logic a, b, c, d, e;
    logic clk_cut1;
    logic [31:0] counter1;

    // Estado inicial
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter1 <= 0;
            clk_cut1 <= 0;
        end else begin
            if (counter1 == (27000-1)) begin
                counter1 <= 0;
                clk_cut1 <= ~clk_cut1;  // Cambia la señal de salida
            end else begin
                counter1 <= counter1 + 1;
            end 
        end
    end

    logic [1:0] cycle_count1;
            // Variable para contar los ciclos
    always_ff @(posedge clk_cut1) begin
        begin
            // Cambiar variables de acuerdo con el ciclo
            case (cycle_count1)
                2'b00: begin
                    dispuni = 0; 
                    dispdec = 1;
                    dispcen = 1;
                    dispmil = 1;
                    disp = 2'b00;
                end
                2'b01: begin
                    dispuni = 1;
                    dispdec = 0; 
                    dispcen = 1;
                    dispmil = 1;
                    disp = 2'b01;
                end
                2'b10: begin
                    dispuni = 1;
                    dispdec = 1;
                    dispcen = 0; 
                    dispmil = 1;
                    disp = 2'b10;
                end
                2'b11: begin
                    dispuni = 1;
                    dispdec = 1;
                    dispcen = 1;
                    dispmil = 0; 
                    disp = 2'b11;
                end
            endcase

            // Incrementar el contador de ciclos (vuelve a 0 después del cuarto ciclo)
            cycle_count1 <= cycle_count1 + 1;
        end
    end
        /*if (reset) begin
            a = 0;
            b = 0;
            c = 0;
            d = 0;
            e = 0;
        end*/

    always_comb begin
        case (disp)
            2'b00: begin
                a = bcd[3];
                b = bcd[2];
                c = bcd[1];
                d = bcd[0];
                e = 0;
            end
            2'b01: begin
                a = bcd[7];
                b = bcd[6];
                c = bcd[5];
                d = bcd[4];
                e = 0;
            end
            2'b10: begin
                a = bcd[11];
                b = bcd[10];
                c = bcd[9];
                d = bcd[8];
                e = 0;
            end
            2'b11: begin
                a = bcd[15];
                b = bcd[14];
                c = bcd[13];
                d = bcd[12];
                e = 0;
            end
        endcase    
    end
    
    assign segA = ~((~b & ~d & ~e) | (~a & c & ~e) | (b & d & ~e) | (a & ~c & ~e)); 
    assign segB = ~((~b & ~e) | (~c & ~d & ~e) | (~a & c & d & ~e) | (a & c & e) | (a & b & ~c) | (a & ~d & ~e));
    assign segC = ~((d & ~e) | (a & c) | (a & b & e) | (~b & ~c & ~e) | (~a & b & ~e));
    assign segD = ~((~b & ~d & ~e) | (~a & ~b & c & ~e) | (b & ~c & d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~e) | (a & b & d & ~e));
    assign segE = ~((~b & ~d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~d & ~e));
    assign segF = ~((~a & b & ~c & ~e) | (a & ~b & ~c & ~e) | (a & b & c & ~e) | (~a & ~c & ~d & ~e) | (~a & b & ~d & ~e) | (a & ~b & ~d & ~e));
    assign segG = ~((~a & ~b & c & ~e) | (b & ~c & ~e) | (a & ~c & ~e) | (a & b & ~e) | (~a & c & ~d & ~e));

   
endmodule
```
#### 2. Parámetros
```SystemVerilog
seg7_disp s7d (
        .clk(clk),
        .reset(reset),
        .segA(segA),
        .segB(segB),
        .segC(segC),
        .segD(segD),
        .segE(segE),
        .segF(segF),
        .segG(segG),
        .dispuni(dispuni),
        .dispdec(dispdec),
        .dispcen(dispcen),
        .dispmil(dispmil),
        .bcd(bcd)
    );
```

#### 3. Entradas y salidas:
-	`input logic [15:0] bcd` : Entrdad en BCD para mostrar el digito cada display.
-	`input logic clk y reset` : Entradas de reloj y reset para sincronización.
-	`output logic segX` La salida de cada segmento de los display.
-	`logic a, b, c, d, e,` : Señales con los valores binarios de cada dígito. d:menos significativo. a:más signficiativo. e: variable con valor 0, siempre.
-	`output logic dispuni` : Salida de transistor para display de unidades.
-	`output logic dispdec` : Salida de transistor para display de decena.
-	`output logic dispcen` : Salida de transistor para display de centenas.
-	`output logic dispmil` : Salida de transistor para display de miles.
-	`logic [1:0] disp` : Señal interna usada para sincronizar transistor con digito a mostrar.
-	`logic clk_cut1` : Señal interna de reloj pasada por un divisor de frecuencia.
-	`logic [31:0} counter1` : Variable interna utilizada como contador del módulo.

#### 4. Criterios de diseño
El módulo funciona como el utilizado en las tareas anteriores.

La primera parte del código, consiste en un divisor de frecuencia. Esto para evitar que al conectar la salida del reloj a los transistores, la señal de reloj se callera.

Seguidamente, el código consiste en un case, el cual enciende y apaga los transistores de manera que solo uno esté encendido a la vez. La variable "cycle_count" es de 2 bits, al pasar los 4 estados (cada transistor se encendió una vez), este hace overflow y se reinicia el ciclo. La variable "disp" se usa para escoger el valor del arreglo de BCD se debe Mostar en ese momento. Aquí hay que aclarar que solo se usaron 7 líneas para los cuatro 7 segmentos, por esto es que se usa este código, el cual enciende y apaga los transistores de manera sincronizada, a la vez que el dígito a mostrar se envía por las 7 líneas, esto ocurre tan rápido que parece que todos están encendidos a la vez y se logra mostrar 4 dígitos distintos con las mismas 7 salidas. También, se usa la variable "disp" junto con un case para seleccionar los valores del arreglo de BCD a mostrar.

Por último, e usa código combinacional con ecuaciones booleanas, esto se usa para encender cada segmentos dependiendo del número (en binario) indicado por el arreglo BCD antes mencionado.

En esta ocasión también se utilizó un 5to display de 7 segmentos. Este tenía como único uso mostrar si el número era negativo o no. Para esto se hizo uso únicamente del segmento central del display, este se activaba dependiendo de una bandera que indicaba si el número digitado o el resultado de la multiplicación era negativo. Este negativo se encuentra fuera del módulo de multiplicación y únicamente es utilizado como un XOR que permite con lógica matemática saber si encenderse o no.

### 3.2 Teclado

### 3.3 Booth_Mul (Módulo de multiplicación)
#### 1. Código
```SystemVerilog
module boothMul(
    input clk,                       // Entrada del reloj
    input rst,                       // Señal de reset asíncrono
    input start,                     // Señal para iniciar la multiplicación
    input signed [7:0] X,           // Operando X de 8 bits
    input signed [7:0] Y,           // Operando Y de 8 bits
    output reg signed [15:0] Z,     // Resultado de la multiplicación de 16 bits
    output reg valid                 // Señal que indica que el resultado es válido
);

    reg signed [15:0] next_Z, Z_temp; // Registro para el siguiente resultado y un valor temporal
    reg next_state, pres_state;        // Registro para el estado actual y el siguiente estado
    reg [1:0] temp, next_temp;         // Registro para manejar el estado intermedio del algoritmo de Booth
    reg [2:0] count, next_count;       // Contador de ciclos, actualizado para un multiplicador de 8 bits
    reg next_valid;                    // Registro para la señal de validez del resultado

    parameter IDLE = 1'b0;             // Estado IDLE
    parameter START = 1'b1;            // Estado de inicio

    // Bloque siempre que se activa en el flanco positivo del reloj o el flanco negativo del reset
    always @ (posedge clk) begin
        if (rst) begin                  // Si se activa el reset
            Z          <= 16'd0;       // Inicializa Z a 0
            valid      <= 1'b0;        // Inicializa valid a 0 (no válido)
            pres_state <= IDLE;        // Estado presente a IDLE
            temp       <= 2'd0;        // Inicializa temp a 0
            count      <= 3'd0;        // Inicializa el contador a 0
        end else begin
            // Actualiza los registros en el ciclo
            Z          <= next_Z;      // Actualiza Z con el siguiente valor
            valid      <= next_valid;  // Actualiza valid con el siguiente valor
            pres_state <= next_state;  // Actualiza el estado presente con el siguiente estado
            temp       <= next_temp;    // Actualiza temp con el siguiente valor
            count      <= next_count;   // Actualiza count con el siguiente valor
        end
    end

    // Bloque combinacional para determinar el siguiente estado y las salidas
    always @ (*) begin 
        case (pres_state)               // Evaluar el estado presente
            IDLE: begin
                next_count = 3'd0;      // Resetea el contador a 0 en IDLE
                next_valid = 1'b0;      // Establece valid a 0
                if (start) begin        // Si se inicia la multiplicación
                    next_state = START; // Cambia el estado a START
                    next_temp  = {X[0], 1'b0}; // Carga el bit menos significativo de X y un 0
                    next_Z     = {8'd0, X}; // Inicia Z con X en la mitad inferior y ceros en la superior
                end else begin
                    next_state = pres_state; // Mantiene el estado presente
                    next_temp  = 2'd0;        // Resetea temp
                    next_Z     = 16'd0;       // Resetea Z
                end
            end

            START: begin
                // Aplicar el algoritmo de Booth según el valor de `temp`
                case (temp)
                    2'b10:   Z_temp = {Z[15:8] - Y, Z[7:0]}; // Restar Y del byte superior de Z
                    2'b01:   Z_temp = {Z[15:8] + Y, Z[7:0]}; // Sumar Y al byte superior de Z
                    default: Z_temp = {Z[15:8], Z[7:0]};     // Mantener Z sin cambios
                endcase

                // Actualiza `temp` para el siguiente par de bits
                next_temp  = {X[count+1], X[count]}; // Obtiene el siguiente par de bits de X
                next_count = count + 1'b1;           // Incrementa el contador
                next_Z     = Z_temp >>> 1;           // Desplazamiento a la derecha de Z_temp
                next_valid = (&count) ? 1'b1 : 1'b0; // Establece valid a 1 si se han procesado tdos los bits
                next_state = (&count) ? IDLE : pres_state; // Cambia al estado IDLE si toos los bits han sido procesados
            end
        endcase
    end

endmodule

```
#### 2. Parámetros
```SystemVerilog
    boothMul uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .X(X),
        .Y(Y),
        .valid(valid),
        .Z(Z)
    );
```

#### 3. Entradas y salidas:
-	`input clk`  : Entrada del reloj
-	`input rst`  : Señal de reset asíncrono
-	`input start` : Señal para iniciar la multiplicación
-	`input signed [7:0] X`  : Operando X de 8 bits
-	`input signed [7:0] Y`   : Operando Y de 8 bits
-	`output reg signed [15:0] Z` :Resultado de la multiplicación de 16 bits
-	`output reg valid` :Señal que indica que el resultado es válido
#### 4. Criterios de diseño
Este modulo funciona recibiendo dos entradas (dichas entradas son los numeros de 2 dígitos que capturó el teclado en la etapa anterior) y luego mediante el algoritmo de booth procede a realizar la multiplicación, como se observa en la codificación del modulo dicha multiplicación inicia su proceso cuando la señal de start es 1, sin embargo la salida obtiene su valor final hasta que la señal valid sea verdadera.

Estas entradas estan directamente instanciadas con el modulo proveniente del teclado, no importa si sus valores van cambiando mientras se insertan los dígitos, ya que la multiplicación solo se efectuara hasta que la señal de start sea valida, es decir en este caso se presione el botón de start. cabe mencionar que en este modulo las entradas X y Y ya vienen sincronizadas con el teclado anterior.

#### 5. Testbench
```SystemVerilog
`timescale 1ns/1ps

module booth_tb;

    // Definir señales para conectar con el módulo boothMul
    reg clk;
    reg rst;
    reg start;
    reg signed [7:0] X, Y;     // Cambiar a 8 bits
    wire signed [15:0] Z;      // Cambiar a 16 bits
    wire valid;

    // Instanciar el módulo BoothMul
    boothMul uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .X(X),
        .Y(Y),
        .valid(valid),
        .Z(Z)
    );

    // Generar el reloj
    always #5 clk = ~clk; // Periodo de 10 ns

    // Procedimiento de prueba
    initial begin
        // Inicializar señales
        clk = 0;
        rst = 1;
        start = 0;
        X = 0;
        Y = 0;

        // Liberar reset después de un tiempo
        #10 rst = 0;
                // Caso de prueba 1: Multiplicación de 88 * 88 con las entradas escritas en binario
        X = 8'd1011000;
        Y = 8'b1011000;
        #10 start = 1;
        #10 start = 0;
        wait (valid);
        $display("Resultado de %d * %d = %d", X, Y, Z);

        // Caso de prueba 2: Multiplicación de 30 * 5
        X = 8'd30;
        Y = 8'd5;
        #10 start = 1;
        #10 start = 0;
        wait (valid);
        $display("Resultado de %d * %d = %d", X, Y, Z);

        // Caso de prueba 3: Multiplicación de 5 * 5
        X = 8'd5;
        Y = 8'd5;
        #10 start = 1;
        #10 start = 0;
        wait (valid);
        $display("Resultado de %d * %d = %d", X, Y, Z);

        // Caso de prueba 4: Multiplicación de 71 * 8
        X = 8'd71;
        Y = 8'd8;
        #10 start = 1;
        #10 start = 0;
        wait (valid);
        $display("Resultado de %d * %d = %d", X, Y, Z);

        // Caso de prueba 5: Multiplicación de 0 * 7
        X = 8'd0;
        Y = 8'd7;
        #10 start = 1;
        #10 start = 0;
        wait (valid);
        $display("Resultado de %d * %d = %d", X, Y, Z);
        // Caso de prueba especial: Multiplicación de -99 * -99
        X = 8'd99; // -99 en decimal
        Y = 8'd99; // -99 en decimal
        #10 start = 1; // Iniciar la multiplicación
        #10 start = 0; // Apagar start

        // Esperar a que valid se active
        wait (valid);
        $display("Resultado de %d * %d = %d", X, Y, Z);

        // Finalizar simulación
        $finish;
    end


    initial begin
        $dumpfile ("booth_tb.vcd");
        $dumpvars (0, booth_tb);
    end

endmodule
```
Este testbench tiene como función probar diferentes casos de multiplicación, en este caso se probó con 99*-99, 0* 7, 71* 8, 5* 5, 30 * 5 y 88* 88
Donde los resultados se muestran a continuación.
![image](https://github.com/user-attachments/assets/e3dbcba8-db5e-4e8f-a5e3-1b2d629c09b9)
Finalmente en el siguiente wave view se puede observar como la salida Z empieza a tener valores cuando se inicia la multiplicación (se presiona start), sin embargo, su valor real final se muestra cuando la señal de valid es 1.
![image](https://github.com/user-attachments/assets/420a7ad0-2dee-469a-832d-f59ddb5fdf49)
Como se puede observar en el instante que valid es 1 Z obtiene el valor de 7744 (esto para la multiplicación de 88*88) y tambien en ese mismo instante Z y Y adquieren los valores para la siguiente multiplicación.



## 4. Consumo de recursos

## 5. Problemas encontrados durante el proyecto

## Apendices:
### Apendice 1:
texto, imágen, etc
