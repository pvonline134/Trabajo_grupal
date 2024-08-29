module call (
    input  logic [3 : 0] gray,  // Entrada: Código Gray (4 bits)
    input  logic btn, // Entrada: Botón
    output logic [3 : 0] leds, // Salida: LEDs
    output logic [3 : 0] binary, // Salida: Código Binario (4 bits)
    output logic uni,  // Salida: Transistor unidades
    output logic dec, // Salida: Transistor decenas
    output logic segA,
    output logic segB,
    output logic segC,
    output logic segD,
    output logic segE,
    output logic segF,
    output logic segG
);

    // Instanciación de los módulos
    gray_to_binary g2b (
        .gray(gray),
        .binary(binary)
    );

    control_led cl (
        .binary(binary),
        .leds(leds)
    );

    seg7_disp s7d (
        .binary(binary),
        .btn(btn),
        .uni(uni),
        .dec(dec),
        .segA(segA),
        .segB(segB),
        .segC(segC),
        .segD(segD),
        .segE(segE),
        .segF(segF),
        .segG(segG)
    );

endmodule