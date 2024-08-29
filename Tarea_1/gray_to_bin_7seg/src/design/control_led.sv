module control_led (
    input  logic [3 : 0] binary, // Entrada: Código Binario (4 bits)
    output logic [3 : 0] leds  // Salida: LEDs
    
);
    assign leds[3] = ~binary[3];
    assign leds[2] = ~binary[2];
    assign leds[1] = ~binary[1];
    assign leds[0] = ~binary[0];

endmodule