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
Debido a la gran extensión y la cantidad de módulos que componenen este sistema, se optó por hacer una descripción general de este.
#### 1. Códigos
##### 1.1 Clk_cut_module
```SystemVerilog
    module clk_cut_module (
    input logic clk,
    input logic reset,
    input logic stop_flag,
    output logic clk_cut,
    output logic mostrar_dato,
    output logic enable_input,
    output logic reset_input_ff
    
);

logic [31:0] counter;
logic [31:0] stop_count;

always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_cut <= 0;
            stop_count <= 0;
            mostrar_dato <= 0;
            enable_input <= 1;
            reset_input_ff <= 0;
        end 
        else if (stop_flag || stop_count != 0) begin
            stop_count <= stop_count + 1;
            enable_input <= 0;
            if (stop_count == 15000) begin //15000
                mostrar_dato <= 1;
                reset_input_ff <= 1;
            end
            if (stop_count == 15001) begin //15001
                mostrar_dato <= 0;  //Para pruebas de fpga en leds: mostrar_dato <= 1 
                reset_input_ff <= 0;
            end
            if (stop_count == 9900000 ) begin //Se debe modificar de acuerdo al tiempo de rebote de las teclas   //9900000
            //indica el número de ciclos clk //En la vida real debe ser un valor alto acorde a 27 000 del contador
                stop_count <= 0;
                enable_input <= 1;
            end
        end
        else begin
            if (counter == (27000-1)) begin  //Para funcionamiento 27 000-1, para simular 2-1
                counter <= 0;
                clk_cut <= ~clk_cut;  // Cambia la señal de salida
            end else begin
                counter <= counter + 1;
            end 
        end
    end

endmodule
```
Descripción: Este código se encarga de generar la señal de reloj necesaria para encender y apagar las columnas para poder leer el teclado matricial 4x4. Este no genera la salida hacia el teclado, sino, solo el reloj divido "clk_cut". Este a la vez, genera otras señales como "reset_input_ff" para reiniciar el conteo. Tambien se encarga de detener el ciclado de la columnas cuando "stop_flag" se hace HIGH, y mantiene el estado de no ciclar mientras que "stop_count" sea diferente a 0.

##### 1.2 colum_on
```SystemVerilog
    module colum_on (
    input logic clk_cut,
    input logic reset,
    output logic [3:0] colum,
    output logic [1:0] colum_code

);

    always_ff @ (posedge clk_cut or posedge reset)
        if (reset) begin
            colum_code <= 2'b00;
        end
        else begin
            colum_code = colum_code + 1;
        end


    always_comb begin //logica combiancional para salidas al teclado
        case (colum_code)
            2'b00: begin
                colum[0] = 1;
                colum[1] = 0;
                colum[2] = 0;
                colum[3] = 0;
            end
            2'b01: begin
                colum[0] = 0;
                colum[1] = 1;
                colum[2] = 0;
                colum[3] = 0;
            end
            2'b10: begin
                colum[0] = 0;
                colum[1] = 0;
                colum[2] = 1;
                colum[3] = 0;
            end
            2'b11: begin
                colum[0] = 0;
                colum[1] = 0;
                colum[2] = 0;
                colum[3] = 1;
            end
        endcase
        
    end


endmodule

```
Descripición: Usando la señal de reloj divida de "clk_cut" genera un contador con la parte secuencial del código, a partir de este se genera un código de columna el cual va cambiando entre un valor binario de 0 a 3. Con la parte combiancional se generan los pulsos a la salida hacia el teclado.

#### 1.3 Row_detect
```SystemVerilog
    module row_detect (
    input logic [3:0] row,
    output logic stop_flag,
    output logic [1:0] row_code //codificación de la tecla presionada

);

    always_comb begin
        case (row)
            4'b0001: begin
                stop_flag = 1;
                row_code = 2'b00;
            end
            4'b0010: begin
                stop_flag = 1;
                row_code = 2'b01;
            end
            4'b0100: begin
                stop_flag = 1;
                row_code = 2'b10;
            end
            4'b1000: begin
                stop_flag = 1;
                row_code = 2'b11;
            end
            default: begin
                stop_flag = 0;
                row_code = 2'bz;
            end

        endcase
    end
endmodule
```
Descripición: Está conectado al teclado por medio de "input_sync", haciendo uso de los pulsos en cada columna y al tocar una tecla, "row[x]" se hace HIGH, x corresponde a la fila donde se detectó una conexión, al detectar esto, "stop_flag" se enciende y detiene el contador de "clk_cut_module" y genera un código para esa fila "row_code".

#### 1.4 deco_out
```SystemVerilog
    module deco_out (
    input logic [3:0] q_in,
    output logic [3:0] num_out

);

    always_comb begin

        case(q_in)
            4'b0000: begin
                num_out = 4'b1010; //A 10
            end
            4'b0001: begin
                num_out = 4'b1011; //B 11
            end
            4'b0010: begin
                num_out = 4'b1100; //C 12
            end
            4'b0011: begin
                num_out = 4'b1101; //D 13
            end
            4'b0100: begin
                num_out = 4'b0011; //3
            end
            4'b0101: begin 
                num_out = 4'b0110; //6
            end
            4'b0110: begin
                num_out = 4'b1001; //9
            end
            4'b0111: begin
                num_out = 4'b1110; //#
            end
            4'b1000: begin
                num_out = 4'b0010; //2
            end
            4'b1001: begin
                num_out = 4'b0101; //5
            end
            4'b1010: begin
                num_out = 4'b1000; //8
            end
            4'b1011: begin
                num_out = 4'b0000; //0
            end
            4'b1100: begin
                num_out = 4'b0001; //1
            end
            4'b1101: begin
                num_out = 4'b0100; //4
            end
            4'b1110: begin
                num_out = 4'b0111; //7
            end
            4'b1111: begin
                num_out = 4'b1111; //*
            end
            default: num_out = 4'bz; //alta impedancia
        endcase
    end
    
endmodule
```
Descripción: Usando q_in que viene de output_FF, se genera un número de salida a partir del valor que se encuentra en q_in[3:0]. Estos números de salida corresponden a los del teclado.

#### 1.4 output_ff
```SystemVerilog
    module output_ff (
    input  logic clk,     
    input  logic reset,    
    input  logic enable,    
    input  logic mostrar_dato,   
    input  logic d,     
    output logic q 
);

    logic q_reg; 

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            q_reg <= 1'b0;           
        end else if (enable) begin
            q_reg <= d;          
        end
       
    end

    assign q = mostrar_dato ? q_reg : 1'b0; 

endmodule
```
Descripción: Se usa para guardar el estado actual de los códigos de columna (colum_code) y de fila (row_code), la salida va a "deco_out" para generar la decodificación de estos valores.

#### 1.4 row_ff
```SystemVerilog
    module row_ff (
    input  logic clk,     
    input  logic reset,    
    input  logic enable,      
    input  logic d,     
    output logic q 
);

    logic q_reg; 

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 1'b0;           
        end else if (enable) begin
            q <= d;          
        end
       
    end


endmodule
```
Descripción: Se encarga de guardar el valor row[3:0] detectado directamente del teclado (No es directamente debido a que pasa por un sincronizador primero pero funciona para la expliación) Esto fue necesario debido a la naturaleza combinacional de "row_detect".

#### 1.5. input_sync
```SystemVerilog
    module input_sync (
    input logic clk,        
    input logic reset,      
    input logic input_pulse,     //Señal física (asíncrona)
    output logic sync_input      //Señal sincronizada
);

    // Flip-flops para sincronización
    logic sync_ff1, sync_ff2;

    //Se usa un sincronizador basado en dos flip-flops en cascada
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sync_ff1 <= 1'b0;    
            sync_ff2 <= 1'b0;    
            sync_input <= 1'b0;  
        end else begin
            sync_ff1 <= input_pulse;     
            sync_ff2 <= sync_ff1;   
            sync_input <= sync_ff2; 
        end
    end


endmodule
```
Descripción: Es un sincronizador basado en 2 FF en cadena, se usa para asegurar que la señal generada por el teclado llegue de manera sincrónica al resto del sistema y obtener un buen funcionamiento.

#### 1.5. neg_sign_module
```SystemVerilog
    module neg_sign_module (
    input logic neg_flag1,
    input logic neg_flag2,
    input logic keep_sign_on,
    input logic neg_sign_disp,
    output logic neg_sign_output

);
    logic inter_neg_flag;

    always_comb begin

        inter_neg_flag = (neg_flag1 ^ neg_flag2);

        if (keep_sign_on)begin
            neg_sign_output = !(inter_neg_flag || neg_sign_disp);
        end
        else begin
            neg_sign_output = !neg_sign_disp;
        end

    end
```
Descripción: No es directamente relacionado con el teclado, pero este módulo haciendo uso del teclado, al presionar la tecla "#" se obtiene el signo menos (-) con este código se genera o no señal del transistor encargado de mostrar el signo. Se usa un XOR para decir que cuando los signos de los númeoros ingresados sean iguales, no encienda el menos y que cuando sean diferentes lo haga. Se encarga también de mostrar el signo mientras se ingresan los números.


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

### 3.4 Module_call (Módulo principal)
#### 1. Código
```SystemVerilog
    module module_call (
    input logic clk,
    input logic reset,
    input logic [3:0] row,
    output logic [3:0] colum,

    //Variables para 7 segmentos
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
    output logic neg_sign
);

    //variables internas
    logic stop_flag;
    logic clk_cut;
    logic [1:0] colum_code;
    logic [3:0] sync_row;
    logic [1:0] row_code;
    logic [3:0] ff_out;
    logic mostrar_dato;
    logic [3:0] stored_row;
    logic enable_input;
    logic reset_input_ff;
    logic [15:0] bcd;
    logic [3:0] num_deco_out;
    logic [15:0] bcd_num1;
    logic [15:0] bcd_num2;
    logic [15:0] bin_num1;
    logic [15:0] bin_num2;
    logic neg_flag1;
    logic neg_flag2;
    logic multiplic_flag;
    logic neg_sign_disp;
    logic mult_ready1;
    logic mult_ready2;
    logic mult_result;
    logic [15:0] mult_result_bcd;
    logic result_ok;
    logic [15:0] salida_bcd;
    logic [15:0] z_out;


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

    BoothMul boothMul_inst (
        .clk(clk),
        .rst(reset),
        .start(mult_ready2),
        .X(bin_num1),
        .Y(bin_num2),
        .z_out(z_out),
        .valid_out(result_ok)
    ); 

    show_num show_num_inst(
        .stored_num_bcd(salida_bcd),
        .mult_result_bcd_SN(mult_result_bcd),
        .result_ok(result_ok),
        .bcd_to_s7d(bcd)
    );

    binario_bcd binario_bcd_resultado (
        .bin_for_bcd(z_out),
        .bcd_out(mult_result_bcd)
    );

    bcd_binario bcd_binario_inst1 ( //hace salida bin correcta
        .entrada_bcd(bcd_num1),
        .multiplic_flag(multiplic_flag),
        .salida_bin(bin_num1),
        .mult_ready(mult_ready1)
    );

    bcd_binario bcd_binario_inst2 ( //hace salida bin correcta
        .entrada_bcd(bcd_num2),
        .multiplic_flag(multiplic_flag),
        .salida_bin(bin_num2),
        .mult_ready(mult_ready2)
    );

    neg_sign_module nsm (
        .neg_flag1(neg_flag1),
        .neg_flag2(neg_flag2),
        .keep_sign_on(multiplic_flag),
        .neg_sign_disp(neg_sign_disp),
        .neg_sign_output(neg_sign)
    );

    bcd_stored_num bcd_stored_num_inst (
        .clk(clk),
        .reset(reset),
        .nuevo_numero(num_deco_out),
        .salida_bcd(salida_bcd),
        .bcd_num1(bcd_num1),
        .bcd_num2(bcd_num2),
        .neg_flag1(neg_flag1),
        .neg_flag2(neg_flag2),
        .neg_sign(neg_sign_disp),
        .multiplic_flag(multiplic_flag)
    );

    row_ff row_ff3 (
        .clk(clk),
        .reset(reset_input_ff),
        .enable(enable_input),
        .d(sync_row[3]),
        .q(stored_row[3])
    );

    row_ff row_ff2 (
        .clk(clk),
        .reset(reset_input_ff),
        .enable(enable_input),
        .d(sync_row[2]),
        .q(stored_row[2])
    );

    row_ff row_ff1 (
        .clk(clk),
        .reset(reset_input_ff),
        .enable(enable_input),
        .d(sync_row[1]),
        .q(stored_row[1])
    );

    row_ff row_ff0 (
        .clk(clk),
        .reset(reset_input_ff),
        .enable(enable_input),
        .d(sync_row[0]),
        .q(stored_row[0])
    );
    
    deco_out deco_out_inst (
        .q_in(ff_out),
        .num_out(num_deco_out)
    );
    
    output_ff out_ff3 (
        .clk(clk),
        .reset(reset),
        .enable(stop_flag),
        .mostrar_dato(mostrar_dato),
        .d(colum_code[1]),
        .q(ff_out[3])
    );

    output_ff out_ff2 (
        .clk(clk),
        .reset(reset),
        .enable(stop_flag),
        .mostrar_dato(mostrar_dato),
        .d(colum_code[0]),
        .q(ff_out[2])
    );

    output_ff out_ff1 (
        .clk(clk),
        .reset(reset),
        .enable(stop_flag),
        .mostrar_dato(mostrar_dato),
        .d(row_code[1]),
        .q(ff_out[1])
    );

    output_ff out_ff0 (
        .clk(clk),
        .reset(reset),
        .enable(stop_flag),
        .mostrar_dato(mostrar_dato),
        .d(row_code[0]),
        .q(ff_out[0])
    );

    input_sync row0_sync (
        .clk(clk),
        .reset(reset),
        .input_pulse(row[0]),
        .sync_input(sync_row[0])
    );

    input_sync row1_sync (
        .clk(clk),
        .reset(reset),
        .input_pulse(row[1]),
        .sync_input(sync_row[1])
    );

    input_sync row2_sync (
        .clk(clk),
        .reset(reset),
        .input_pulse(row[2]),
        .sync_input(sync_row[2])
    );

    input_sync row3_sync (
        .clk(clk),
        .reset(reset),
        .input_pulse(row[3]),
        .sync_input(sync_row[3])
    );

    clk_cut_module ccm (
        .clk(clk),
        .reset(reset),
        .stop_flag(stop_flag),
        .clk_cut(clk_cut),
        .mostrar_dato(mostrar_dato),
        .enable_input(enable_input),
        .reset_input_ff(reset_input_ff)
    );

    colum_on colum_on_inst (
        .clk_cut(clk_cut),
        .reset(reset),
        .colum(colum),
        .colum_code(colum_code)
    );

    row_detect row_detect_ins (
        .row(stored_row),
        .stop_flag(stop_flag),
        .row_code(row_code)
    );

endmodule
```
#### 2. Parámetros
Aquí se usan como variables internas
```SystemVerilog
    logic stop_flag;
    logic clk_cut;
    logic [1:0] colum_code;
    logic [3:0] sync_row;
    logic [1:0] row_code;
    logic [3:0] ff_out;
    logic mostrar_dato;
    logic [3:0] stored_row;
    logic enable_input;
    logic reset_input_ff;
    logic [15:0] bcd;
    logic [3:0] num_deco_out;
    logic [15:0] bcd_num1;
    logic [15:0] bcd_num2;
    logic [15:0] bin_num1;
    logic [15:0] bin_num2;
    logic neg_flag1;
    logic neg_flag2;
    logic multiplic_flag;
    logic neg_sign_disp;
    logic mult_ready1;
    logic mult_ready2;
    logic mult_result;
    logic [15:0] mult_result_bcd;
    logic result_ok;
    logic [15:0] salida_bcd;
    logic [15:0] z_out;

```
#### 3. Entradas y salidas:
```SystemVerilog
    input logic clk,
    input logic reset,
    input logic [3:0] row,
    output logic [3:0] colum,
    //Variables para 7 segmentos
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
    output logic neg_sign
```
#### 4. Criterios de diseño 
Tomando en cuenta la gran cantidad de módulos involucrados en todo el sistema, diseño se realizó por etapas, donde, lo primero fue asegurar el funcionamiento del teclado con todos los módulos involucrados. Después se agregaron los módulos relacionados con los 7 segmentos para poder ver que el teclado funciona fuera del testbench, en cuanto a la generación de los números. Por último, se agregaron los módulos relacionados con la multiplicadora y otros relacionados para mostrar el resultado.

#### 5. Testbench
```SystemVerilog
module module_call_tb;

    //Declaración de variables
    logic clk;
    logic reset;
    logic [3:0] colum;
    logic [3:0] row;

    //instancia 
    module_call uut(
        .clk(clk),
        .reset(reset),
        .colum(colum),
        .row(row)

    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;  // Reloj con periodo de 10 ns
    end

     initial begin
        // Inicio de la simulación
        $display("TB para module_call");

        // Condiciones iniciales
        reset = 1;        // Activamos el reset al inicio
        row = 0;
        #20 
        reset = 0;    // Desactivamos el reset después de 20 ns
        #40
        row[0] = 1;
        #5
        row[0] = 0;
        #2000
        row[2] = 1;
        #5
        row[2] = 0;
        #2000
        row[3] = 1;
        #5
        row[3] = 0;

        


        // Esperar un número de ciclos suficiente para observar cambios en clk_cut
        #20000;

        // Fin de la simulación
        $display("Testbench finalizado");
        $finish;
    end

    // Monitoreo para observar la salida
    initial begin
        $monitor("Time=%0t | clk=%b | reset=%b | colum=%b | row= %b", $time, clk, reset, colum, row);
    end


    initial begin
        $dumpfile("module_call_tb.vcd");
        $dumpvars(0,module_call_tb);
    end


endmodule
```
Este testbench muestra algunas teclas siendo presionadas, sin embargo, como se tiene poco control del cuando hacer row[x] HIGH de acuerdo a una columna, se usó el testbench principalmente con el Waveview.


## 4. Consumo de recursos
```SystemVerilog
Info: Device utilisation:
Info: 	                 VCC:     1/    1   100%
Info: 	               SLICE:  1477/ 8640    17%
Info: 	                 IOB:    22/  274     8%
Info: 	                ODDR:     0/  274     0%
Info: 	           MUX2_LUT5:   327/ 4320     7%
Info: 	           MUX2_LUT6:   149/ 2160     6%
Info: 	           MUX2_LUT7:    48/ 1080     4%
Info: 	           MUX2_LUT8:    14/ 1056     1%
Info: 	                 GND:     1/    1   100%
Info: 	                RAMW:     0/  270     0%
Info: 	                 GSR:     1/    1   100%
Info: 	                 OSC:     0/    1     0%
Info: 	                rPLL:     0/    2     0%
```

## 5. Problemas encontrados durante el proyecto
Sin duda uno de los mayores problemas fue hacer funcionar el teclado, debido a la multitud de señales que están involucradas, en general, el problema con esto fue asegurar la sincronización de todo el sistema y buscar que la probabiliad de fallo del mismo sea la más baja posible.
Además del teclado, se tuvo problemas con la multiplicadora, debido a que con números pequeños hace la operación correctamente, pero si se ponen, números más grandes deja de funcionar bien.


## Apendices:
### Apendice 1:
texto, imágen, etc
