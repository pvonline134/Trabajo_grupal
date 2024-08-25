module binary_to_7segm (

    input logic [3:0] binary, //Entrada binaria
    output logic [6:0] segments // Salida BCD

);

always @(*) 
begin
        case(binary)
            4'b0000: segments = 7'b1111110; // "0"  
            4'b0001: segments = 7'b0110000; // "1" 
            4'b0010: segments = 7'b1101101; // "2" 
            4'b0011: segments = 7'b1111001; // "3" 
            4'b0100: segments = 7'b0110011; // "4" 
            4'b0101: segments = 7'b1011011; // "5" 
            4'b0110: segments = 7'b1011111; // "6" 
            4'b0111: segments = 7'b1110000; // "7" 
            4'b1000: segments = 7'b1111111; // "8"  
            4'b1001: segments = 7'b1110011; // "9"
            default: segments = 7'b1111110; // "0" 
        endcase
end
endmodule
    


