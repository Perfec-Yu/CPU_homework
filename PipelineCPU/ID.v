module ID(clk, reset, PC, Instruction, IRQ, data_out, ctr_out);
    input clk, reset;
    input [31:0] PC;
    input [31:0] Instruction;
    input IRQ;
    reg [31:0] JT;
    reg [15:0] Imm16;
    reg [4:0] Shamt;
    reg [31:0] Ext_out;
    reg [31:0] LU_out;
    reg [4:0] Rs;
    reg [4:0] Rt;
    reg [4:0] Rd;
    output reg [100:0] data_out;
    assign data_out = {JT, Shamt, Rs, Rt, Rd, Ext_out, LU_out};
    
    // Control Signals
	wire [2:0] PCSrc; // select Source of PC
	wire [1:0] RegDst; // select Register to Write
    wire RegWr; // Register write enable
	wire ALUSrc1; // select Source for ALU 
	wire ALUSrc2; // selct Source for ALU
	wire [5:0] ALUFun; // ALU Function
	wire Sign; // ALU works with signed or unsigned numbers
	wire MemWr; // Memory write enable
	wire MemRd; // Memory read enable
	wire [1:0] MemtoReg; // select Datapath from Memory to Regfile
	wire ExtOp; // Immediate Number Extending policy: 1 sign extending, 0 zero extending
	wire LuOp; // deal with 'Lui' inst.
    wire Jump_I;
    wire Jump_R;
    wire ID_IRQ;
    wire ID_EXP;
    output reg [17:0] ctr_out;
    assign ctr_out = {RegDst, RegWr, ALUSrc1, ALUSrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, Jump_I, Jump_R, ID_EXP, ID_IRQ}; 

    assign JT <= {PC[31:28], Instruction[25:0], 2'b00};
    assign Imm16 <= Instruction[15:0];
    assign Shamt <= Instruction[10:6];
    assign Rd <= Instruction[15:11];
    assign Rt <= Instruction[20:16];
    assign Rs <= Instruction[25:21];
    assign Ext_out <= ExtOp? {16{Imm16[15]}, Imm16[15:0]}: {16'b0, Imm16[15:0]}; 
    assign LU_out <= LuOp? {Imm16[15:0], 16'b0}: Ext_out;
    assign JumpI <= (PC_Src==3'b010);
    assign JumpR <= (PC_Src==3'b011);
    assign ID_IRQ <= (PC_Src==3'b100);
    assign ID_EXP <= (PC_Src==3'b101);

    Controller controllerA (
        .Opcode(Instruction[31:26]), .Funct(Instruction[5:0]), .IRQ(IF_IRQ),
		.PCSuper(PC[31]), .PCSrc(PCSrc), .RegWr(RegWr), .RegDst(RegDst), 
		.MemRd(MemRd),	.MemWr(MemWr), .MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp),
        .LuOp(LuOp), .ALUFun(ALUFun) ,.Sign(Sign));
endmodule
