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

## 4. Consumo de recursos

## 5. Problemas encontrados durante el proyecto

## Apendices:
### Apendice 1:
texto, imágen, etc
