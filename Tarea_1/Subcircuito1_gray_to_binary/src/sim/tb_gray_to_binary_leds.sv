
`timescale 1ns/1ps

module tb_gray_to_binary_leds;

    // Testbench signals
    logic [3:0] gray;    // Test input: Gray code
    logic [3:0] binary;  // Test output: Binary code

    // Instantiate the module under test (MUT)
    gray_to_binary_leds dut (
        .gray(gray),
        .binary(binary)
    );

    // Test stimulus
    initial begin
        // Display header
        $display("Gray Code | Binary Code ");
        $display("----------|-------------");

        // Test each Gray code and display the result
        gray = 4'b0000; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0001; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0011; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0010; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0110; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0111; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0101; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b0100; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1100; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1101; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1111; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1110; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1010; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1011; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1001; #10;
        $display("%b   | %b", gray, binary);
        
        gray = 4'b1000; #10;
        $display("%b   | %b", gray, binary);

        $finish;  // Stop the simulation
    end

    initial begin
        $dumpfile("tb_gray_to_binary_leds.vcd");
        $dumpvars(0,tb_gray_to_binary_leds);
    end


endmodule


