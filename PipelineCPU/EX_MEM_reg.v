module EX_MEM_reg (clk, reset, data_in, data_out, ctr_in, ctr_out, MEM_ALU_out,WB_DatabusC);
    input clk, reset;
//    input [1:0] forwardB;
    input [31:0] MEM_ALU_out;
    input [31:0] WB_DatabusC;
    input [132:0] data_in;
    input [5:0] ctr_in;
    output reg [132:0] data_out;
    output reg [5:0] ctr_out;
    always@(posedge clk or negedge reset) begin
        if (~reset) begin
            data_out <= 133'b0;
            ctr_out <= 6'b0;
        end
        else begin
            data_out <= data_in;
            ctr_out <= ctr_in;                
        end
    end
endmodule
    //assign DatabusB_DM = (ForwardB==2'b10)? MEM_ALU_out:
//    (ForwardB==2'b01)? WB_DatabusC: DatabusB;