# Nombre del proyecto

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.0 Descripción general del sistema

### 3.1 Subsistema 2
#### 1. Encabezado del módulo
```SystemVerilog
module calculadora_sumadora (
    input logic [3:0] digito,      // Entrada del dígito (0-9)
    input logic clk,               // Reloj
    input logic reset,             // Reset global
    input logic c,                 // Señal para resetear el número actual
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
            if (c) begin
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
- Lista de parámetros

#### 3. Entradas y salidas:
- `input logic [3:0] digito,`: Este input de digito representa el digito de 4 bits proveniente del dipswitch.
- `input logic clk,`: Este input representa el reloj utilizado en el código.
- `input logic reset,`: Este input representa el reset general del código y de la maquina de estados.
- `input logic c,`: Este input representa el botón de borrado (clear) del número.
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
    reg c;
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
        
        // Presionar 'c' para resetear num1
        c = 1;
        #10;
        c = 0;
        
       


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
        c = 1;
        #10;
        c = 0;

        
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

Este testbench prueba el funcionamiento del modulo anterior en diferentes casos, primero se resetea todo para iniciar en ceros, luego en el numero 1 se prueba con el número 555 (en el testbench como se van viendo los dígitos inserción tras inserción), luego se presiona el botón de borrado y se borra el numero, luego se procede con la inserción dígito tras dígito del numero 199, posteriormente, se cambia de estado presionando el botón p, el cual hace que ahora se esté trabajando con el numero 2, para este numero se le insertan los dígitos 9 y 0, formando así el 90 posteriormente se borra el numero con el botón c y luego se insertan los dígitos para formar el número 999, finalmente se efectúa la suma.

Los resultados del testbench se muestran a continuación:
![image](https://github.com/user-attachments/assets/6ed71e5b-ba2c-4525-baa0-df73260a13c7)

#### 6. Binario a BCD
```SystemVerilog
module bin_to_bcd_12bit (
    output logic [11:0] bin,    // Número binario de 12 bits (rango 0-4095)
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
#### 6. Parámetros
- Lista de parámetros

#### 7. Entradas y salidas:
- `input logic [11:0] bin,` : la señal de entrada del sistema es un numero en binario (o decimal).
- `output logic [15:0] bcd,` : la señal de salida del sistema muestra a la entrada en formato bcd.

#### 8. Criterios de diseño
Para este diseño simplemente se siguió el algoritmo del proyecto pasado para lograr pasar un número de binario a bcd con la diferencia que esta vez se usó lógica secuencial y no unicamente sólo lógica combinacional


#### 9. Testbench
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


### Otros modulos
- agregar informacion siguiendo el ejemplo anterior.


## 4. Consumo de recursos

## 5. Problemas encontrados durante el proyecto

## Apendices:
### Apendice 1:
texto, imágen, etc
