`timescale 1ns/1ps

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,UART_TX,UART_RX);
input reset,clk;
input rd,wr,UART_RX;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
output UART_TX;
reg [31:0] rdata;

output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output irqout;

reg [31:0] TH,TL;
reg [2:0] TCON;

wire [7:0] RX_DATA;
reg [7:0] TX_DATA;
reg [4:0] UART_CON;
wire [1:0] UART_SIGNAL;
wire UART_TX;
reg TX_EN;

assign irqout = TCON[2]|UART_CON[2]|UART_CON[3];
// read prepheral register
always@(*) begin
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;			
			32'h40000004: rdata <= TL;			
			32'h40000008: rdata <= {29'b0,TCON};				
			32'h4000000C: rdata <= {24'b0,led};			
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h40000018: rdata <= {24'b0,TX_DATA};
            32'h4000001C: rdata <= {24'b0,RX_DATA};
			32'h40000020: rdata <= {27'b0,UART_CON};
			default: rdata <= 32'b0;
		endcase
	end
	else
		rdata <= 32'b0;
end

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;
		TX_DATA <= 8'b0;
		//RX_DATA <= 8'b0;
		UART_CON <= 5'b00010;
		TX_EN <= 1'b0;
		//UART_SIGNAL <= 3'b0;
        //UART_TX <= 1'b0;
		led <= 8'b0;
		digi <= 12'b1;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
		if(wr) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];		
				32'h4000000C: led <= wdata[7:0];			
				32'h40000014: digi <= wdata[11:0];
                32'h40000018: begin
                    TX_DATA <= wdata[7:0]; // write data to be sent
                    TX_EN <= 1'b1; // send enable
                end
				32'h40000020: UART_CON <= wdata[4:0];
				default: ;
			endcase
		end
		
		// UART_SIGNAL[0,1,2] equals to [RX_STATUS,TX_STATUS,TX_EN] 
        if(~addr[5]) begin
	        if(UART_SIGNAL[1]) begin // send finished
	            if(UART_CON[0]) begin
					//UART_CON[0] <= 1'b0; // sending interrupt
					UART_CON[2] <= 1'b1; 
					UART_CON[4] <= 1'b0; // unoccupied
					TX_EN <= 1'b0;
				end
	        end
	        else if(~UART_SIGNAL[1]) begin // sending
	            UART_CON[0] <= 1'b1;
	            UART_CON[2] <= 1'b0;
	            UART_CON[4] <= 1'b1;
	        end

	        if(UART_SIGNAL[0]) begin  // read finished
	            if(UART_CON[1]) begin
	            	UART_CON[1] <= 1'b0;
					UART_CON[3] <= 1'b1;
				end
	        end
	        else begin
	            UART_CON[1] <= 1'b1;
	            UART_CON[3] <= 1'b0;
	        end
	    end
	end
end

Uart uartA(.clk(clk),.reset(reset),.TX_DATA(TX_DATA),.RX_DATA(RX_DATA),.UART_CON(UART_CON),
			.UART_SIGNAL(UART_SIGNAL),.TX_EN(TX_EN),.UART_RX(UART_RX),.UART_TX(UART_TX));
endmodule

