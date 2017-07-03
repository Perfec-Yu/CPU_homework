module Compare(ctrl,Zero,Negative,A,Compare_result);
input [2:0]ctrl;
input Zero;
input Negative;
input [31:0] A;
output reg [31:0] Compare_result;

always @(*)
begin
     case(ctrl)
     3'b001: Compare_result <= {31'd0,Zero};
     3'b000: Compare_result <= {31'd0,~Zero};
     3'b010: Compare_result <= {31'd0,Negative};
     3'b110: Compare_result <= {31'd0,A[31]|(~(|A))};
     3'b100: Compare_result <= {31'd0,A[31]};
     3'b111: Compare_result <= {31'd0,~A[31]&(|A)};
     default: Compare_result <= 0;
     endcase
end
endmodule 

