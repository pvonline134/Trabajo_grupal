module bin_to_bcd_12bit (
    input logic [13:0] bin,    // Número binario de 12 bits (rango 0-4095)
    output logic [15:0] bcd    // Número BCD de 16 bits (cuatro dígitos BCD: miles, centenas, decenas, unidades)
);  
    // Variables internas
    logic [27:0] shift;        // Registros de desplazamiento (suficientes para manejar 12 bits binarios + 4 dígitos BCD)
    int i;                     // Contador

    always_comb begin
        // Inicializa el registro de desplazamiento con el valor binario
        shift = {16'b0, 14'b00111110011111};  // Concatenación de 16 ceros con el valor binario de 12 bits

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