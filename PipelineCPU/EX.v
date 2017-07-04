module EX(
    input [4:0] Shamt,
    input [31:0] DatabusA,
    input [31:0] DatabusB,
    input [31:0] Ext_out,
    input [31:0] LU_out,
    input ALUSrc1,
    input ALUSrc2,
    input [5:0] ALUFun,
    input Sign,
    input [31:0] PC,
    input [1:0] ForwardA,
    input [1:0] ForwardB,
    output [31:0] ALU_out,
    output [31:0] ConBA,
    output EX_Branch_EN,
    output PC_Plus_4),
    wire ALU_in1;
    wire ALU_in2;
    wire Zero;
    wire Overflow;
    wire Negtive;
    assign ALU_in1 = ALUSrc1? {27'b0, Shamt}: 
        (ForwardA==2'b10)? MEM_ALU_out: 
        (ForwardA==2'b01)? WB_Read_data: DatabusA;
    assign ALU_in2 = ALUSrc2? LU_out: 
        (ForwardB==2'b10)? MEM_ALU_out:
        (ForwardB==2'b01)? WB_Read_data: DatabusB;
    assign PC_plus_4 = PC + 32'd4;
    assign ConBA = {EXT_out[29:0], 2'b00} + PC_plus_4; 
    assign Branch = (ALUFun[5:4]==2'b11);
    assign EX_Branch_EN = Branch & ALU_out[0];
     
	ALU alu1(.A(ALU_in1), .B(ALU_in2), .ALUFun(ALUFun), .Sign(Sign), .out(ALU_out), .Zero(Zero), .Overflow(Overflow), .Negative(Negtive));
endmodule
