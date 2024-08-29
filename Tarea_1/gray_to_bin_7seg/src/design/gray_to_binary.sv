module gray_to_binary (
    
    input  logic [3 : 0] gray, // Entrada: Código Gray (4 bits)
    output logic [3 : 0] binary // Salida: Código Binario (4 bits)
);

    assign binary[3] = gray[3];
    assign binary[2] = gray[3] ^ gray[2];
    assign binary[1] = binary[2] ^ gray[1];
    assign binary[0] = binary[1] ^ gray[0];

endmodule