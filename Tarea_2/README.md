# Sumador con FPGA

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.0 Descripción general del sistema

### 3.1 FSM para sumar
#### 1. Código
```SystemVerilog
module calculadora_sumadora (
    input logic [3:0] digito,      // Entrada del dígito (0-9)
    input logic clk,               // Reloj
    input logic reset,             // Reset global
    input logic clear_disp,                 // Señal para resetear el número actual
    input logic p,                 // Señal para cambiar entre num1 y num2
    input logic e,                 // Señal para ejecutar la suma
    output logic [11:0] numero1,   // Número 1 (máximo 3 dígitos: centenas, decenas, unidades)
    output logic [11:0] numero2,   // Número 2 (máximo 3 dígitos: centenas, decenas, unidades)
    output logic [11:0] resultado  // Resultado de la suma
);

    logic [1:0] estado;            // Estado para determinar si se está ingresando num1 o num2
    logic [11:0] num1_reg, num2_reg; // Registros internos para num1 y num2

    // Inicialización
    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            num1_reg <= 12'd0;
            num2_reg <= 12'd0;
            estado <= 2'b00; // Empezamos ingresando en num1
            resultado <= 12'd0;
        end
        else begin
            if (clear_disp) begin
                if (estado == 2'b00) begin
                    num1_reg <= 12'd0; // Resetea num1
                end
                else begin
                    num2_reg <= 12'd0; // Resetea num2
                end
            end
            else if (p) begin
                estado <= ~estado; // Cambia entre num1 y num2
            end
            else if (e) begin
                resultado <= num1_reg + num2_reg; // Suma los dos números
            end
            else begin
                // Insertar el dígito
                if (estado == 2'b00) begin
                    // Desplazamiento de número 1
                    if (num1_reg < 999) begin
                        num1_reg <= (num1_reg * 10) + digito;
                    end
                end
                else begin
                    // Desplazamiento de número 2
                    if (num2_reg < 999) begin
                        num2_reg <= (num2_reg * 10) + digito;
                    end
                end
            end
        end
    end

    // Asignar valores de salida
    assign numero1 = num1_reg;
    assign numero2 = num2_reg;

endmodule
```
#### 2. Parámetros
Los parámetros se instanciaron de la siguiente manera:
```SystemVerilog
   calculadora_sumadora calcsum(
        .clk(clk),
        .reset(reset),
        .clear_disp(clear_disp),
        .p(p),
        .e(btnsuma),
        .numero1(int_numero1),
        .numero2(int_numero2),
        .resultado(int_resultado),
        .estado(int_estado),
        .digito(digito),
        
    );
```

#### 3. Entradas y salidas:
- `input logic [3:0] digito,`: Este input de digito representa el digito de 4 bits proveniente del dipswitch.
- `input logic clk,`: Este input representa el reloj utilizado en el código.
- `input logic reset,`: Este input representa el reset general del código y de la maquina de estados.
- `input logic clear_disp,`: Este input representa el botón de borrado (clear) del número.
- `input logic p,`: Este input es el responsable del cambio de estado (pasa a trabajar ahora con los números del dígito 2).
- `input logic e,`: Este input es el que se encarga de realizar la suma final.
- `output logic [11:0] numero1,`: Esta salida representa al primer número en la suma.
- `output logic [11:0] numero2,`: Esta salida representa al segundo número en la suma.
- `output logic [11:0] resultado,`: Esta salida representa el resultado de la suma.

#### 4. Criterios de diseño
Los criterios de diseño se basan principalmente en el siguiente diagrama que representa las máquinas de estados de este módulo.
![image](https://github.com/user-attachments/assets/d04c32dd-a04a-4ed8-95b7-c1bd9bae3ea4)
![image](https://github.com/user-attachments/assets/213193fe-1b73-489e-9ee3-737eac4236c3)
La primera imagen parte de un estado M el cual al recibir un numero o un digito (N), el cual pasa al siguiente estado (A), este estado representa el primer número el cual será utilizado en la suma, al recibir N esta quedará guardada en las unidades de este número, posteriormente se regresa al estado M y se repetirá el proceso hasta máximo llegar a los tres dígitos, habrán desplazamientos es decir lo que está en las unidades pasará a las decenas y luego a las centenas es por eso que la salida de este módulo tiene tres posibles salidas un número con sólo unidades un número con decenas y unidades y un número con centenas decenas y unidades.
Si se llegase a recibir la señal de borrado (PC) se borrará todo lo que este dentro del primer número, llenandolo de ceros.
Si se preciona el botón de p (en la maquina de estados es *) se comenzará atrabajat con el segundo numero de la operación y se repetirá el proceso anterior solo que ahora en el número 2.

La imagen 2 muestra la otra maquina de estados, esta se encarga de realizar la suma, al precionar el botón de e (en la maquina de estados se representa con #), el estado C representa el resultado de la suma, ya que su salida es la suma de los numeros.


#### 5. Testbench
```SystemVerilog
`timescale 1ns/1ps
module tb_calculadora_sumadora;

    // Entradas
    reg [3:0] digito;
    reg clk;
    reg reset;
    reg clear_disp;
    reg p;
    reg e;

    // Salidas
    wire [11:0] numero1;
    wire [11:0] numero2;
    wire [11:0] resultado;

    // Instanciar la calculadora sumadora
    calculadora_sumadora uut (
        .digito(digito),
        .clk(clk),
        .reset(reset),
        .c(c),
        .p(p),
        .e(e),
        .numero1(numero1),
        .numero2(numero2),
        .resultado(resultado)
    );

    // Generar el reloj
    always #5 clk = ~clk;

    initial begin
        // Inicialización
        clk = 0;
        reset = 1;
        c = 0;
        p = 0;
        e = 0;
        digito = 0;
        
        // Esperar un ciclo de reloj
        #10;
        reset = 0;
        
        // Paso 1: num1 = 555
        digito = 4'd5;
        #10;
        digito = 4'd5;
        #10;
        digito = 4'd5;
        #10;
        
        // Presionar 'clear_disp' para resetear num1
        clear_disp = 1;
        #10;
        clear_disp = 0;
        
       


        digito = 0001;

        #10;
        digito = 4'd9;
        #10;
        digito = 4'd9;
        #10;

        // Presionar 'p' para cambiar a num2
        p = 1;
        #10;
        p = 0;

        // Paso 4: num2 = 8
        digito = 4'd9;
        #10;

      
        digito = 4'd0;
        #10;
        clear_disp = 1;
        #10;
        clear_disp = 0;

        
        digito = 4'd9;
        #10;
        digito = 4'd9;
        #10;
        digito = 4'd9;
        #10;

        // Presionar 'e' para sumar num1 y num2
        e = 1;
        #10;
        e = 0;

        // Finalizar la simulación
       
        $finish;
    end

    // Monitorizar cambios en las señales para verificar resultados
    initial begin
        $monitor("numero1=%0d, numero2=%0d, resultado=%0d", numero1, numero2, resultado);
    end






        initial begin
        $dumpfile ("tb_calculadora_sumadora.vcd");
        $dumpvars (0, tb_calculadora_sumadora);
    end
endmodule
```

Este testbench prueba el funcionamiento del modulo anterior en diferentes casos, primero se resetea todo para iniciar en ceros, luego en el numero 1 se prueba con el número 555 (en el testbench como se van viendo los dígitos inserción tras inserción), luego se presiona el botón de borrado y se borra el numero, luego se procede con la inserción dígito tras dígito del numero 199, posteriormente, se cambia de estado presionando el botón p, el cual hace que ahora se esté trabajando con el numero 2, para este numero se le insertan los dígitos 9 y 0, formando así el 90 posteriormente se borra el numero con el botón de borrado y luego se insertan los dígitos para formar el número 999, finalmente se efectúa la suma.

Los resultados del testbench se muestran a continuación:
![image](https://github.com/user-attachments/assets/6ed71e5b-ba2c-4525-baa0-df73260a13c7)

### 3.2 Conversión de binario a BCD
#### 1. Código
```SystemVerilog
module bin_to_bcd_12bit (
    input logic [11:0] bin,    // Número binario de 12 bits (rango 0-4095)
    output logic [15:0] bcd    // Número BCD de 16 bits (cuatro dígitos BCD: miles, centenas, decenas, unidades)
);  
    // Variables internas
    logic [27:0] shift;        // Registros de desplazamiento (suficientes para manejar 12 bits binarios + 4 dígitos BCD)
    int i;                     // Contador

    always_comb begin
        // Inicializa el registro de desplazamiento con el valor binario
        shift = {16'b0, bin};  // Concatenación de 16 ceros con el valor binario de 12 bits

        // Algoritmo de Doble Desplazamiento (Double Dabble)
        for (i = 0; i < 12; i = i + 1) begin
            // Si el dígito en los miles es mayor o igual a 5, suma 3
            if (shift[27:24] >= 5)
                shift[27:24] = shift[27:24] + 3;

            // Si el dígito en las centenas es mayor o igual a 5, suma 3
            if (shift[23:20] >= 5)
                shift[23:20] = shift[23:20] + 3;

            // Si el dígito en las decenas es mayor o igual a 5, suma 3
            if (shift[19:16] >= 5)
                shift[19:16] = shift[19:16] + 3;

            // Si el dígito en las unidades es mayor o igual a 5, suma 3
            if (shift[15:12] >= 5)
                shift[15:12] = shift[15:12] + 3;

            // Desplaza el registro hacia la izquierda una posición
            shift = shift << 1;
        end

        // Asigna los 16 bits BCD de la salida
        bcd = shift[27:12];   // Los 16 bits de más alto valor contienen el BCD resultante
    end
endmodule
```
#### 2. Parámetros
Instanciación del módulo de binario a BCD:
``` SystemVerilog
    bin_to_bcd_12bit bin2bcd (
        .bin(binario),
        .bcd(int_bcd)
    );
```
#### 3. Entradas y salidas:
- `input logic [11:0] bin,` : la señal de entrada del sistema es un numero en binario (o decimal).
- `output logic [15:0] bcd,` : la señal de salida del sistema muestra a la entrada en formato bcd.

#### 4. Criterios de diseño
Para este diseño simplemente se siguió el algoritmo del proyecto pasado para lograr pasar un número de binario a bcd con la diferencia que esta vez se usó lógica secuencial y no unicamente sólo lógica combinacional


#### 5. Testbench
```SystemVerilog
`timescale 1ns/1ps
module tb_bin_to_bcd_12bit;

    // Señales para la DUT (Device Under Test)
    logic [11:0] bin;      // Entrada binaria
    logic [15:0] bcd;      // Salida en BCD

    // Instancia del módulo bin_to_bcd_12bit
    bin_to_bcd_12bit uut (
        .bin(bin),
        .bcd(bcd)
    );

    // Proceso inicial para aplicar los estímulos
    initial begin
        // Monitor para observar los cambios de las señales
        $monitor("Tiempo: %0t | Binario: %b (%0d) | BCD: %b", $time, bin, bin, bcd);

        // Estímulo 1: Número 0
        bin = 12'b000000000000;  // 0 en binario
        #10;  // Espera 10 unidades de tiempo
        
        // Estímulo 2: Número 5
        bin = 12'b000000000101;  // 5 en binario
        #10;
        
        // Estímulo 3: Número 12
        bin = 12'b000000001100;  // 12 en binario
        #10;

        // Estímulo 4: Número 123
        bin = 12'b000001111011;  // 123 en binario
        #10;

        // Estímulo 5: Número 999
        bin = 12'b001111001111;  // 999 en binario
        #10;

        // Estímulo 6: Número 4095 (máximo número de 12 bits)
        bin = 12'b111111111111;  // 4095 en binario
        #10;

        // Fin de la simulación
        $finish;
    end




  
    initial begin
        $dumpfile ("tb_bin_to_bcd_12bit.vcd");
        $dumpvars (0, tb_bin_to_bcd_12bit);
    end

endmodule
```

Este testbench prueba el funcionamiento del modulo anterior en diferentes numeros, primero se transforma a bcd el numero 0 luego el 5, luego el 12, el 123, el 975 y finalmente el 4095.

Los resultados se muestran acontinuación:
![image](https://github.com/user-attachments/assets/b70e83de-6281-4452-ad2f-78908d58c56d)

### 3.3 Teclado 4x4
### 1. Código

```SystemVerilog
module lector_4x4 (
    input logic clk,
    input logic rst,
    input logic [3:0] fila,    // Fila del teclado
    output logic [3:0] columna, // Columna del teclado
    output logic [3:0] num,     // Dígito presionado
    output logic valido         // Número capturado
);

// Estados
typedef enum logic [2:0] {
    rep          = 3'b000,  // Reposo
    scan_fila    = 3'b001,  // Escaneo fila
    scan_col     = 3'b010,  // Escaneo columna
    captura_num   = 3'b011,  // Captura de dígito
    espera       = 3'b100   // Espera a que el botón deje de presionarse 
} Estado;

Estado Estado_act, Estado_sig;

logic [1:0] col_contador;     // Contador de columnas
logic [3:0] num_actual;       // Registro para el número capturado

// Configuracion de reset
always_ff @(posedge clk or negedge rst) begin
    if (rst) begin
        Estado_act <= rep;
        col_contador <= 2'b00;  // Asegura que col_contador se inicializa en el estado de reposo
        num_actual <= 4'b0000;  // Inicializa num_actual para evitar latch
    end 
end

// Lógica de transición y salida
always_comb begin
    // Asignaciones por defecto para evitar latches
    Estado_sig = Estado_act;
    columna = 4'b1111;       // Deshabilitar columnas por defecto
    valido = 1'b0;           // Deshabilitar el valor válido
    num = 4'b0000;           // Asignar un valor predeterminado a `num`
    col_contador = 2'b00;    // Inicializar col_contador con un valor predeterminado
    num_actual = 4'b0000;    // Inicializar num_actual con un valor predeterminado para evitar latch

    case (Estado_act)

        rep: begin
            if (fila != 4'b1111)  // Verificar si hay fila presionada
                Estado_sig = scan_fila;
        end

        scan_fila: begin
            columna = 4'b1110;      // Activar columna 0
            Estado_sig = scan_col;
        end

        scan_col: begin
            // Reasignación de col_contador en cada estado de la columna
            case (col_contador)
                2'b00: columna = 4'b1110; // Activar columna 0
                2'b01: columna = 4'b1101; // Activar columna 1
                2'b10: columna = 4'b1011; // Activar columna 2
                2'b11: columna = 4'b0111; // Activar columna 3
            endcase

            if (fila != 4'b1111) begin  // Si alguna tecla es presionada
                num_actual = capturar_tecla(fila, col_contador);  // Capturar dígito
                Estado_sig = captura_num;
            end else begin
                col_contador = col_contador + 1;  // Incrementar el contador

                if (col_contador == 2'b11) begin
                    col_contador = 2'b00;         // Reiniciar el contador al final de las columnas
                    Estado_sig = rep;             // Volver al estado de reposo
                end
            end
        end

        captura_num: begin
            num = num_actual;  // Dígito a la salida
            valido = 1'b1;     // Señal de dígito válido
            Estado_sig = espera;
        end

        espera: begin
            if (fila == 4'b1111) // Soltar tecla
                Estado_sig = rep;
        end

    endcase
end

// Función para capturar el número en función de la fila y columna activada
function logic [3:0] capturar_tecla(input logic [3:0] fila, input logic [1:0] columna);
    case ({fila, columna})
        6'b1110_00: capturar_tecla = 4'd1;
        6'b1110_01: capturar_tecla = 4'd2;
        6'b1110_10: capturar_tecla = 4'd3;
        6'b1110_11: capturar_tecla = 4'd0;  // A

        6'b1101_00: capturar_tecla = 4'd4;
        6'b1101_01: capturar_tecla = 4'd5;
        6'b1101_10: capturar_tecla = 4'd6;
        6'b1101_11: capturar_tecla = 4'd0;  // B

        6'b1011_00: capturar_tecla = 4'd7;
        6'b1011_01: capturar_tecla = 4'd8;
        6'b1011_10: capturar_tecla = 4'd9;
        6'b1011_11: capturar_tecla = 4'd0;  // C

        6'b0111_00: capturar_tecla = 4'd0;  // *
        6'b0111_01: capturar_tecla = 4'd0;
        6'b0111_10: capturar_tecla = 4'd0;  // #
        6'b0111_11: capturar_tecla = 4'd0;

        default: capturar_tecla = 4'd0;
    endcase
endfunction

endmodule
```
### 2. Parámetros 

El teclado no resultó con el comportamiento deseado tras realizar testbenches de comprobación, por lo que no se instanció en ningún momento durante la elaboración del proyecto.

### 3. Entradas y Salidas
-	`input logic clk` : Esta señal representa el reloj del sistema.
-	`input logic rst` : Esta señal representa el reset del sistema.
-	`input logic [3:0] fila` : Este arreglo representa la entrada de la fila presionada.
-	`output logic [3:0] columna` : Este arreglo representa la columna de la tecla presionada.
-	`output logic [3:0] num` : Este arreglo representa el número capturado y decodificado que pasaría a la siguiente etapa.
-	`output logic valido`   : Esta señal permite ratificar la validez del dato capturado, pese a que pueden haber múltiples capturas.

### 4. Criterios de diseño
Para el diseño del código se realizó un seguimiento de la máquina de estados mostrada en la siguiente imagen: 
![image](https://github.com/user-attachments/assets/e2ad71b9-0f66-450a-a4f1-ee97e53b6fba)

Esta máquina consta de 5 estados en la que dos de ellos está resumidos. Inicialmente el teclado se va a encontrar en “rep” que corresponde al estado de reposo del teclado, cuando nada es presionado o se presiona reset, este va a ser el estado designado. El teclado mantiene todas las filas y columnas encendidas, en el momento en el que se presiona una tecla se da una obstrucción de flujo,  en ese momento que se presiona una tecla se pasa al estado “scan fila”, este corresponde a un input que detectará cual fue la fila de la tecla presionada. Sino se detectó cual fue la fila presionada se pasa al estado de reposo, pero si se detecta correctamente se pasa al estado “scan col”, en este estado se está realizando un cambio constante de la columna activa (apagada realmente) a ritmo del clock, este “shift” entre la columna permite conocer cual fue la tecla presionada. Si esto no es así se vuelve al estado de reposo, pero si se encuentra la tecla presionada se pasa al estado “captura num”, en este se guarda un arreglo de 8 bits donde los primero 4 corresponden a la fila y los últimos 4 a la columna. Si no se realiza una captura se vuelve al estado de escaneo de columna, lo que permitirá capturar de nuevo cuando se de la oportunidad. Si se da una correcta captura se pasa al estado de espera, en este únicamente se espera a que la tecla deje de estar presionada para volver al estado de reposo, esto se hace para que no se de una captura múltiple de un mismo número. 
Además, este módulo posee un decodificador que permite la interpretación de los arreglos de 8 bits como un número o letra (tecla de función) según la tecla presionada en la matriz 4x4.

### 5. Testbench
```SystemVerilog
`timescale 1ns/1ps

module lector_4x4_tb;

    // Señales
    reg clk;                // Señal de reloj
    reg rst;                // Señal de reset
    reg [3:0] fila;         // Entradas de filas
    wire [3:0] columna;     // Salida de columnas
    wire [3:0] num;         // Salida del dígito presionado
    wire valido;            // Señal de número capturado válido

    // Instanciar el diseño del teclado 4x4
    lector_4x4 uut (
        .clk(clk),
        .rst(rst),
        .fila(fila),
        .num(num),
        .columna(columna),
        .valido(valido)
    );

    // Generación de la señal de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Generar reloj con un periodo de 10 unidades de tiempo
    end

    // Testbench
    initial begin
        // Inicialización
        rst = 1;
        fila = 4'b1111; // Ninguna tecla presionada

        #20 
        rst = 0;    // Liberar el reset

        // Escenario 1: Simular pulsación de la tecla en fila 0 y columna 0
        fila = 4'b1110; // La fila 0 está activada (tecla presionada)
        #20;            // Esperar un ciclo de escaneo de columnas
        fila = 4'b1111; // Liberar la tecla
        
        // Escenario 2: Simular pulsación de la tecla en fila 2 y columna 1
        #50;
        fila = 4'b1011; // La fila 2 está activada (tecla presionada)
        #20;
        fila = 4'b1111; // Liberar la tecla
        
        // Escenario 3: Simular pulsación de la tecla en fila 3 y columna 2
        #50;
        fila = 4'b0111; // La fila 3 está activada (tecla presionada)
        #20;
        fila = 4'b1111; // Liberar la tecla

        // Terminar la simulación
        #100;
        $finish;
    end

    // Monitor para observar los resultados
    initial begin
        $monitor("Time: %0t | Fila: %b | Columna: %b | Digito capturado: %0d | Valido: %b",
                  $time, fila, columna, num, valido);
    end

    initial begin
        $dumpfile("lector_4x4_tb.vcd");
        $dumpvars(0, lector_4x4_tb);
    end

endmodule
```
Para realizar pruebas sobre el módulo diseñado se hizo input de distintas filas presionando distintas teclas en el teclado, este debía imprimir en la consola la columna en la cual se detuvo para hacer la captura, el dígito capturado en decimal, y si el digito era válido o no. El resultado de la consola se ve a continuación:

![image](https://github.com/user-attachments/assets/c1bda661-8c17-4e9c-afb3-2318552e309a)

Esta fue la última prueba realizada previo al cambio de intrucciones para trabajar con el dip switch, en esta última version no se estaba realizando un correcto shift de las columnas.

### 3.4 Decodificador de DipSwitch
### 1. Código

```SystemVerilog
module dipswitch_decoder (
    input logic [3:0] dipswitch, // Entrada de 4 bits del dipswitch
    input logic button,          // Entrada del botón
    input logic clk,             // Entrada del reloj
    input logic rst,             // Entrada de reset asíncrono
    output logic [3:0] digito    // Salida que guarda el valor del dipswitch
);

    // Registro para almacenar el valor anterior del dipswitch
    logic [3:0] last_value;
    // Registro para indicar si el botón fue presionado
    logic button_pressed;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            digito <= 4'b0000;       // Resetear el dígito a cero
            last_value <= 4'b0000;   // Resetear el valor anterior
            button_pressed <= 1'b0;   // Reiniciar el estado del botón
        end else begin
            if (button) begin
                // Si el botón está presionado y es diferente del último estado
                if (!button_pressed) begin
                    digito <= dipswitch;  // Actualizar el dígito con el valor del dipswitch
                    last_value <= dipswitch; // Guardar el último valor
                end
                button_pressed <= 1'b1;   // Marcar que el botón fue presionado
            end else begin
                button_pressed <= 1'b0;   // Reiniciar el estado del botón
            end
        end
    end

endmodule
```
### 2. Parámetros

Los parámetros del módulo se instanciaron de la siguiente manera:
```SystemVerilog
 dipswitch_decoder dipdec(
        .clk(clk),
        .button(boton),
        .rst(reset),
        .dipswitch(dipswitch),
        .digito(digito)
    );
```
### 3. Entradas y Salidas

-	`input logic [3:0] dipswitch` :  Arreglo de 4 bits del número a introducir 
-	`input logic button` : Señal de botón para aceptar el arreglo del dipswitch.
-	`input logic clk` : Esta señal representa el reloj del sistema.
-	`input logic rst` : Entrada de reset del sistema.           
-	`output logic [3:0] digito` : Arreglo de número de salida para la siguiente etapa.

### 4. Criterios de diseño

Este es un módulo sencillo que permite capturar y decodificar un número en binario colocado en un dipswitch tras ser presionado un botón. El botón de reset hace que el último dígito capturado sea 0 y que el botón pase a ser cero. Posteriormente, el código cuenta con un condicional que una vez presionado el botón el valor del dipswitch se guarda en “Digito”, y este número luego es decodificado y utilizado en la próxima etapa. 

### 5. Testbench
```SystemVerilog
module tb_dipswitch_decoder;

    // Parámetros de simulación
    parameter CLK_PERIOD = 10; // Periodo del reloj en ns

    // Señales de prueba
    logic [3:0] dipswitch;
    logic button;
    logic clk;
    logic rst;
    logic [3:0] digito;

    // Instancia del módulo a probar
    dipswitch_decoder uut (
        .dipswitch(dipswitch),
        .button(button),
        .clk(clk),
        .rst(rst),
        .digito(digito)
    );

    // Generador de reloj
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // Invierto el reloj cada medio periodo
    end

    // Proceso de prueba
    initial begin
        // Inicialización
        rst = 1; // Activar reset
        button = 0;
        dipswitch = 4'b0000;
        #(CLK_PERIOD); // Esperar un ciclo de reloj

        // Desactivar el reset
        rst = 0;
        #(CLK_PERIOD); // Esperar un ciclo de reloj

        // Caso 1: Cambiar dipswitch y presionar botón
        dipswitch = 4'b0001; // Valor del dipswitch
        button = 1;          // Presionar el botón
        #(CLK_PERIOD); // Esperar un ciclo de reloj
        button = 0;          // Soltar el botón
        #(CLK_PERIOD); // Esperar un ciclo de reloj
        $display("Dipswitch: %b, Digito: %b", dipswitch, digito); // Mostrar resultado

        // Caso 2: Cambiar dipswitch y presionar botón
        dipswitch = 4'b0010; // Nuevo valor del dipswitch
        button = 1;          // Presionar el botón
        #(CLK_PERIOD); // Esperar un ciclo de reloj
        button = 0;          // Soltar el botón
        #(CLK_PERIOD); // Esperar un ciclo de reloj
        $display("Dipswitch: %b, Digito: %b", dipswitch, digito); // Mostrar resultado

        // Caso 3: Probar el mismo valor sin presionar el botón
        dipswitch = 4'b0010; // Mismo valor del dipswitch
        #(CLK_PERIOD); // Esperar un ciclo de reloj
        $display("Dipswitch: %b, Digito: %b", dipswitch, digito); // Mostrar resultado

        // Caso 4: Cambiar dipswitch y presionar botón
        dipswitch = 4'b0100; // Nuevo valor del dipswitch
        button = 1;          // Presionar el botón
        #(CLK_PERIOD); // Esperar un ciclo de reloj
        button = 0;          // Soltar el botón
        #(CLK_PERIOD); // Esperar un ciclo de reloj
        $display("Dipswitch: %b, Digito: %b", dipswitch, digito); // Mostrar resultado

        // Fin de la simulación
        $finish;
    end



 
    initial begin
        $dumpfile ("tb_dipswitch_decoder.vcd");
        $dumpvars (0, tb_dipswitch_decoder);
    end

endmodule
```
En este testbench se introdujeron posibles valores en la variable de entrada dipswitch y se simuló la señal de botón para capturar cuando es adecuado. También se probaron valores de dipswitch sin presionar el botón, lo que hizo que no se imprimieran los resultados. Tras finalizar el testbench la consola mostró lo siguiente:

![image](https://github.com/user-attachments/assets/2b9857d0-b2a9-4980-ad57-19526e6565c8)

### 3.5 Control de los 7 segmentos
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
    output logic a, b, c, d, e,
    output logic dispuni,     
    output logic dispdec,
    output logic dispcen,
    output logic dispmil,
    output logic [1:0] disp,
    output reg clk_cut,
    input logic [15:0] bcd

);

    reg [31:0] counter;    // Contador de ciclos de reloj
    // Estado inicial
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_cut <= 0;
        end else begin
            if (counter == (1000-1)) begin
                counter <= 0;
                clk_cut <= ~clk_cut;  // Cambia la señal de salida
            end else begin
                counter <= counter + 1;
            end 
        end
    end

    reg [1:0] cycle_count;
            // Variable para contar los ciclos
    always @(posedge clk_cut) begin
        begin
            // Cambiar variables de acuerdo con el ciclo
            case (cycle_count)
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
            cycle_count <= cycle_count + 1;
        end
        if (reset) begin
            a = 0;
            b = 0;
            c = 0;
            d = 0;
            e = 0;
        end
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
### 2. Parámetros 
``` SystemVerilog
    seg7_disp s7d (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .segA(segA),
        .segB(segB),
        .segC(segC),
        .segD(segD),
        .segE(segE),
        .segF(segF),
        .segG(segG),
        .dispuni(dispuni),      // Conectar salidas
        .dispdec(dispdec),
        .dispcen(dispcen),
        .dispmil(dispmil),
        .clk_cut(clk_cut),
        .disp(disp),
        .bcd(int_bcd)
    );
```
### 3. Entradas y Salidas
-	`input logic [15:0] bcd` : Entrdad en BCD para mostrar el digito cada display.
-	`input logic clk y reset` : Entradas de reloj y reset para sincronización.
-	`output logic segX` La salida de cada segmento de los display.
-	`output logic a, b, c, d, e,` : Valores binarios de cada dígito d:menos significativo a:más signficiativo e: variable con valor 0, siempre.
-	`output logic dispuni` : Salida de transistor para display de unidades.
-	`output logic dispdec` : Salida de transistor para display de decena.
-	`output logic dispcen` : Salida de transistor para display de centenas.
-	`output logic dispmil` : Salida de transistor para display de miles.
-	`output logic [1:0] disp` : Variable usada para sincronizar transistor con digito a mostrar.
-	`output reg clk_cut` : Señal de reloj pasada por un divisor de frecuencia.

### 4. Criterios de diseño
Primero se va a hablar de las salidas de los transistores, pues, esto fue con lo que se empezó. Al principio se notó que al conectar la salida del reloj a los transistores hacía que la señal de reloj se callera, esto se observó un osciloscopio. Se notó que al bajar la frecuencia, este efecto se veía reducido en gran medida. Por esto la primera parte del código, desde la línea 22 hasta la 36, consiste en un divisor de frecuencia. Al hacer esto, la señal llegaba de manera apropiada a cada transistor.

Desde la línea 38 hasta la 72, el código consiste en un case, el cual enciende y apaga los transistores de manera que solo uno esté encendido a la vez. La variable "cycle_count" es de 2 bits, al pasar los 4 estados (cada transistor se encendió una vez), este hace overflow y se reinicia el ciclo. La variable "disp" se usa para escoger el valor del arreglo de BCD se debe mostar en ese momento. Aquí hay que aclarar que solo se usaron 7 líneas para los cuatro 7 segmentos, por esto es que se usa este código, el cual enciende y apaga los transistores de manera sincronizada, a la vez que el dígito a mostrar se envía por las 7 líneas, esto ocurre tan rápido que parece que todos están encendidos a la vez y se logra mostrar 4 dígitos distintos con las mismas 7 salidas.

De la línea 77 hasta la 113, se usa la variable "disp" junto con un case para seleccionar los valores del arreglo de BCD a mostar. 

Por último, de la 116 hasta el final, se usa código combinacional con ecuaciones booleanas, esto se usa para encender cada segmentos dependiendo del número (en binario) indicado por el arreglo BCD antes mencionado.

A continuación se muestan imágenes de osciloscopio donde se observa cada transistor encendiendoce y apagandoce. Dado que son transistores PNP, estos se encienden cuando la entrada de la base es cero o low.  (Dado que no se contaba con un osciloscopio de 4 canales, se muestran dos osciloscopio de 2 canales, la idea es que se vea el comportamiento de las señales y no tanto el timming).
![DS0001](https://github.com/user-attachments/assets/a67f68f2-e82e-4644-8bbc-72702a57869d)

![DS0003](https://github.com/user-attachments/assets/fe82790a-55ad-40fb-879a-bb13e1e62c59)



### 3.6 Selector de valor a mostrar

### Código
``` SystemVerilog
module show_num (
    input logic estado,  // Señal de control proveniente de otro módulo
    input logic btnsum,
    input logic [11:0] numero1,    // Primera entrada
    input logic [11:0] numero2,    // Segunda entrada
    input logic [11:0] resultado,
    output logic [11:0] binario
);

    always_comb begin
        if (btnsum) begin
            binario = resultado;
        end 
        else begin
            if (estado == 2'b00)begin
            binario = numero1;
            end
            else begin
            binario = numero2;
            end
        end
    end

endmodule
```
### 2. Parámetros 
``` SystemVerilog
    show_num shnum (
        .estado(int_estado),
        .numero1(int_numero1),
        .numero2(int_numero2),
        .resultado(int_resultado),
        .binario(binaro),
        .btnsum(btnsuma)
    );
```
### 3. Entradas y Salidas
- `input logic estado` : Viene de la FSM se usa para saber que número se está insertando y con ello cual mostrar.
- `input logic btnsum` : Viene de la FSM indica si se está haciendo la suma (a + b), mientras se mantenga apretado el botón de btnsum se mostrará el resultado.
- `input logic [11:0] numero1` :Valor binario del primer sumando.
- `input logic [11:0] numero2` :Valor binario del segundo sumando.
- `input logic [11:0] resultado` :Resultado de la suma.
- `output logic [11:0] binario` :Salida que irá al código del 7 segmentos para mostrar el número deseado.

### 4. Criterios de diseño
Dado que los valores que se desearían mostrar en los 7 segmentos están guardados en variables es necesario un código el cual lea estas variables y las envíe al código del punto 3.5 para ser mostradas dependiendo de impulsos de entrada, estos determinan que se mostrará.
Este código presenta un tipo de jerarquía, donde el botón btnsuma cuando es apretado, restringe que se muestre numero 1 y numero2. Si no está apretado y si "estado" =0, se muestra numero1, de lo contrario se muestra número2.

### 5. Testbench

``` SystemVerilog
module tb_bin_to_bcd_12bit;

  // Declaración de señales para el DUT (Device Under Test)
  logic estado;
  logic btnsum;
  logic [11:0] numero1;
  logic [11:0] numero2;
  logic [11:0] resultado;
  logic [11:0] binario;

  // Instanciar el DUT
  show_num uut (
    .estado(estado),
    .btnsum(btnsum),
    .numero1(numero1),
    .numero2(numero2),
    .resultado(resultado),
    .binario(binario)
  );

  // Bloque inicial para la simulación
  initial begin
    // Inicializar señales con valores binarios
    btnsum = 0;
    estado = 0;
    numero1 = 12'b101010101010;  // Valor binario para numero1
    numero2 = 12'b010101010101;  // Valor binario para numero2
    resultado = 12'b111100001111; // Valor binario para resultado

    // Simulación de los casos con btnsum = 1
    #10;
    btnsum = 1; // Cuando btnsum es 1, binario debe ser igual a "resultado"
    #10;

    // Cambiar btnsum a 0 y verificar estado == 0 (binario debe ser numero1)
    btnsum = 0;
    estado = 0;
    #10;

    // Cambiar estado a 1 (binario debe ser numero2)
    estado = 1;
    #10;

    // Finalizar la simulación
    $stop;
  end

  // Monitor para observar los valores de binario, estado y btnsum
  initial begin
    $monitor("Time=%0t | btnsum=%b | estado=%b | numero1=%b | numero2=%b | resultado=%b | binario=%b", 
              $time, btnsum, estado, numero1, numero2, resultado, binario);
  end
  
    initial begin
        $dumpfile ("tb_bin_to_bcd_12bit.vcd");
        $dumpvars (0, tb_bin_to_bcd_12bit);
    end

endmodule
```
En la terminal se muestran los siguientes valores:
![image](https://github.com/user-attachments/assets/48e7e89f-0747-47b4-8147-ead5678196d6)
Vease que cuando btnsuma = 1, no importa el valor de estado, pues, este está por encima en la jerarquía. Cuando btnsuma = 0, el valor de "binario" cambia entre numero1 y numero2 dependiendo del valor de "estado".


### Otros modulos
Se muesta tambien el "top_module" o modulo principal:

``` SystemVerilog
module module_call(
    input logic clk,            // Señal de reloj
    input logic reset,          // Señal de reset
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
    output logic [1:0] disp,
    output reg clk_cut,
    output logic a, b, c, d, e,
    input logic boton,     
    input logic clear_disp,
    input logic p,
    input logic btnsuma,
    input logic [3:0] dipswitch,
    output logic [3:0] digito,
    output logic [11:0] binario

);  

    logic [11:0] int_numero1;
    logic [11:0] int_numero2;
    logic [11:0] int_resultado;
    logic int_estado;
    logic [3:0] int_digito;
    logic [11:0] int_binario;
    logic [15:0] int_bcd;


    dipswitch_decoder dipdec(
        .clk(clk),
        .button(boton),
        .rst(reset),
        .dipswitch(dipswitch),
        .digito(digito)
    );
    
    calculadora_sumadora calcsum(
        .clk(clk),
        .reset(reset),
        .clear_disp(clear_disp),
        .p(p),
        .e(btnsuma),
        .numero1(int_numero1),
        .numero2(int_numero2),
        .resultado(int_resultado),
        .estado(int_estado),
        .digito(digito),
        .boton(boton)
    );
    
    // Instanciación modulo binario a bcd
    bin_to_bcd_12bit bin2bcd (
        .bin(binario),
        .bcd(int_bcd)
    );

    show_num shnum (
        .estado(int_estado),
        .numero1(int_numero1),
        .numero2(int_numero2),
        .resultado(int_resultado),
        .binario(binaro),
        .btnsum(btnsuma)
    );

    // Instanciación modulo 7 segmentos
    seg7_disp s7d (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .segA(segA),
        .segB(segB),
        .segC(segC),
        .segD(segD),
        .segE(segE),
        .segF(segF),
        .segG(segG),
        .dispuni(dispuni),      // Conectar salidas
        .dispdec(dispdec),
        .dispcen(dispcen),
        .dispmil(dispmil),
        .clk_cut(clk_cut),
        .disp(disp),
        .bcd(int_bcd)
    );



endmodule

```



## 4. Consumo de recursos
Dado que no se pudo obtener la totalidad del proyecto, esta información estará incompleta, sin embargo, de lo que se logró se obtuvieron los siguientes datos de consumo de recursos.

![pnr](https://github.com/user-attachments/assets/787055e7-3802-47a7-836e-0d76e80c7e7d)

## 5. Problemas encontrados durante el proyecto
Para la realización de este proyecto el equipo se topó con multitud de problemas y errores a la hora de implementar cada unos de los módulos.
Para el teclado, el principal problema fue capturar los datos, la implementación del clk probó ser un reto, el cual, no se pudo superar. A la hora de que la señal de cada línea de hacía "low" se complicaba capturar la señal por la entrada de datos de la FPGA.
Para el dipswitch, se tuvieron más o menos los mismos problemas, pues, si se logró capturar los datos provenientes de este, sin embargo, el problema fue la sincronización del mundo real al digital, debido a esto, no se logró insertar los datos de manera apropiada.
En cuanto a la FSM para sumar y la codificación de bianrio a BCD, no hubo mayores problemas más allá del reto que ya supone el diseño de un módulo. Estos funcionaron apropiadamente salvo algunos detalles. En específico con la FSM, que al cambiar de teclado a dipswitch se presentaron problemas.



