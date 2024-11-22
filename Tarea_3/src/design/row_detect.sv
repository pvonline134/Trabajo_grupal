module row_detect (
    input logic [3:0] row,
    output logic stop_flag,
    output logic [1:0] row_code //codificación de la tecla presionada

);

    always_comb begin
        case (row)
            4'b0001: begin
                stop_flag = 1;
                row_code = 2'b00;
            end
            4'b0010: begin
                stop_flag = 1;
                row_code = 2'b01;
            end
            4'b0100: begin
                stop_flag = 1;
                row_code = 2'b10;
            end
            4'b1000: begin
                stop_flag = 1;
                row_code = 2'b11;
            end
            default: begin
                stop_flag = 0;
                row_code = 2'bz;
            end

        endcase
    end
endmodule