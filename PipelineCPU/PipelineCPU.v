module PipelineCPU (reset, sysclk, UART_RX, UART_TX, digi, led, switch);
	input reset, sysclk;
	input UART_RX;
	output UART_TX;
	wire clk;
	assign clk = sysclk;
/*	reg clk;
    integer count=0;
    initial clk=0;
    always @(posedge sysclk) begin
        count=count+1;
        if(count==5) begin
            count=0;
            clk=~clk;
        end
    end*/
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
	
    // wire [31:0] IF_ID_PC;
    // wire [31:0] IF_ID_Instruction;

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
    wire ID_Branch;

    // wire [148:0] ID_EX_data_in;
    // wire [16:0] ID_EX_ctr_in;
    // wire [31:0] ID_EX_PC;
 
    wire EX_Branch;
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
    
    wire [4:0] EX_MEM_Rd;

    wire MEM_Branch_EN;
    wire [4:0] MEM_Rd;
    wire [31:0] MEM_PC_Plus_4;
	wire [31:0] MEM_PC;
	wire [31:0] MEM_Read_data; // @MEM, Memory data
	wire [31:0] MEM_Read_data_1; // @MEM
	wire [31:0] MEM_Read_data_2; // @MEM
    wire [31:0] MEM_ALU_out; // @MEM
    wire [31:0] MEM_DatabusB; // @MEM

    wire [31:0] WB_PC;
    wire [31:0] WB_PC_Plus_4;
    wire [31:0] WB_Read_data;
    wire [31:0] WB_ALU_out;
	wire [31:0] WB_DatabusC; // Register Databus: A, B for read; C for write
	wire [4:0] WB_Rd; // @WB, Register to Write
	
    // peripherals
    output wire [7:0] led; // LED7 ~ LED0, 0x4000000C
    input wire [7:0] switch; // SWITCH7 ~ SWITCH0, 0x40000010
    output wire [11:0] digi; // { AN3 ~ AN0, DP ~ CA}, 0x40000014
    wire irqout; // timer interrupt signal
    wire ID_IRQ;
    wire ID_EXP;
    wire ID_Flush;
    wire EX_Flush;
    wire [4:0] UART_CON;
    reg Loaduse;
    // Forwarding
//    reg [1:0] ForwardA;
//    reg [1:0] ForwardB;

    // parameters
	parameter Xp = 5'h1a; // $26 to save return address when Interr. or Except.
    parameter Ra = 5'h1f; // $31

    IF ifA(.clk(clk), .reset(reset), .EX_ConBA(EX_ConBA), 
        .EX_Branch_EN(EX_Branch_EN), .ID_Jump_I(ID_Jump_I), 
        .ID_Jump_R(ID_Jump_R), .ID_JT(ID_JT),.ID_DatabusA(ID_DatabusA), 
        .ID_IRQ(ID_IRQ), .ID_EXP(ID_EXP), .IF_PC(IF_PC), .IF_Instruction(IF_Instruction), .Loaduse(Loaduse));

    IF_ID_reg ifidregA(.clk(clk), .reset(reset), .IF_PC(IF_PC), .IF_Instruction(IF_Instruction), .ID_PC(ID_PC), .ID_Instruction(ID_Instruction), .ID_Flush(ID_Flush));

    ID idA(.clk(clk), .reset(reset), .PC(ID_PC), .Instruction(ID_Instruction), .IRQ(irqout), .PCSuper(IF_PC[31]),
        .data_out({ID_JT,ID_Shamt,ID_Rs,ID_Rt,ID_Rd,ID_Ext_out,ID_LU_out}), 
        .ctr_out({ID_RegDst, ID_RegWr, ID_ALUSrc1, ID_ALUSrc2, ID_ALUFun, ID_Sign, ID_MemWr, ID_MemRd, ID_MemtoReg, ID_Jump_I, ID_Jump_R, ID_EXP, ID_IRQ, ID_Branch})); 

    RegFile regfileA(.reset(reset), .clk(clk), 
        .addr1(ID_Rs), .data1(ID_DatabusA), 
        .addr2(ID_Rt), .data2(ID_DatabusB), 
        .wr(WB_RegWr), .addr3(WB_Rd), .data3(WB_DatabusC));
    ID_EX_reg idexrefA(.clk(clk), .reset(reset), .EX_Branch_EN(EX_Branch_EN), 
        .MEM_Branch_EN(MEM_Branch_EN), .IF_PC(IF_PC),
        .EX_ConBA(EX_ConBA), .ID_PC(ID_PC), .EX_PC(EX_PC), .EX_Flush(EX_Flush), 
        .data_in({ID_Rs, ID_Rt, ID_Rd, ID_Ext_out, ID_LU_out, ID_Shamt, ID_DatabusA, ID_DatabusB, ID_Branch}), 
        .data_out({EX_Rs, EX_Rt, EX_Rd, EX_Ext_out, EX_LU_out, EX_Shamt, EX_DatabusA, EX_DatabusB, EX_Branch}),
        .ctr_in({ID_RegDst, ID_RegWr, ID_ALUSrc1, ID_ALUSrc2, ID_ALUFun, ID_Sign, ID_MemWr, ID_MemRd, ID_MemtoReg, ID_IRQ}),
        .ctr_out({EX_RegDst, EX_RegWr, EX_ALUSrc1, EX_ALUSrc2, EX_ALUFun, EX_Sign, EX_MemWr, EX_MemRd, EX_MemtoReg}),
        .MEM_PC(MEM_PC), .MEM_Rd(MEM_Rd), .MEM_RegWr(MEM_RegWr), .MEM_ALU_out(MEM_ALU_out), .MEM_MemtoReg(MEM_MemtoReg), .EX_DatabusB(EX_DatabusB), .EX_MEM_Rd(EX_MEM_Rd),
        .MEM_Read_data(MEM_Read_data), .MEM_PC_Plus_4(MEM_PC_Plus_4), .WB_Rd(WB_Rd), .WB_DatabusC(WB_DatabusC), .EX_ALU_out(EX_ALU_out), .WB_RegWr(WB_RegWr));

    EX exA(.Shamt(EX_Shamt), .DatabusA(EX_DatabusA), .DatabusB(EX_DatabusB),
        .Ext_out(EX_Ext_out), .LU_out(EX_LU_out), .ALUSrc1(EX_ALUSrc1), .ALUSrc2(EX_ALUSrc2),
        .ALUFun(EX_ALUFun), .Sign(EX_Sign), .PC(EX_PC),
        .ALU_out(EX_ALU_out), .ConBA(EX_ConBA), .EX_Branch_EN(EX_Branch_EN), .PC_Plus_4(EX_PC_Plus_4),
        .MEM_ALU_out(MEM_ALU_out), .WB_DatabusC(WB_DatabusC), .Branch(EX_Branch));
    
    EX_MEM_reg exmemregA(.clk(clk), .reset(reset), 
        .data_in({EX_PC, EX_PC_Plus_4, EX_ALU_out, EX_DatabusB, EX_MEM_Rd}),
        .data_out({MEM_PC, MEM_PC_Plus_4, MEM_ALU_out, MEM_DatabusB, MEM_Rd}),
        .ctr_in({EX_MemtoReg, EX_MemWr, EX_MemRd, EX_RegWr, EX_Branch_EN}),
        .ctr_out({MEM_MemtoReg, MEM_MemWr, MEM_MemRd, MEM_RegWr, MEM_Branch_EN}),
        .MEM_ALU_out(MEM_ALU_out),
        .WB_DatabusC(WB_DatabusC));

    MEM memA(.Read_data_1(MEM_Read_data_1), .Read_data_2(MEM_Read_data_2), .Read_data(MEM_Read_data), .Data_Read(MEM_ALU_out[30]));

    Peripheral peripheral1(.reset(reset),.sysclk(sysclk),.clk(clk),
        .rd(MEM_MemRd),.wr(MEM_MemWr),.addr(MEM_ALU_out),
        .wdata(MEM_DatabusB),.rdata(MEM_Read_data_2),
        .led(led),.switch(switch),.digi(digi),
        .irqout(irqout),.UART_RX(UART_RX),.UART_TX(UART_TX));

    DataMem datamemA (.reset(reset), .clk(clk), 
        .rd(MEM_MemRd), .wr(MEM_MemWr), .addr(MEM_ALU_out), 
        .wdata(MEM_DatabusB), .rdata(MEM_Read_data_1));

    MEM_WB_reg memwbregA(.clk(clk), .reset(reset), 
        .data_in({MEM_PC, MEM_PC_Plus_4, MEM_ALU_out, MEM_Read_data, MEM_Rd}),
        .data_out({WB_DatabusC, WB_Rd}),
        .ctr_in({MEM_MemtoReg, MEM_RegWr}),
        .ctr_out({WB_MemtoReg, WB_RegWr}));

    always@(*) begin
 //       if (MEM_RegWr && MEM_Rd != 0 && MEM_Rd == EX_Rs) begin
 //           ForwardA = 2'b10;
 //       end
 //       else if (WB_RegWr && WB_Rd != 0 && WB_Rd == EX_Rs) begin
 //           ForwardA = 2'b01;
 //       end
 //       else begin
 //           ForwardA = 2'b00;
 //       end
 //       if (MEM_RegWr && MEM_Rd != 0 && MEM_Rd == EX_Rt) begin
 //           ForwardB = 2'b10;
 //       end
 //       else if (WB_RegWr && WB_Rd != 0 && WB_Rd == EX_Rt) begin
 //           ForwardB = 2'b01;
 //       end
 //       else begin
 //           ForwardB = 2'b00;
 //       end
 //        
        if (ID_MemRd) begin
            if ((IF_Instruction[25:21] == ID_Rt)||(IF_Instruction[20:16] == ID_Rt)) begin
                Loaduse <= 1'b1;
            end
            else begin
                Loaduse <= 1'b0;
            end
        end
        else begin
            Loaduse <= 1'b0;
        end
    end

    assign ID_Flush = (ID_Jump_I || ID_Jump_R || EX_Branch_EN || Loaduse || ID_IRQ);
    assign EX_Flush = (EX_Branch_EN && (~ID_IRQ));
    //assign IF_ID_PC = ID_Flush?32'b0:IF_PC;
    //assign IF_ID_Instruction = ID_Flush?32'b0:IF_Instruction;
    //assign ID_EX_data_in = EX_Flush?149'b0:{ID_Rs, ID_Rt, ID_Rd, ID_Ext_out, ID_LU_out, ID_Shamt, ID_DatabusA, ID_DatabusB, ID_Branch};
    //assign ID_EX_ctr_in = EX_Flush?17'b0: {ID_RegDst, ID_RegWr, ID_ALUSrc1, ID_ALUSrc2, ID_ALUFun, ID_Sign, ID_MemWr, ID_MemRd, ID_MemtoReg, ID_IRQ};
    //assign ID_EX_PC = (MEM_Branch_EN&&ID_IRQ)?IF_PC:
    //    (EX_Branch_EN&&ID_IRQ)?EX_ConBA:ID_PC;
    assign EX_MEM_Rd = (EX_RegDst==2'b00)? EX_Rd:
        (EX_RegDst==2'b01)? EX_Rt:
        (EX_RegDst==2'b10)? Ra: Xp;
endmodule
