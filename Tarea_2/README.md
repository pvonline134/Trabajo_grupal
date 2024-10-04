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
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas

### Otros modulos
- agregar informacion siguiendo el ejemplo anterior.


## 4. Consumo de recursos

## 5. Problemas encontrados durante el proyecto

## Apendices:
### Apendice 1:
texto, imágen, etc
