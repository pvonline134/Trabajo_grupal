module bcd_stored_num (
    input logic clk,                    // Reloj
    input logic reset,                  // Señal de reinicio
    input logic [3:0] nuevo_numero,     // Nuevo número de un dígito en binario
    output logic [15:0] salida_bcd,      // Salida BCD (capacidad para 4 dígitos BCD)
    output logic [15:0] bcd_num1,
    output logic [15:0] bcd_num2,
    output logic multiplic_flag,
    output logic neg_flag1,
    output logic neg_flag2,
    output logic neg_sign
    
);

    // Registro para almacenar la concatenación en formato BCD
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            salida_bcd <= 8'b0;  // Reinicia la salida
            multiplic_flag <= 0;
            //keep_sign_on <= 0;
            neg_flag1 <= 0;
            neg_flag2 <= 0;
            neg_sign <= 0;
            bcd_num1 <= 0;
            bcd_num2 <= 0;
        end
        else if(nuevo_numero == 4'b1111)begin //*
            bcd_num1 <= salida_bcd;
            neg_flag1 <= neg_sign;
            salida_bcd <= 8'b0;
            neg_sign <= 0;
        end 
        else if(nuevo_numero == 4'b1101) begin //D
            bcd_num2 <= salida_bcd;
            neg_flag2 <= neg_sign;
            salida_bcd <= 8'b0;
            multiplic_flag <= 1;
            neg_sign <= 0;
        end
        else if (nuevo_numero == 4'b1110) begin
            neg_sign <= 1;
        end
        else if (nuevo_numero != 4'b1010) begin
            // Desplaza la salida 4 bits a la izquierda e ingresa el nuevo dígito
            salida_bcd <= (salida_bcd << 4) | nuevo_numero;
        end
    end

endmodule