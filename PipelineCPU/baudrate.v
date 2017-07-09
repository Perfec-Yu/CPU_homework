module BRG(sysclk,sampleclk);
input sysclk;
//output sampleclk;
//assign sampleclk = sysclk;
output reg sampleclk = 0;
integer count=0;
always @(posedge sysclk) begin
	count=count+1;
	if(count==325) begin
		count=0;
		sampleclk=~sampleclk;
	end
end
endmodule

