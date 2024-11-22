module module_call (
    input logic clk,
    input logic reset,
    input logic [3:0] row,
    output logic [3:0] colum,

    //Variables para 7 segmentos
    output logic segA,
    output logic segB,
    output logic segC,
    output logic segD,
    output logic segE,
    output logic segF,
    output logic segG,
    output logic dispuni,     
    output logic dispdec,
    output logic dispcen,
    output logic dispmil,    
    output logic neg_sign
);

    //variables internas
    logic stop_flag;
    logic clk_cut;
    logic [1:0] colum_code;
    logic [3:0] sync_row;
    logic [1:0] row_code;
    logic [3:0] ff_out;
    logic mostrar_dato;
    logic [3:0] stored_row;
    logic enable_input;
    logic reset_input_ff;
    logic [15:0] bcd;
    logic [3:0] num_deco_out;
    logic [15:0] bcd_num1;
    logic [15:0] bcd_num2;
    logic [15:0] bin_num1;
    logic [15:0] bin_num2;
    logic neg_flag1;
    logic neg_flag2;
    logic multiplic_flag;
    logic neg_sign_disp;
    logic mult_ready1;
    logic mult_ready2;
    logic mult_result;
    logic [15:0] mult_result_bcd;
    logic result_ok;
    logic [15:0] salida_bcd;
    logic [15:0] z_out;


    seg7_disp s7d (
        .clk(clk),
        .reset(reset),
        .segA(segA),
        .segB(segB),
        .segC(segC),
        .segD(segD),
        .segE(segE),
        .segF(segF),
        .segG(segG),
        .dispuni(dispuni),
        .dispdec(dispdec),
        .dispcen(dispcen),
        .dispmil(dispmil),
        .bcd(bcd)
    );

    BoothMul boothMul_inst (
        .clk(clk),
        .rst(reset),
        .start(mult_ready2),
        .X(bin_num1),
        .Y(bin_num2),
        .z_out(z_out),
        .valid_out(result_ok)
    ); 

    show_num show_num_inst(
        .stored_num_bcd(salida_bcd),
        .mult_result_bcd_SN(mult_result_bcd),
        .result_ok(result_ok),
        .bcd_to_s7d(bcd)
    );

    binario_bcd binario_bcd_resultado (
        .bin_for_bcd(z_out),
        .bcd_out(mult_result_bcd)
    );

    bcd_binario bcd_binario_inst1 ( //hace salida bin correcta
        .entrada_bcd(bcd_num1),
        .multiplic_flag(multiplic_flag),
        .salida_bin(bin_num1),
        .mult_ready(mult_ready1)
    );

    bcd_binario bcd_binario_inst2 ( //hace salida bin correcta
        .entrada_bcd(bcd_num2),
        .multiplic_flag(multiplic_flag),
        .salida_bin(bin_num2),
        .mult_ready(mult_ready2)
    );

    neg_sign_module nsm (
        .neg_flag1(neg_flag1),
        .neg_flag2(neg_flag2),
        .keep_sign_on(multiplic_flag),
        .neg_sign_disp(neg_sign_disp),
        .neg_sign_output(neg_sign)
    );

    bcd_stored_num bcd_stored_num_inst (
        .clk(clk),
        .reset(reset),
        .nuevo_numero(num_deco_out),
        .salida_bcd(salida_bcd),
        .bcd_num1(bcd_num1),
        .bcd_num2(bcd_num2),
        .neg_flag1(neg_flag1),
        .neg_flag2(neg_flag2),
        .neg_sign(neg_sign_disp),
        .multiplic_flag(multiplic_flag)
    );

    row_ff row_ff3 (
        .clk(clk),
        .reset(reset_input_ff),
        .enable(enable_input),
        .d(sync_row[3]),
        .q(stored_row[3])
    );

    row_ff row_ff2 (
        .clk(clk),
        .reset(reset_input_ff),
        .enable(enable_input),
        .d(sync_row[2]),
        .q(stored_row[2])
    );

    row_ff row_ff1 (
        .clk(clk),
        .reset(reset_input_ff),
        .enable(enable_input),
        .d(sync_row[1]),
        .q(stored_row[1])
    );

    row_ff row_ff0 (
        .clk(clk),
        .reset(reset_input_ff),
        .enable(enable_input),
        .d(sync_row[0]),
        .q(stored_row[0])
    );
    
    deco_out deco_out_inst (
        .q_in(ff_out),
        .num_out(num_deco_out)
    );
    
    output_ff out_ff3 (
        .clk(clk),
        .reset(reset),
        .enable(stop_flag),
        .mostrar_dato(mostrar_dato),
        .d(colum_code[1]),
        .q(ff_out[3])
    );

    output_ff out_ff2 (
        .clk(clk),
        .reset(reset),
        .enable(stop_flag),
        .mostrar_dato(mostrar_dato),
        .d(colum_code[0]),
        .q(ff_out[2])
    );

    output_ff out_ff1 (
        .clk(clk),
        .reset(reset),
        .enable(stop_flag),
        .mostrar_dato(mostrar_dato),
        .d(row_code[1]),
        .q(ff_out[1])
    );

    output_ff out_ff0 (
        .clk(clk),
        .reset(reset),
        .enable(stop_flag),
        .mostrar_dato(mostrar_dato),
        .d(row_code[0]),
        .q(ff_out[0])
    );

    input_sync row0_sync (
        .clk(clk),
        .reset(reset),
        .input_pulse(row[0]),
        .sync_input(sync_row[0])
    );

    input_sync row1_sync (
        .clk(clk),
        .reset(reset),
        .input_pulse(row[1]),
        .sync_input(sync_row[1])
    );

    input_sync row2_sync (
        .clk(clk),
        .reset(reset),
        .input_pulse(row[2]),
        .sync_input(sync_row[2])
    );

    input_sync row3_sync (
        .clk(clk),
        .reset(reset),
        .input_pulse(row[3]),
        .sync_input(sync_row[3])
    );

    clk_cut_module ccm (
        .clk(clk),
        .reset(reset),
        .stop_flag(stop_flag),
        .clk_cut(clk_cut),
        .mostrar_dato(mostrar_dato),
        .enable_input(enable_input),
        .reset_input_ff(reset_input_ff)
    );

    colum_on colum_on_inst (
        .clk_cut(clk_cut),
        .reset(reset),
        .colum(colum),
        .colum_code(colum_code)
    );

    row_detect row_detect_ins (
        .row(stored_row),
        .stop_flag(stop_flag),
        .row_code(row_code)
    );

endmodule