module WB(PC, PC_plus_4, ALU_out, Read_data, MemtoReg, DatabusC);
    input [31:0] PC;
    input [31:0] PC_Plus_4;
    input [31:0] ALU_out;
    input [31:0] Read_data;
    input [1:0] MemtoReg;
    output DatabusC;
	assign DatabusC = (MemtoReg == 2'b00)? ALU_out: 
        (MemtoReg == 2'b01)? Read_data: 
        (MemtoReg == 2'b10)? PC_plus_4:PC;
endmodule
