module bcd_disp (
    input logic clk,                    // Reloj
    input logic reset,                  // Señal de reinicio
    input logic [3:0] nuevo_numero,     // Nuevo número de un dígito en binario
    output logic [15:0] salida_bcd      // Salida BCD (capacidad para 4 dígitos BCD)
);

    // Registro para almacenar la concatenación en formato BCD
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            salida_bcd <= 16'b0;  // Reinicia la salida
        end
        else if (nuevo_numero != 4'b1010) begin
            // Desplaza la salida 4 bits a la izquierda e ingresa el nuevo dígito
            salida_bcd <= (salida_bcd << 4) | nuevo_numero;
        end
    end

endmodule