module Receiver(UART_RX,sampleclk,RX_DATA,RX_STATUS,reset);
input UART_RX,sampleclk,reset;
output reg [7:0] RX_DATA;
output reg RX_STATUS;
reg flag,state=0;
integer i=0,j=0;
//state represents whether it is reading data or not
//flag judges whether we are staying at initial bit or not
always @(posedge sampleclk or negedge reset) begin
	if(~reset) begin
		RX_STATUS<=0;
		i<=0;
		j<=0;
		flag<=0;
		RX_DATA<=0;
	end
	else if(state==1) begin
		j=j+1;
		if(flag==0&&j==8) begin flag<=1; j<=0; end
		if(flag==1&&j==16) begin
			RX_DATA[i]<=UART_RX;
			i=i+1;
			j<=0;
		end
		if(i==8) begin
			RX_STATUS<=1;
			state<=0;
		end
	end
	else if(UART_RX==0) state<=1;
	else begin 
		RX_STATUS<=0;
		i<=0;
		j<=0;
		flag<=0;
	end	
end
endmodule

