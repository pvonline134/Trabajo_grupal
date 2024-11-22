module row_ff (
    input  logic clk,     
    input  logic reset,    
    input  logic enable,    
    //input  logic show_row,   
    input  logic d,     
    output logic q 
);

    logic q_reg; 

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 1'b0;           
        end else if (enable) begin
            q <= d;          
        end
       
    end

    //assign q = show_row ? q_reg : 1'bz; 

endmodule

