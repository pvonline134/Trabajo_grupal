module input_sync (
    input logic clk,        
    input logic reset,      
    input logic input_pulse,     //Señal física (asíncrona)
    output logic sync_input      //Señal sincronizada
);

    // Flip-flops para sincronización
    logic sync_ff1, sync_ff2;

    //Se usa un sincronizador basado en dos flip-flops en cascada
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sync_ff1 <= 1'b0;    
            sync_ff2 <= 1'b0;    
            sync_input <= 1'b0;  
        end else begin
            sync_ff1 <= input_pulse;     
            sync_ff2 <= sync_ff1;   
            sync_input <= sync_ff2; 
        end
    end


endmodule
