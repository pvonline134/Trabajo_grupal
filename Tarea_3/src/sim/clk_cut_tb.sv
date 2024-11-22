//`timescale 1ns / 1ps

module tb_clk_cut;

    // Declaración de señales
    logic clk;
    logic reset;
    logic clk_cut;
    logic stop_flag;

    // Instancia del módulo clk_cut
    clk_cut uut (
        .clk(clk),
        .reset(reset),
        .clk_cut(clk_cut),
        .stop_flag(stop_flag)
    );

    // Generador de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Reloj con periodo de 10 ns
    end

    // Procedimiento de prueba
    initial begin
        // Inicio de la simulación
        $display("Iniciando testbench para clk_cut");

        // Condiciones iniciales
        reset = 1;        // Activamos el reset al inicio
        stop_flag = 0;
        #20 
        reset = 0;    // Desactivamos el reset después de 20 ns

        #250
        stop_flag = 1;
        #10
        stop_flag = 0;


        // Esperar un número de ciclos suficiente para observar cambios en clk_cut
        #250;

        // Fin de la simulación
        $display("Testbench finalizado");
        $finish;
    end

    // Monitoreo para observar la salida
    initial begin
        $monitor("Time=%0t | clk=%b | reset=%b | clk_cut=%b | stop_flag=%b", $time, clk, reset, clk_cut, stop_flag);
    end

    initial begin
        $dumpfile("clk_cut_tb.vcd");
        $dumpvars(0,tb_clk_cut);
    end


endmodule
