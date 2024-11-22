module clk_cut_module (
    input logic clk,
    input logic reset,
    input logic stop_flag,
    output logic clk_cut,
    output logic mostrar_dato,
    output logic enable_input,
    output logic reset_input_ff
    
);

logic [31:0] counter;
logic [31:0] stop_count;

always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_cut <= 0;
            stop_count <= 0;
            mostrar_dato <= 0;
            enable_input <= 1;
            reset_input_ff <= 0;
        end 
        else if (stop_flag || stop_count != 0) begin
            stop_count <= stop_count + 1;
            enable_input <= 0;
            if (stop_count == 15000) begin //15000
                mostrar_dato <= 1;
                reset_input_ff <= 1;
            end
            if (stop_count == 15001) begin //15001
                mostrar_dato <= 0;  //Para pruebas de fpga en leds: mostrar_dato <= 1 
                reset_input_ff <= 0;
            end
            if (stop_count == 9900000 ) begin //Se debe modificar de acuerdo al tiempo de rebote de las teclas   //9900000
            //indica el número de ciclos clk //En la vida real debe ser un valor alto acorde a 27 000 del contador
                stop_count <= 0;
                enable_input <= 1;
            end
        end
        else begin
            if (counter == (27000-1)) begin  //Para funcionamiento 27 000-1, para simular 2-1
                counter <= 0;
                clk_cut <= ~clk_cut;  // Cambia la señal de salida
            end else begin
                counter <= counter + 1;
            end 
        end
    end

endmodule