module show_num (
    input logic [15:0] stored_num_bcd,
    input logic [15:0] mult_result_bcd_SN,
    input logic result_ok,
    output logic [15:0] bcd_to_s7d

);

    always_comb begin
        if(result_ok)begin
            bcd_to_s7d =  mult_result_bcd_SN;
        end
        else begin
            bcd_to_s7d = stored_num_bcd;
        end
    end




endmodule