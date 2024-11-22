module colum_on (
    input logic clk_cut,
    input logic reset,
    output logic [3:0] colum,
    output logic [1:0] colum_code

);

    always_ff @ (posedge clk_cut or posedge reset)
        if (reset) begin
            colum_code <= 2'b00;
        end
        else begin
            colum_code = colum_code + 1;
        end


    always_comb begin //logica combiancional para salidas al teclado
        case (colum_code)
            2'b00: begin
                colum[0] = 1;
                colum[1] = 0;
                colum[2] = 0;
                colum[3] = 0;
            end
            2'b01: begin
                colum[0] = 0;
                colum[1] = 1;
                colum[2] = 0;
                colum[3] = 0;
            end
            2'b10: begin
                colum[0] = 0;
                colum[1] = 0;
                colum[2] = 1;
                colum[3] = 0;
            end
            2'b11: begin
                colum[0] = 0;
                colum[1] = 0;
                colum[2] = 0;
                colum[3] = 1;
            end
        endcase
        
    end


endmodule

