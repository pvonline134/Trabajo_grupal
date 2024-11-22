module neg_sign_module (
    input logic neg_flag1,
    input logic neg_flag2,
    input logic keep_sign_on,
    input logic neg_sign_disp,
    output logic neg_sign_output

);
    logic inter_neg_flag;

    always_comb begin

        inter_neg_flag = (neg_flag1 ^ neg_flag2);

        if (keep_sign_on)begin
            neg_sign_output = !(inter_neg_flag || neg_sign_disp);
        end
        else begin
            neg_sign_output = !neg_sign_disp;
        end

    end




endmodule