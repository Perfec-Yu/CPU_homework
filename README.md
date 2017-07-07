# CPU_homework
summer assignment for digital processor course

can work with FPGA Basys3 XC7A35TCPG236-1, using Vivado.

rom.v contains machinecode of a program that finds the gcd of two 8 bit integers, which should be transmitted to the FPGA through UART, and every time an complete Byte has been received or sended, an interruption is invoked and will be automatically processed by the program; also, the program provides a possible solution to scan the digital tubes periodically to display the data in the specific register. 