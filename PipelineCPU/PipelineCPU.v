module PipelineCPU (reset, sysclk, UART_RX, UART_TX, digi, led, switch);
	input reset, sysclk;
	input UART_RX;
	output UART_TX;

    // cpu_clk
	reg clk;
	integer count=0;
	initial clk=0;
	always @(sysclk) begin
		count=count+1;
		if(count==5) begin
			count=0;
			clk=~clk;
		end
	end

    // Control Signals

	wire [1:0] ID_RegDst; // select Register to Write
    wire ID_RegWr; // Register write enable
	wire ID_ALUSrc1; // select Source for ALU 
	wire ID_ALUSrc2; 
	wire [5:0] ID_ALUFun; // ALU Function
	wire ID_Sign; // ALU works with signed or unsigned numbers
	wire ID_MemWr; // Memory write enable
	wire ID_MemRd; // Memory read enable
	wire [1:0] ID_MemtoReg; // select Datapath from Memory to Regfile
	wire ID_ExtOp; // Immediate Number Extending policy: 1 sign extending, 0 zero extending
	wire ID_LuOp; // deal with 'Lui' inst.

    wire [1:0] EX_RegDst;
    wire EX_RegWr; 
	wire EX_ALUSrc1; 
	wire EX_ALUSrc2; 
	wire [5:0] EX_ALUFun; 
	wire EX_Sign; 
	wire EX_MemWr; 
    wire EX_MemRd;
	wire [1:0] EX_MemtoReg; 

    wire MEM_RegWr; 
	wire MEM_MemWr; 
    wire MEM_MemRd;
    wire [1:0] MEM_MemtoReg;

    wire WB_RegWr; 
	wire [1:0] WB_MemtoReg; 
    
    // data
    wire [31:0] IF_PC;
    wire [31:0] IF_Instruction;
	
    wire [31:0] ID_PC;
	wire [31:0] ID_Instruction; // Inst.
    wire [31:0] ID_DatabusA;
    wire [31:0] ID_DatabusB;
	wire [31:0] ID_JT; // @ID, target address for J inst.
    wire [4:0] ID_Rs;
    wire [4:0] ID_Rt;
    wire [4:0] ID_Rd;
	wire [31:0] ID_Ext_out; // @ID, Extended Immediate Number
	wire [31:0] ID_LU_out; // @ID, If it is 'Lui' inst., shift immediate number 16bits left; Ext_out otherwise
    wire ID_Jump_I; // @ID
    wire ID_Jump_R; // @ID
    wire [4:0] ID_Shamt;

    wire [31:0] EX_PC;
    wire [31:0] EX_PC_Plus_4;
    wire [4:0] EX_Rs;
    wire [4:0] EX_Rt;
    wire [4:0] EX_Rd;
    wire [31:0] EX_Ext_out;
    wire [31:0] EX_LU_out;
    wire [4:0] EX_Shamt;
    wire [31:0] EX_DatabusA;
    wire [31:0] EX_DatabusB;
	wire [31:0] EX_ALU_in1; // decided @EX stage, ALU operand
	wire [31:0] EX_ALU_in2; // decided @EX stage, ALU operand
	wire [31:0] EX_ALU_out; // @EX, ALU output
	wire [31:0] EX_ConBA; // @EX, target address for Branch inst.
    wire EX_Branch_EN; // @EX, whether branch inst. @EX stage occurs
    
    reg [4:0] EX_MEM_Rd;

    wire [4:0] MEM_Rd;
    wire [31:0] MEM_PC_Plus_4;
	wire [31:0] MEM_PC;
	wire [31:0] MEM_Read_data; // @MEM, Memory data
	wire [31:0] MEM_Read_data_1; // @MEM
	wire [31:0] MEM_Read_data_2; // @MEM
    wire [31:0] MEM_ALU_out; // @MEM
    wire [31:0] MEM_DatabusB; // @MEM

    wire [31:0] WB_PC;
    wire [31:0] WB_Read_data;
	wire [31:0] WB_DatabusC; // Register Databus: A, B for read; C for write
	wire [4:0] WB_Write_Reg; // @WB, Register to Write
	
    // peripherals
    input wire [7:0] led; // LED7 ~ LED0, 0x4000000C
    input wire [7:0] switch; // SWITCH7 ~ SWITCH0, 0x40000010
    input wire [11:0] digi; // { AN3 ~ AN0, DP ~ CA}, 0x40000014
    wire irqout; // timer interrupt signal

    wire ID_IRQ;
    wire ID_EXP;
    reg ID_Flush;
    reg EX_Flush;
    reg Loaduse;
	
    // Forwarding
    reg [1:0] ForwardA;
    reg [1:0] ForwardB;

    // parameters
    parameter ILLOP = 32'h8000_0004; // Interrupt PC Address
    parameter XADR = 32'h8000_0008; // Exception PC Address
	parameter Xp = 5'h1a; // $26 to save return address when Interr. or Except.
    parameter Ra = 5'h1f; // $31

    IF ifA(.clk(clk), .reset(reset), .EX_ConBA(EX_ConBA), 
        .EX_Branch_EN(EX_Branch_EN), .ID_Jump_I(ID_Jump_I), 
        .ID_Jump_R(ID_Jump_R), .ID_JT(ID_JT),.ID_DatabusA(ID_DatabusA), 
        .ID_IRQ(ID_IRQ), .ID_EXP(ID_EXP), .IF_PC(IF_PC), .IF_Instruction(IF_Instruction));

    IF_ID_reg ifidregA(.clk(clk), .reset(reset), .IF_PC(IF_PC), .IF_Instruction(IF_Instruction), .ID_PC(ID_PC), .ID_Instruction(ID_Instruction), .ID_Flush(ID_Flush));

    ID idA(.clk(clk), .reset(reset), .PC(ID_PC), .Instruction(ID_Instruction), .IRQ(irqout) 
        .data_out({ID_JT,ID_Shamt,ID_Rs,ID_Rt,ID_Rd,ID_Ext_out,ID_LU_out}), 
        .ctr_out({ID_RegDst, ID_RegWr, ID_ALUSrc1, ID_ALUSrc2, ID_ALUFun, ID_Sign, ID_MemWr, ID_MemRd, ID_MemtoReg, ID_Jump_I, ID_Jump_R, ID_EXP, ID_IRQ}); 
    
    RegFile regfileA(.reset(reset), .clk(clk), 
        .addr1(ID_Rs), .data1(ID_DatabusA), 
        .addr2(ID_Rt), .data2(ID_DatabusB), 
        .wr(WB_RegWr), .addr3(WB_Rd), .data3(WB_DatabusC));
    
    ID_EX_reg idexrefA(.clk(clk), .reset(reset), .EX_Branch_EN(EX_Branch_EN), 
        .EX_ConBA(EX_ConBA), .ID_PC(ID_PC), .EX_PC(EX_PC), .EX_Flush(EX_Flush), 
        .data_in({ID_Rs, ID_Rt, ID_Rd, ID_Ext_out, ID_LU_out, ID_Shamt, ID_DatabusA, ID_DatabusB}), 
        .data_out({EX_Rs, EX_Rt, EX_Rd, EX_Ext_out, EX_LU_out, EX_Shamt, EX_DatabusA, EX_DatabusB}),
        .ctr_in({ID_RegWr, ID_RegWr, ID_ALUSrc1, ID_ALUSrc2, ID_ALUFun, ID_Sign, ID_MemWr, ID_MemRd, ID_MemtoReg}),
        .ctr_out({EX_RegWr, EX_RegWr, EX_ALUSrc1, EX_ALUSrc2, EX_ALUFun, EX_Sign, EX_MemWr, EX_MemRd, EX_MemtoReg});

    EX exA(.Shamt(EX_Shamt), .DatabusA(EX_DatabusA), .DatabusB(EX_DatabusB),
        .Ext_out(Ext_out), .LU_out(LU_out), .ALUSrc1(EX_ALUSrc1), .ALUSrc2(EX_ALUSrc2),
        .ALUFun(EX_ALUFun), .Sign(EX_Sign), PC(EX_PC), .ForwardA(ForwardA), .ForwardB(ForwardB),
        .ALU_out(EX_ALU_out), .ConBA(EX_ConBA), .EX_Branch_EN(EX_Branch_EN), .PC_Plus_4(EX_PC_Plus_4));
    
    EX_MEM_reg exmemregA(.clk(clk), .reset(reset), 
        .data_in({EX_PC, EX_PC_Plus_4, EX_ALU_out, EX_DatabusB, EX_MEM_Rd}),
        .data_out({MEM_PC, MEM_PC_Plus_4, MEM_ALU_out, MEM_DatabusB, MEM_Rd}),
        .ctr_in({EX_MemtoReg, EX_MemRd, EX_MemRd, EX_RegWr}),
        .ctr_out({MEM_MemtoReg, MEM_MemRd, MEM_MemRd, MEM_RegWr}));

    MEM memA(Read_data_1(MEM_Read_data_1), .Read_data_2(MEM_Read_data_2), .Read_data(MEM_Read_data));

    Peripheral peripheral1(.reset(reset),.clk(clk),
        .rd(MEM_MemRd),.wr(MEM_MemWr),.addr(MEM_ALU_out),
        .wdata(MEM_DatabusB),.rdata(MEM_Read_data_2),
        .led(led),.switch(switch),.digi(digi),
        .irqout(irqout),.UART_RX(UART_RX),.UART_TX(UART_TX));

    DataMem datamemA (.reset(reset), .clk(clk), 
        .rd(MEM_MemRd), .wr(MEM_MemWr), .addr(MEM_ALU_out), 
        .wdata(MEM_DatabusB), .rdata(MEM_Read_data_1));

    MEM_WB_reg memwbregA(.clk(clk), .reset(reset), 
        .data_in({MEM_PC, MEM_PC_Plus_4, MEM_ALU_out, MEM_Read_data, MEM_Rd}),
        .data_out({WB_PC, WB_PC_Plus_4, WB_ALU_out, WB_Read_datad, WB_Rd}),
        .ctr_in({MEM_MemtoReg, MEM_RegWr}),
        .ctr_out({WB_MemtoReg, WB_RegWr}));

    WB wbA(.PC(WB_PC), .PC_plus_4(WB_PC_Plus_4), .ALU_out(WB_ALU_out), 
        .Read_data(WB_Read_data), .MemtoReg(WB_MemtoReg), .DatabusC(WB_DatabusC));

    always@(*) begin
        if (MEM_RegWr && MEM_Rd != 0 && MEM_Rd == EX_Rs) begin
            ForwardA = 2'b10;
        end
        else if (WB_RegWr && WB_Rd != 0 && WB_Rd == EX_Rs) begin
            ForwardA = 2'b01;
        end
        else begin
            ForwardA = 2'b00;
        end
        if (MEM_RegWr && MEM_Rd != 0 && MEM_Rd == EX_Rt) begin
            ForwardB = 2'b10;
        end
        else if (WB_RegWr && WB_Rd != 0 && WB_Rd == EX_Rt) begin
            ForwardB = 2'b01;
        end
        else begin
            ForwardB = 2'b00;
        end
        
        if (ID_MemRd) begin
            if ((IF_Instruction[25:21] == ID_Rt)||(IF_Instruction[20:16] == ID_Rt)) begin
                Loaduse <= 1'b1;
            end
            else begin
                Loaduse <= 1'b0;
            end
        end
    end

    assign ID_Flush = ID_Jump_I | ID_Jump_R | EX_Branch_EN | Loaduse;
    assign EX_Flush = EX_Branch_EN & (~ID_IRQ);
    assign EX_MEM_Rd = (EX_RegDst==2'b00)? EX_Rd:
        (EX_RegDst==2'b01)? EX_Rt:
        (EX_RegDst==2'b10)? Ra: Xp;
    always@(posedge clk or negedge reset) begin
        if (~reset) begin
            EX_MEM_Rd <= 5'b0;
            ID_Flush <= 1'b0;
            EX_Flush <= 1'b0;
            Loaduse <= 1'b0;
            ForwardA <= 2'b0;
            ForwardB <= 2'b0;
        end
    end
	/*
	assign Write_Reg = (RegDst == 2'b00)? Instruction[15:11]: 
        (RegDst == 2'b01)? Instruction[20:16]:
        (RegDst == 2'b10)? Ra: Xp;
	wire [2:0] PCSrc; // select Source of PC
	wire EX_Zero; // @EX, ALU output, Branch equal
    wire EX_Overflow; // @EX, ALU output, result overflow
    wire EX_Negative; // @EX, ALU output, result negative
	assign PC_plus_4 = PC + 32'h4;
	assign PC_next = (PCSrc == 3'b000)? PC_plus_4:
        (PCSrc == 3'b001)? ConBA:
        (PCSrc == 3'b010)? JT:
        (PCSrc == 3'b011)? DatabusA:
        (PCSrc == 3'b100)? ILLOP: XADR;
	assign Ext_out = {ExtOp? {16{Instruction[15]}}: 16'h0000, Instruction[15:0]};
	assign LU_out = LuOp? {Instruction[15:0], 16'h0000}: Ext_out;
	assign ALU_in1 = ALUSrc1? {27'h00000, Instruction[10:6]}: DatabusA;
	assign ALU_in2 = ALUSrc2? LU_out: DatabusB;
	assign JT = {PC_plus_4[31:28], Instruction[25:0], 2'b00};
	assign ConBA = (ALU_out[0])? PC_plus_4 + {LU_out[29:0], 2'b00}: PC_plus_4;
    ROM romA (.addr(PC[30:0]), .data(Instruction));
	Controller control1(
		.OpCode(Instruction[31:26]), .Funct(Instruction[5:0]), .IRQ(irqout),
		.PCSrc(PCSrc), .RegWr(RegWr), .RegDst(RegDst), 
		.MemRd(MemRd),	.MemWr(MemWr), .MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp), .ALUFun(ALUFun) ,.Sign(Sign) ,.PCSuper(PC[31]));
    // CPU fetch inst.
	always @(negedge reset or posedge clk)
		if (~reset)
			PC <= 32'h00000000;
		else
			PC <= PC_next;
    */
endmodule
