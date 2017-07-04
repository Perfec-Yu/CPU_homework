module Controller(
	input [5:0] OpCode,
    input [5:0] Funct,
	input IRQ,
    input PCSuper,
	output [2:0] PCSrc,
    output RegWr,
	output [1:0] RegDst,
	output MemRd,
	output MemWr,
	output [1:0] MemtoReg,
	output ALUSrc1,
	output ALUSrc2,
	output ExtOp,
	output LuOp,
	output [5:0] ALUFun,
	output Sign);
	
    reg [21:0] allsign;

	assign {PCSrc, RegDst, RegWr, ALUSrc1, ALUSrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, ExtOp, LuOp} = allsign;

	always @(*) begin
		if ((~PCSuper) & IRQ) begin
			allsign <= 21'b100_11_1_X_X_XXXXXX_X_0_0_11_X_X; //IRQ
			end
		else begin
			case (OpCode)
				6'b000000:
				begin
					case (Funct)
						6'b100000: allsign <= 21'b000_00_1_0_0_000000_1_0_0_00_X_X; //add
						6'b100001: allsign <= 21'b000_00_1_0_0_000000_0_0_0_00_X_X; //addu
						6'b100010: allsign <= 21'b000_00_1_0_0_000001_1_0_0_00_X_X; //sub
						6'b100011: allsign <= 21'b000_00_1_0_0_000001_0_0_0_00_X_X; //subu
						6'b100100: allsign <= 21'b000_00_1_0_0_011000_X_0_0_00_X_X; //and
						6'b100101: allsign <= 21'b000_00_1_0_0_011110_X_0_0_00_X_X; //or
						6'b100110: allsign <= 21'b000_00_1_0_0_010110_X_0_0_00_X_X; //xor
						6'b100111: allsign <= 21'b000_00_1_0_0_010001_X_0_0_00_X_X; //nor
						6'b000000: allsign <= 21'b000_00_1_1_0_100000_0_0_0_00_X_X; //sll
						6'b000010: allsign <= 21'b000_00_1_1_0_100001_0_0_0_00_X_X; //srl
						6'b000011: allsign <= 21'b000_00_1_1_0_100011_1_0_0_00_X_X; //sra
						6'b101010: allsign <= 21'b000_00_1_0_0_110101_1_0_0_00_X_X; //slt
						6'b001000: allsign <= 21'b011_XX_0_X_X_XXXXXX_X_0_0_XX_X_X; //jr
						6'b001001: allsign <= 21'b011_10_1_X_X_XXXXXX_X_0_0_10_X_X; //jalr
						default:   allsign <= 21'b101_11_1_X_X_XXXXXX_X_0_0_10_X_X; //EXPT
					endcase
				end
				6'b100011: allsign <= 21'b000_01_1_0_1_000000_1_0_1_01_1_0; //lw
				6'b101011: allsign <= 21'b000_XX_0_0_1_000000_1_1_0_XX_1_0; //sw
				6'b001111: allsign <= 21'b000_01_1_0_1_000000_0_0_0_00_X_1; //lui
				6'b001000: allsign <= 21'b000_01_1_0_1_000000_1_0_0_00_1_0; //addi
				6'b001001: allsign <= 21'b000_01_1_0_1_000000_0_0_0_00_0_0; //addiu
				6'b001100: allsign <= 21'b000_01_1_0_1_011000_X_0_0_00_0_0; //andi
				6'b001101: allsign <= 21'b000_01_1_0_1_011110_X_0_0_00_0_0; //ori
				6'b001010: allsign <= 21'b000_01_1_0_1_110101_1_0_0_00_1_0; //slti
				6'b001011: allsign <= 21'b000_01_1_0_1_110101_0_0_0_00_0_0; //sltiu
				6'b000100: allsign <= 21'b001_XX_0_0_0_110011_1_0_0_XX_1_0; //beq
				6'b000101: allsign <= 21'b001_XX_0_0_0_110001_1_0_0_XX_1_0; //bne
				6'b000110: allsign <= 21'b001_XX_0_0_0_111101_1_0_0_XX_1_0; //blez
				6'b000111: allsign <= 21'b001_XX_0_0_0_111111_1_0_0_XX_1_0; //bgtz
				6'b000001: allsign <= 21'b001_XX_0_0_0_111011_1_0_0_XX_1_0; //bltz
				6'b000010: allsign <= 21'b010_XX_0_X_X_XXXXXX_X_0_0_XX_X_X; //j
				6'b000011: allsign <= 21'b010_10_1_X_X_XXXXXX_X_0_0_10_X_X; //jal
				default:   allsign <= 21'b101_11_1_X_X_XXXXXX_X_0_0_10_X_X; //EXPT
			endcase
		end
	end

endmodule
