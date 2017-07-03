module SingleCPU (reset, sysclk, UART_RX, UART_TX, digi, led, switch);
	input reset, sysclk;
	input UART_RX;
	output UART_TX;
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

    // Memory
	wire [31:0] Instruction; // Inst.
	wire [31:0] Read_data; // Memory data
	wire [31:0] Read_data_1;
	
    // Register
	wire [31:0] DatabusA, DatabusB, DatabusC; // Register Databus: A, B for read; C for write

    // Selections
	reg [31:0] PC;
	wire [31:0] PC_plus_4; // PC + 4
	wire [31:0] PC_next;
	wire [4:0] Write_Reg; // Register to Write
	wire [31:0] Ext_out; // Extended Immediate Number
	wire [31:0] LU_out; // If it is 'Lui' inst., shift immediate number 16bits left; Ext_out otherwise
	wire [31:0] ALU_in1; // ALU operand
	wire [31:0] ALU_in2; // ALU operand
	wire [31:0] ALU_out; // ALU output
	wire Zero; // ALU output, Branch equal
    wire Overflow; // ALU output, result overflow
    wire Negative; // ALU output, result negative
	wire [31:0] JT; // target address for J inst.
	wire [31:0] ConBA; // target address for Branch inst.
	
    // peripherals
    input wire [7:0] led; // LED7 ~ LED0, 0x4000000C
    input wire [7:0] switch; // SWITCH7 ~ SWITCH0, 0x40000010
    input wire [11:0] digi; // { AN3 ~ AN0, DP ~ CA}, 0x40000014
    wire irqout; // timer interrupt signal
	reg clk;
	wire [31:0] Read_data_2;
	
	integer count=0;
	initial clk=0;
	always @(sysclk) begin
		count=count+1;
		if(count==5) begin
			count=0;
			clk=~clk;
		end
	end
	
    // parameters
    parameter ILLOP = 32'h8000_0004; // Interrupt PC Address
    parameter XADR = 32'h8000_0008; // Exception PC Address
	parameter Xp = 5'h1a; // $26 to save return address when Interr. or Except.
    parameter Ra = 5'h1f; // $31

    Peripheral peripheral1(.reset(reset),.clk(clk),.rd(MemRd),.wr(MemWr),.addr(ALU_out),.wdata(DatabusB),
						.rdata(Read_data_2),.led(led),.switch(switch),.digi(digi),.irqout(irqout),.UART_RX(UART_RX),.UART_TX(UART_TX));

    ROM romA (.addr(PC[30:0]), .data(Instruction));
    DataMem datamemA (.reset(reset), .clk(clk), .rd(MemRd), .wr(MemWr), .addr(ALU_out), .wdata(DatabusB), .rdata(Read_data_1));
    RegFile regfileA(.reset(reset), .clk(clk), .addr1(Instruction[25:21]), .data1(DatabusA), .addr2(Instruction[20:16]), 
						.data2(DatabusB), .wr(RegWr), .addr3(Write_Reg), .data3(DatabusC));

	assign PC_plus_4 = PC + 32'h4;
	assign PC_next = (PCSrc == 3'b000)? PC_plus_4:
        (PCSrc == 3'b001)? ConBA:
        (PCSrc == 3'b010)? JT:
        (PCSrc == 3'b011)? DatabusA:
        (PCSrc == 3'b100)? ILLOP: XADR;
	assign Write_Reg = (RegDst == 2'b00)? Instruction[15:11]: 
        (RegDst == 2'b01)? Instruction[20:16]:
        (RegDst == 2'b10)? Ra: Xp;
	assign Ext_out = {ExtOp? {16{Instruction[15]}}: 16'h0000, Instruction[15:0]};
	assign LU_out = LuOp? {Instruction[15:0], 16'h0000}: Ext_out;
	assign ALU_in1 = ALUSrc1? {27'h00000, Instruction[10:6]}: DatabusA;
	assign ALU_in2 = ALUSrc2? LU_out: DatabusB;
	assign JT = {PC_plus_4[31:28], Instruction[25:0], 2'b00};
	assign ConBA = (ALU_out[0])? PC_plus_4 + {LU_out[29:0], 2'b00}: PC_plus_4;
	assign DatabusC = (MemtoReg == 2'b00)? ALU_out: 
        (MemtoReg == 2'b01)? Read_data: 
        (MemtoReg == 2'b10)? PC_plus_4:PC;
	assign Read_data = ALU_out[30]? Read_data_2:Read_data_1;
	
	Controller control1(
		.OpCode(Instruction[31:26]), .Funct(Instruction[5:0]), .IRQ(irqout),
		.PCSrc(PCSrc), .RegWr(RegWr), .RegDst(RegDst), 
		.MemRd(MemRd),	.MemWr(MemWr), .MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp), .ALUFun(ALUFun) ,.Sign(Sign) ,.PCSuper(PC[31]));
	
	ALU alu1(.A(ALU_in1), .B(ALU_in2), .ALUFun(ALUFun), .Sign(Sign), .out(ALU_out), .Zero(Zero), .Overflow(Overflow), .Negative(Negtive));

    // CPU fetch inst.
	always @(negedge reset or posedge clk)
		if (~reset)
			PC <= 32'h00000000;
		else
			PC <= PC_next;
endmodule
	
