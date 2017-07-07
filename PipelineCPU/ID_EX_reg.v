module ID_EX_reg(clk, reset, MEM_Branch_EN, EX_Branch_EN, EX_ConBA, IF_PC, ID_PC, EX_PC, data_in, ctr_in, data_out, ctr_out, EX_Flush);
    input clk, reset;
    input EX_Branch_EN;
    input MEM_Branch_EN;
    input [31:0] EX_ConBA;
    input [148:0] data_in;
    input [16:0] ctr_in;
    input [31:0] ID_PC;
    input [31:0] IF_PC;
    input EX_Flush;
    output reg [148:0] data_out;
    output reg [15:0] ctr_out;
    output reg [31:0] EX_PC;
    always@(posedge clk or negedge reset) begin
        if (~reset) begin
            data_out <= 149'b0;
            ctr_out <= 16'b0;
            EX_PC <= 32'b0;
        end
        else begin
            data_out <= data_in;
            ctr_out <= ctr_in[16:1];
            EX_PC <= ID_PC;
        end
    end
endmodule
