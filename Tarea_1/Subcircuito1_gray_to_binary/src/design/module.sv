module gray_to_binary_leds (
    input  logic [3 : 0] gray,  // Entrada: Código Gray (4 bits)
    output logic [3 : 0] binary, // Salida: Código Binario (4 bits)
    output logic [3 : 0] leds // salida: leds (se usará en el constr)
);



    // Lógica combinacional para la decodificación
    always_comb begin
        // transformación de gray a binario mediante xor

        binary[3] = gray [3]; //su valor se mantiene por ser el MSB
        binary[2] = gray [3] ^ gray [2]; //Xor de la entrada MSB y la entrada 2
        binary[1] = binary [2] ^ gray [1]; //Xor del resultado anterior con la entrada del bit en la posición 1
        binary[0] = binary [1] ^ gray [0]; //xor del resultado anterior y el bit de la entrada en la posición 0

        //debido a la estructura física de la fpga se deben negar los leds con la salida
        //esto para que cuando el dipswitch este en 0000 los leds estén apagados y no encendidos.
        leds[3] = ~binary[3];
        leds[2] = ~binary[2];
        leds[1] = ~binary[1];
        leds[0] = ~binary[0];
        
    end

endmodule
