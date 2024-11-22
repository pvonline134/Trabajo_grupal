module bcd_binario (
    input logic [7:0] entrada_bcd,    // Entrada BCD (2 dígitos BCD, 8 bits)
    input logic multiplic_flag,
    output logic [7:0] salida_bin,      // Salida en binario (hasta 255 en decimal, 8 bits)
    output logic mult_ready
);

    logic [7:0] decenas;
    logic [7:0] unidades;

    always_comb begin

        if (multiplic_flag) begin
            // Obtenemos los dígitos individuales en BCD
            decenas = entrada_bcd[7:4];  // Decenas en BCD
            unidades = entrada_bcd[3:0]; // Unidades en BCD

            // Calcular (decenas * 10) sin multiplicación
            // 10 * decenas es lo mismo que (8 * decenas) + (2 * decenas)
            salida_bin = (decenas << 3) + (decenas << 1) + unidades;
            mult_ready = 1;
        end
        else begin
            mult_ready = 0;
            salida_bin = 0;
            decenas = 0; 
            unidades = 0; 
        end
    end

endmodule