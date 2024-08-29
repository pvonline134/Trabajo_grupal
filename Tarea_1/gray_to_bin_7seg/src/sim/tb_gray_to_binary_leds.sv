
`timescale 1ns/1ps

module tb_gray_to_binary_leds;

    // Testbench signals
    logic [3:0] gray;    // Test input: Gray code
    logic [3:0] binary;  // Test output: Binary code
    logic btn;
    logic dec;
    logic uni;
    logic segA;
    logic segB;
    logic segC;
    logic segD;
    logic segE;
    logic segF;
    logic segG;

    // Instantiate the module under test (MUT)
     call mc (
        .gray(gray),
        .binary(binary),
        .btn(btn),
        .dec(dec),
        .uni(uni),
        .segA(segA),
        .segB(segB),
        .segC(segC),
        .segD(segD),
        .segE(segE),
        .segF(segF),
        .segG(segG)
    );

    // Test stimulus
    initial begin
        // Display header

        $display("boton no apretado");

        btn = 1'b0;
        $display (dec);
        btn = 1'b0;
        $display (uni);

        $display("boton apretado");
        btn = 1'b1;
        $display (dec);
        btn = 1'b1;
        $display (uni);

        btn = 1'b0; //modificar valor 0 o 1 para simular tocar el boton
        $display ("btn :" , btn);

        $display("Decodificación y estado de segmento");
        $display("Nota: 0 enciende los segementos"); 
        $display("Gray Code | Binary Code ");
        $display("----------|-------------");

        // Test each Gray code and display the result
        gray = 4'b0000; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0001; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0011; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0010; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);

        gray = 4'b0110; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0111; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0101; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b0100; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1100; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1101; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1111; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1110; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);

        gray = 4'b1010; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1011; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1001; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);
        
        gray = 4'b1000; #10;
        $display("%b   | %b", gray, binary);
        $display ("SegA: ",segA);
        $display ("SegB: ",segB);
        $display ("SegC: ",segC);
        $display ("SegD: ",segD);
        $display ("SegE: ",segE);
        $display ("SegF: ",segF);
        $display ("SegG: ",segG);

        $finish;  // Stop the simulation
    end

    initial begin
        $dumpfile("tb_gray_to_binary_leds.vcd");
        $dumpvars(0,tb_gray_to_binary_leds);
    end


endmodule


