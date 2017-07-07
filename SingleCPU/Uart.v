module Uart(sysclk,clk,reset,RX_DATA,TX_DATA,UART_CON,UART_SIGNAL,TX_EN,UART_RX,UART_TX); // Controller
    input [7:0] TX_DATA; // data to be sent
    input [4:0] UART_CON;
    input sysclk;
	input TX_EN;
	input UART_RX;
    input clk, reset;
	wire sampleclk;
	output UART_TX;
    output [7:0] RX_DATA;// data received
    output [1:0] UART_SIGNAL; // 0-RX_STATUS, 1-TX_STATUS, 2-TX_EN
	
    BRG baud1(.sysclk(sysclk),.sampleclk(sampleclk));
    Sender sender1(.sampleclk(sampleclk),.TX_DATA(TX_DATA),.TX_EN(TX_EN),.TX_STATUS(UART_SIGNAL[1]),.UART_TX(UART_TX));
    Receiver receiver1(.sampleclk(sampleclk),.RX_DATA(RX_DATA),.UART_RX(UART_RX),.RX_STATUS(UART_SIGNAL[0]),.reset(reset));

    always@(posedge sampleclk or negedge reset) begin
        if(~reset) begin
          //  RX_DATA <= 8'b0;
          //  UART_SIGNAL <= 3'b0;
        end
       // else if(UART_SIGNAL[2]) // sending request
			//UART_SIGNAL[2] <= UART_SIGNAL[1];
    end
endmodule 
