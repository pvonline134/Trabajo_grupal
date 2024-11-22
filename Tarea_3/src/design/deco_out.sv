module deco_out (
    input logic [3:0] q_in,
    output logic [3:0] num_out

);

    always_comb begin

        case(q_in)
            4'b0000: begin
                num_out = 4'b1010; //A 10
            end
            4'b0001: begin
                num_out = 4'b1011; //B 11
            end
            4'b0010: begin
                num_out = 4'b1100; //C 12
            end
            4'b0011: begin
                num_out = 4'b1101; //D 13
            end
            4'b0100: begin
                num_out = 4'b0011; //3
            end
            4'b0101: begin 
                num_out = 4'b0110; //6
            end
            4'b0110: begin
                num_out = 4'b1001; //9
            end
            4'b0111: begin
                num_out = 4'b1110; //#
            end
            4'b1000: begin
                num_out = 4'b0010; //2
            end
            4'b1001: begin
                num_out = 4'b0101; //5
            end
            4'b1010: begin
                num_out = 4'b1000; //8
            end
            4'b1011: begin
                num_out = 4'b0000; //0
            end
            4'b1100: begin
                num_out = 4'b0001; //1
            end
            4'b1101: begin
                num_out = 4'b0100; //4
            end
            4'b1110: begin
                num_out = 4'b0111; //7
            end
            4'b1111: begin
                num_out = 4'b1111; //*
            end
            default: num_out = 4'bz; //alta impedancia
        endcase
    end
    
endmodule