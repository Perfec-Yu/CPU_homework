module Sender(sampleclk,TX_DATA,TX_EN,TX_STATUS,UART_TX);
input sampleclk,TX_EN;
input [7:0] TX_DATA;
output reg TX_STATUS,UART_TX;
reg flag,state;
integer i,j;
//state==0 means sender is sending data
//state==1 means sender is waiting for new data
always @(posedge sampleclk) begin
	case(state)
	0:
	begin
		TX_STATUS<=0;
		j=j+1;
		if(flag==0&&j==8) begin 
			UART_TX<=0;
			flag<=1;
			j<=0;
		end
		if(flag==1&&j==16) begin
			UART_TX<=TX_DATA[i];
			i<=i+1;
			j<=0;
		end
		if(i==8&&j==16) begin
			TX_STATUS<=1;
			UART_TX<=1;
			state<=1;
			i<=0;
		end
	end
	1:
	begin 
		TX_STATUS<=1;
		UART_TX<=1;
		i<=0;
		j<=0;
		flag<=0;
		if(TX_EN==1) state<=0;
	end
	default:state<=1;
	endcase
end
endmodule

