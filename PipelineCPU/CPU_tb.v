`timescale 1ns/1ps
module CPU_tb();

	reg reset;

	reg sysclk;

	wire [7:0] switch;

	reg UART_RX;

	wire  [7:0] led;

	wire  [11:0] digi;

	wire  UART_TX;



	PipelineCPU CPU1(.reset(reset),.sysclk(sysclk),.switch(switch),.UART_RX(UART_RX),.led(led),

		.digi(digi),.UART_TX(UART_TX));



	initial begin

	reset <= 1'b1;

	sysclk <= 1'b0;

	UART_RX <= 1'b1;

end



always #5 sysclk <= ~sysclk;



initial begin

	#5  reset <= 1'b0;
	#10 reset <= 1'b1;

	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 ;
	#104167 UART_RX <= ~UART_RX;//0 0
	#208334 UART_RX <= ~UART_RX;//1
	#104167 UART_RX <= ~UART_RX;//0 0 0
	#312501 UART_RX <= ~UART_RX;//1
	#104167 UART_RX <= ~UART_RX;//0 0
	#208334 UART_RX <= ~UART_RX;//1
	#104167 ;
	#104167 ;
	#104167 ;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 UART_RX <= ~UART_RX;
	#104167 ;
	#104167 UART_RX <= ~UART_RX;//0 0
	#208334 UART_RX <= ~UART_RX;//1
	#104167 UART_RX <= ~UART_RX;//0 0 0
	#312501 UART_RX <= ~UART_RX;//1
	#104167 UART_RX <= ~UART_RX;//0 0
	#208334 UART_RX <= ~UART_RX;//1

end



endmodule