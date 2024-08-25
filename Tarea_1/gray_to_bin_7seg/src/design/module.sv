module gray_to_binary_leds (
    input  logic [3 : 0] gray,  // Entrada: Código Gray (4 bits)
    input  logic btn, // Entrada: Boton
    //entradas para facilitar la escritura de las ecuaciones booleanas
    output wire a,
    output wire b,
    output wire c,
    output wire d,
    output wire e,
    output logic [3 : 0] binary, // Salida: Código Binario (N bits)
    output logic [3 : 0] leds, // Salida: leds
    output logic uni,  // Salida : transistor unidades
    output logic dec, // Salida: transistor decenas
    //Salidas a segmentos del display
    output logic segA,
    output logic segB,
    output logic segC,
    output logic segD,
    output logic segE,
    output logic segF,
    output logic segG
    
);

    // Lógica combinacional para la decodificació
    // gray_code a binary_code usando compuertas lógicas

    assign binary[3] = gray [3];
    assign binary[2] = gray [3] ^ gray [2];
    assign binary[1] = binary [2] ^ gray [1];
    assign binary[0] = binary [1] ^ gray [0];

    //asignacion de leds de acuerdo al bit

    assign leds[3] = ~binary[3];
    assign leds[2] = ~binary[2];
    assign leds[1] = ~binary[1];
    assign leds[0] = ~binary[0];

    //Se les asigna un nuevo valor a las variables para facilitar escritura de ecuaciones booleanas

    assign a = binary[3];
    assign b = binary[2];
    assign c = binary[1];
    assign d = binary[0];
    assign e = btn;

    //Salida para controlar transistores
    assign uni = btn;
    assign dec = ~btn;

    //Ecuaciones booleanas de los 7 segmentos
    assign segA = ~((~b & ~d & ~e) | (~a & c & ~e) | (b & d & ~e) | (a & ~c & ~e)); 
    assign segB = ~((~b & ~e) | (~c & ~d & ~e) | (~a & c & d & ~e) | (a & c & e) | (a & b & ~c) | (a & ~d & ~e));
    assign segC = ~((d & ~e) | (a & c) | (a & b & e) | (~b & ~c & ~e) | (~a & b & ~e));
    assign segD = ~((~b & ~d & ~e) | (~a & ~b & c & ~e) | (b & ~c & d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~e) | (a & b & d & ~e));
    assign segE = ~((~b & ~d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~d & ~e));
    assign segF = ~((~a & b & ~c & ~e) | (a & ~b & ~c & ~e) | (a & b & c & ~e) | (~a & ~c & ~d & ~e) | (~a & b & ~d & ~e) | (a & ~b & ~d & ~e));
    assign segG = ~((~a & c & ~e) | (b & ~e) | (a & ~c & ~e));
    

endmodule