module gray_to_binary_leds (
    input  logic [3 : 0] gray,  // Entrada: Código Gray (4 bits)
    output logic [3 : 0] binary, // Salida: Código Binario (N bits)
    output logic [3 : 0] leds // salida: leds
);



    // Lógica combinacional para la decodificación
    always_comb begin
        // gray_code a binary_code usando compuertas lógicas

        binary[3] = gray [3];
        binary[2] = gray [3] ^ gray [2];
        binary[1] = binary [2] ^ gray [1];
        binary[0] = binary [1] ^ gray [0];

        leds[3] = ~binary[3];
        leds[2] = ~binary[2];
        leds[1] = ~binary[1];
        leds[0] = ~binary[0];
        
    end

endmodule
