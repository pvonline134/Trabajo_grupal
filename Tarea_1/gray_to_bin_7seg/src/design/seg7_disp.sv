module seg7_disp (
    input  logic [3 : 0] binary, // Entrada: Código Binario (4 bits)
    input  logic btn, // Entrada: Botón
    output logic uni,  // Salida: Transistor unidades
    output logic dec, // Salida: Transistor decenas
    output logic segA,
    output logic segB,
    output logic segC,
    output logic segD,
    output logic segE,
    output logic segF,
    output logic segG,
    output logic a, b, c, d, e
);
    

    // Asignación de variables internas
    assign a = binary[3];
    assign b = binary[2];
    assign c = binary[1];
    assign d = binary[0];
    assign e = btn;

    // Salida para controlar transistores
    assign uni = btn;
    assign dec = ~btn;

    // Ecuaciones booleanas de los 7 segmentos
    assign segA = ~((~b & ~d & ~e) | (~a & c & ~e) | (b & d & ~e) | (a & ~c & ~e)); 
    assign segB = ~((~b & ~e) | (~c & ~d & ~e) | (~a & c & d & ~e) | (a & c & e) | (a & b & ~c) | (a & ~d & ~e));
    assign segC = ~((d & ~e) | (a & c) | (a & b & e) | (~b & ~c & ~e) | (~a & b & ~e));
    assign segD = ~((~b & ~d & ~e) | (~a & ~b & c & ~e) | (b & ~c & d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~e) | (a & b & d & ~e));
    assign segE = ~((~b & ~d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~d & ~e));
    assign segF = ~((~a & b & ~c & ~e) | (a & ~b & ~c & ~e) | (a & b & c & ~e) | (~a & ~c & ~d & ~e) | (~a & b & ~d & ~e) | (a & ~b & ~d & ~e));
    assign segG = ~((~a & ~b & c & ~e) | (b & ~c & ~e) | (a & ~c & ~e) | (a & b & ~e) | (~a & c & ~d & ~e));
    
    
endmodule