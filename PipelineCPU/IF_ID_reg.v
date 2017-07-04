module IF_ID_reg (clk, reset, IF_PC, IF_Instruction, ID_PC, ID_Instruction, ID_Flush);
    input clk, reset, ID_Flush;
    input [31:0] IF_PC;
    input [31:0] IF_Instruction;
    output reg [31:0] ID_PC;
    output reg [31:0] ID_Instruction;
    always@(posedge clk or negedge reset) begin
        if (~reset) begin
            ID_PC <= 32'b0;
            ID_Instruction <= 32'b0;
        end
        else begin
            if (ID_Flush) begin
                ID_PC <= 32'b0;
                ID_Instruction <= 32'b0;
            end
            else begin
                ID_PC <= IF_PC;
                ID_Instruction <= IF_Instruction;
            end
        end
    end
endmodule