module ALU (A, B, ALUFun, Sign, out, Zero, Overflow, Negative);
        
        input [31:0] A; // ALU operand
	input [31:0] B; // ALU operand
        input [5:0] ALUFun; // ALU Function
        input Sign; // ALU works with signed or unsigned numbers
	output reg [31:0] out; // ALU output 
                           // ?reg
        output Zero; // ALU output, Branch equal
        output Overflow; // ALU output, result overflow
        output Negative; // ALU output, result negative
        
        wire[31:0] Add_result;
        wire[31:0] Bit_result;
        wire[31:0] Shift_result;
        wire[31:0] Compare_result;
        Add add(.A(A),.B(B),.ctrl(ALUFun[0]),.Sign(Sign),.Add_result(Add_result),.Zero(Zero),.Overflow(Overflow),.Negative(Negative));
        Logic logic(.A(A),.B(B),.ctrl(ALUFun[3:0]),.Bit_result(Bit_result));
        Compare compare(.ctrl(ALUFun[3:1]),.Zero(Zero),.Negative(Negative),.A(A),.Compare_result(Compare_result));
        Shift shift(.A(A),.B(B),.ctrl(ALUFun[1:0]),.Shift_result(Shift_result));
        always @(*)
        begin case(ALUFun[5:4])
        2'b00: out = Add_result; 
        2'b01: out = Bit_result;
        2'b10: out = Shift_result;
        2'b11: out = Compare_result;
        endcase
        end

endmodule
        
