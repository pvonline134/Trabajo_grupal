module module_call_tb;

    //Declaración de variables
    logic clk;
    logic reset;
    logic [3:0] colum;
    logic [3:0] row;

    //instancia 
    module_call uut(
        .clk(clk),
        .reset(reset),
        .colum(colum),
        .row(row)

    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;  // Reloj con periodo de 10 ns
    end

     initial begin
        // Inicio de la simulación
        $display("TB para module_call");

        // Condiciones iniciales
        reset = 1;        // Activamos el reset al inicio
        row = 0;
        #20 
        reset = 0;    // Desactivamos el reset después de 20 ns
        #40
        row[0] = 1;
        #5
        row[0] = 0;
        #2000
        row[2] = 1;
        #5
        row[2] = 0;
        #2000
        row[3] = 1;
        #5
        row[3] = 0;

        


        // Esperar un número de ciclos suficiente para observar cambios en clk_cut
        #20000;

        // Fin de la simulación
        $display("Testbench finalizado");
        $finish;
    end

    // Monitoreo para observar la salida
    initial begin
        $monitor("Time=%0t | clk=%b | reset=%b | colum=%b | row= %b", $time, clk, reset, colum, row);
    end






    initial begin
        $dumpfile("module_call_tb.vcd");
        $dumpvars(0,module_call_tb);
    end


endmodule