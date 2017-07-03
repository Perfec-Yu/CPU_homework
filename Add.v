module Add(A,B,ctrl,Sign,Add_result,Zero,Overflow,Negative);

input [31:0] A;
input [31:0] B;
input ctrl;
input Sign;

output [31:0] Add_result;
output Zero;
output Overflow;
output Negative;

wire [31:0] B1;
wire Overflow_sign;

assign B1=(ctrl==1)?(~B)+1:B;
assign {Overflow_sign,Add_result}=(ctrl==1)?(~B)+1+A:B+A;
assign Zero=~|Add_result;
assign Overflow=Sign & (A[31]^~B1[31]) & (A[31]^Add_result[31]);
assign Negative=(Sign&Add_result[31]&~Overflow) | (~Sign&~Overflow_sign);

endmodule
 
