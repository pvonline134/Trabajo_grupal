module seg7_disp (
    input logic clk,
    input logic reset,
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
    input logic [15:0] bcd

);

    logic [1:0] disp;
    logic a, b, c, d, e;
    logic clk_cut1;
    logic [31:0] counter1;

    // Estado inicial
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter1 <= 0;
            clk_cut1 <= 0;
        end else begin
            if (counter1 == (27000-1)) begin
                counter1 <= 0;
                clk_cut1 <= ~clk_cut1;  // Cambia la señal de salida
            end else begin
                counter1 <= counter1 + 1;
            end 
        end
    end

    logic [1:0] cycle_count1;
            // Variable para contar los ciclos
    always_ff @(posedge clk_cut1) begin
        begin
            // Cambiar variables de acuerdo con el ciclo
            case (cycle_count1)
                2'b00: begin
                    dispuni = 0; 
                    dispdec = 1;
                    dispcen = 1;
                    dispmil = 1;
                    disp = 2'b00;
                end
                2'b01: begin
                    dispuni = 1;
                    dispdec = 0; 
                    dispcen = 1;
                    dispmil = 1;
                    disp = 2'b01;
                end
                2'b10: begin
                    dispuni = 1;
                    dispdec = 1;
                    dispcen = 0; 
                    dispmil = 1;
                    disp = 2'b10;
                end
                2'b11: begin
                    dispuni = 1;
                    dispdec = 1;
                    dispcen = 1;
                    dispmil = 0; 
                    disp = 2'b11;
                end
            endcase

            // Incrementar el contador de ciclos (vuelve a 0 después del cuarto ciclo)
            cycle_count1 <= cycle_count1 + 1;
        end
    end
        /*if (reset) begin
            a = 0;
            b = 0;
            c = 0;
            d = 0;
            e = 0;
        end*/

    always_comb begin
        case (disp)
            2'b00: begin
                a = bcd[3];
                b = bcd[2];
                c = bcd[1];
                d = bcd[0];
                e = 0;
            end
            2'b01: begin
                a = bcd[7];
                b = bcd[6];
                c = bcd[5];
                d = bcd[4];
                e = 0;
            end
            2'b10: begin
                a = bcd[11];
                b = bcd[10];
                c = bcd[9];
                d = bcd[8];
                e = 0;
            end
            2'b11: begin
                a = bcd[15];
                b = bcd[14];
                c = bcd[13];
                d = bcd[12];
                e = 0;
            end
        endcase    
    end
    
    assign segA = ~((~b & ~d & ~e) | (~a & c & ~e) | (b & d & ~e) | (a & ~c & ~e)); 
    assign segB = ~((~b & ~e) | (~c & ~d & ~e) | (~a & c & d & ~e) | (a & c & e) | (a & b & ~c) | (a & ~d & ~e));
    assign segC = ~((d & ~e) | (a & c) | (a & b & e) | (~b & ~c & ~e) | (~a & b & ~e));
    assign segD = ~((~b & ~d & ~e) | (~a & ~b & c & ~e) | (b & ~c & d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~e) | (a & b & d & ~e));
    assign segE = ~((~b & ~d & ~e) | (~a & c & ~d & ~e) | (a & ~c & ~d & ~e));
    assign segF = ~((~a & b & ~c & ~e) | (a & ~b & ~c & ~e) | (a & b & c & ~e) | (~a & ~c & ~d & ~e) | (~a & b & ~d & ~e) | (a & ~b & ~d & ~e));
    assign segG = ~((~a & ~b & c & ~e) | (b & ~c & ~e) | (a & ~c & ~e) | (a & b & ~e) | (~a & c & ~d & ~e));

   
endmodule