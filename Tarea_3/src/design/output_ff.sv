module output_ff (
    input  logic clk,     
    input  logic reset,    
    input  logic enable,    
    input  logic mostrar_dato,   
    input  logic d,     
    output logic q 
);

    logic q_reg; 

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            q_reg <= 1'b0;           
        end else if (enable) begin
            q_reg <= d;          
        end
       
    end

    assign q = mostrar_dato ? q_reg : 1'b0; 

endmodule

