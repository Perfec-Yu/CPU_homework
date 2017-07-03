module Logic(A,B,ctrl,Bit_result);
input [31:0] A;
input [31:0] B;
input [3:0] ctrl;
output reg [31:0] Bit_result;

always @(*)
begin
     case(ctrl)
     4'b1000: Bit_result<= A & B;
     4'b1110: Bit_result<= A | B;
     4'b0110: Bit_result<= A ^ B;
     4'b0001: Bit_result<= ~(A | B);
     4'b1010: Bit_result<= A;
     default: Bit_result<= 0;
     endcase
end

endmodule

