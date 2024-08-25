
`timescale 1ns/1ps

module tb_binary_to_7segm;

    // Testbench signals
    logic [3:0] binary;    // Test input: Binary code
    logic [6:0] segments;  // Test output: BCD code

    binary_to_7segm dut (
        .binary(binary),
        .segments(segments)
    );

    //Test
    initial begin

        $display("Binary | BCD");
        
        binary = 4'b0000; #10;
        $display("%b   | %b", binary, segments); //"0"

        binary = 4'b0001; #10;
        $display("%b   | %b", binary, segments); //"1"

        binary = 4'b0010; #10;
        $display("%b   | %b", binary, segments); //"2"

        binary = 4'b0011; #10;
        $display("%b   | %b", binary, segments); //"3"

        binary = 4'b0100; #10;
        $display("%b   | %b", binary, segments); //"4"

        binary = 4'b0101; #10;
        $display("%b   | %b", binary, segments); //"5"

        binary = 4'b0110; #10;
        $display("%b   | %b", binary, segments); //"6"

        binary = 4'b0111; #10;
        $display("%b   | %b", binary, segments); //"7"

        binary = 4'b1000; #10;
        $display("%b   | %b", binary, segments); //"8"

        binary = 4'b1001; #10;
        $display("%b   | %b", binary, segments); //"9"

        $finish; //Stop
    end

initial begin
        $dumpfile("tb_binary_to_7segm.vcd");
        $dumpvars(0,tb_binary_to_7segm);
    end
    
endmodule