module gray_to_binary_leds (
    input logic [3:0] gray,   // Entrada en código Gray de 4 bits
    output logic [3:0] binary // Salida en binario de 4 bits
   
);

    // Convertir Gray a binario
    assign binary[3] = gray[3];
    assign binary[2] = gray[3] ^ gray[2];
    assign binary[1] = binary[2] ^ gray[1];
    assign binary[0] = binary[1] ^ gray[0];

    // Controlar los LEDs en función del resultado binario
    

endmodule
