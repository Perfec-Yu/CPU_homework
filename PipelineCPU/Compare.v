module Compare(ctrl,A,Compare_result,B);
input [2:0]ctrl;
input [31:0] B;
input [31:0] A;
output reg [31:0] Compare_result;

always @(*)
begin
     case(ctrl)
     3'b001: Compare_result <= {31'd0,A==B?1'b1:1'b0};
     3'b000: Compare_result <= {31'd0,A!=B?1'b1:1'b0};
     3'b010: Compare_result <= {31'b0,(A[31]^B[31])? A[31]:(A<B)?1'b1:1'b0};
     3'b110: Compare_result <= {31'd0,A[31]|(~(|A))};
     3'b100: Compare_result <= {31'd0,A[31]};
     3'b111: Compare_result <= {31'd0,~A[31]&(|A)};
     default: Compare_result <= 0;
     endcase
end
endmodule 

