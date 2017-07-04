module IF(clk, reset, EX_ConBA, EX_Branch_EN, ID_Jump_I, ID_Jump_R, ID_JT, ID_DatabusA, ID_EXP, ID_IRQ, IF_PC, IF_Instruction);
    input clk, reset;
    input EX_Branch_EN;
    input [31:0] EX_ConBA;
    input ID_Jump_R;
    input ID_Jump_I;
    input [31:0] ID_DatabusA;
    input [31:0] ID_JT;
    input ID_IRQ;
    input ID_EXP;
    output [31:0] IF_Instruction;
    output reg [31:0] IF_PC;

    wire [31:0] PC_out;
    wire [2:0] PCSrc;
    wire [31:0] IF_PC_Plus_4;
    assign PCSrc = ID_IRQ? 3'b100:
        ID_EXP? 3'b101:
        EX_Branch_EN? 3'b001:
        ID_Jump_I? 3'b010:
        ID_Jump_R? 3'b011:3'b000;
    assign IF_PC_Plus_4 = IF_PC + 32'd4;
    assign PC_out = (PCSrc==3'd0)? IF_PC_Plus_4:
        (PCSrc==3'd1)? EXConBA:
        (PCSrc==3'd2)? ID_JT:
        (PCSrc==3'd3)? ID_DatabusA:
        (PCSrc==3'd4)? ILLOP:XADR;
    /*always@(*) begin
        if (ID_IRQ) begin
            PC_out <= ILLOP;
        end
        else if(ID_EXP) begin
            PC_out <= XADR;
        end
        else if (EX_Branch_EN) begin
            PC_out <= {IF_PC[31], EX_ConBA[30:0]};
        end
        else if (ID_Jump_R) begin
            PC_out <= ID_DatabusA;
        end
        else if (ID_Jump_I) begin
            PC_out <= {IF_PC[31], ID_JT[30:0]};
        end
        else begin
            PC_out <= IF_PC + 4;
        end
    end*/
    always(@posedge clk or negedge reset) begin
        if (~reset) begin
           IF_PC <= 32'b0;
           IF_Instruction <= 32'b0;
        end
        else begin
            IF_PC <= PC_out;
        end
    end
    ROM romA (.addr(IF_PC), .data(IF_Instruction)); 
endmodule
