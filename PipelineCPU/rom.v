`timescale 1ns/1ps

module ROM (addr,data);
input [30:0] addr;
output [31:0] data;

localparam ROM_SIZE = 256*4;
(* rom_style = "distributed" *) reg [31:0] ROMDATA[ROM_SIZE-1:0];

assign data=(addr < ROM_SIZE)?ROMDATA[addr[30:2]]:32'b0;

integer i;
initial begin
ROMDATA[0] <= 32'b00001000000000000000000000000011;
ROMDATA[1] <= 32'b00001000000000000000000000111101;
ROMDATA[2] <= 32'b00001000000000000000000001111110;
ROMDATA[3] <= 32'b00111100000100000100000000000000;
ROMDATA[4] <= 32'b00100000000101001110110001110111;
ROMDATA[5] <= 32'b00100000000101011111111111111111;
ROMDATA[6] <= 32'b00100000000101100000000000000011;
ROMDATA[7] <= 32'b00100000000101110000000000000001;
ROMDATA[8] <= 32'b10101110000000000000000000001000;
ROMDATA[9] <= 32'b10101110000101000000000000000000;
ROMDATA[10] <= 32'b10101110000101010000000000000100;
ROMDATA[11] <= 32'b00100000000001000000111100000000;
ROMDATA[12] <= 32'b00100000000001010000000100000000;
ROMDATA[13] <= 32'b00100000000010000000000011000000;
ROMDATA[14] <= 32'b10101100000010000000000000000000;
ROMDATA[15] <= 32'b00100000000010000000000011111001;
ROMDATA[16] <= 32'b10101100000010000000000000000100;
ROMDATA[17] <= 32'b00100000000010000000000010100100;
ROMDATA[18] <= 32'b10101100000010000000000000001000;
ROMDATA[19] <= 32'b00100000000010000000000010110000;
ROMDATA[20] <= 32'b10101100000010000000000000001100;
ROMDATA[21] <= 32'b00100000000010000000000010011001;
ROMDATA[22] <= 32'b10101100000010000000000000010000;
ROMDATA[23] <= 32'b00100000000010000000000010010010;
ROMDATA[24] <= 32'b10101100000010000000000000010100;
ROMDATA[25] <= 32'b00100000000010000000000010000010;
ROMDATA[26] <= 32'b10101100000010000000000000011000;
ROMDATA[27] <= 32'b00100000000010000000000011111000;
ROMDATA[28] <= 32'b10101100000010000000000000011100;
ROMDATA[29] <= 32'b00100000000010000000000010000000;
ROMDATA[30] <= 32'b10101100000010000000000000100000;
ROMDATA[31] <= 32'b00100000000010000000000010010000;
ROMDATA[32] <= 32'b10101100000010000000000000100100;
ROMDATA[33] <= 32'b00100000000010000000000010001000;
ROMDATA[34] <= 32'b10101100000010000000000000101000;
ROMDATA[35] <= 32'b00100000000010000000000010000011;
ROMDATA[36] <= 32'b10101100000010000000000000101100;
ROMDATA[37] <= 32'b00100000000010000000000011000110;
ROMDATA[38] <= 32'b10101100000010000000000000110000;
ROMDATA[39] <= 32'b00100000000010000000000010100001;
ROMDATA[40] <= 32'b10101100000010000000000000110100;
ROMDATA[41] <= 32'b00100000000010000000000010000110;
ROMDATA[42] <= 32'b10101100000010000000000000111000;
ROMDATA[43] <= 32'b00100000000010000000000010001110;
ROMDATA[44] <= 32'b10101100000010000000000000111100;
ROMDATA[45] <= 32'b10101110000101100000000000001000;
ROMDATA[46] <= 32'b00111100000100011000000000000000;
ROMDATA[47] <= 32'b00111100000100101000000000000000;
ROMDATA[48] <= 32'b00000000000000000001000000100100;
ROMDATA[49] <= 32'b00010000010000001111111111111111;
ROMDATA[50] <= 32'b00000000111000001001100000100101;
ROMDATA[51] <= 32'b00000000110001110100000000101010;
ROMDATA[52] <= 32'b00010101000000000000000000000010;
ROMDATA[53] <= 32'b00000000110001110011000000100010;
ROMDATA[54] <= 32'b00001000000000000000000000110011;
ROMDATA[55] <= 32'b00000000110000000011100000100101;
ROMDATA[56] <= 32'b00000010011000000011000000100101;
ROMDATA[57] <= 32'b00010100111000001111111111111000;
ROMDATA[58] <= 32'b10101110000100110000000000001100;
ROMDATA[59] <= 32'b10101110000100110000000000011000;
ROMDATA[60] <= 32'b00001000000000000000000000101110;
ROMDATA[61] <= 32'b10001110000010100000000000100000;
ROMDATA[62] <= 32'b00000000000010100101111100000000;
ROMDATA[63] <= 32'b00000000000010110101111111000010;
ROMDATA[64] <= 32'b00010101011000000000000000101001;
ROMDATA[65] <= 32'b00000000000010100101111101000000;
ROMDATA[66] <= 32'b00000000000010110101111111000010;
ROMDATA[67] <= 32'b00010101011000000000000000110101;
ROMDATA[68] <= 32'b10101110000101110000000000001000;
ROMDATA[69] <= 32'b00101000101010100000001000000000;
ROMDATA[70] <= 32'b00010101010000000000000000011001;
ROMDATA[71] <= 32'b00101000101010100000010000000000;
ROMDATA[72] <= 32'b00010101010000000000000000010000;
ROMDATA[73] <= 32'b00101000101010100000100000000000;
ROMDATA[74] <= 32'b00010101010000000000000000000111;
ROMDATA[75] <= 32'b00000000000011010101000100000010;
ROMDATA[76] <= 32'b00000000000010100101000010000000;
ROMDATA[77] <= 32'b10001101010010100000000000000000;
ROMDATA[78] <= 32'b00000001010001000101000000100000;
ROMDATA[79] <= 32'b00000001010001010101000000100010;
ROMDATA[80] <= 32'b00100000000001010000000100000000;
ROMDATA[81] <= 32'b00001000000000000000000001100111;
ROMDATA[82] <= 32'b00110001101010100000000000001111;
ROMDATA[83] <= 32'b00000000000010100101000010000000;
ROMDATA[84] <= 32'b10001101010010100000000000000000;
ROMDATA[85] <= 32'b00000001010001000101000000100000;
ROMDATA[86] <= 32'b00000001010001010101000000100010;
ROMDATA[87] <= 32'b00000000000001010010100001000000;
ROMDATA[88] <= 32'b00001000000000000000000001100111;
ROMDATA[89] <= 32'b00000000000011000101000100000010;
ROMDATA[90] <= 32'b00000000000010100101000010000000;
ROMDATA[91] <= 32'b10001101010010100000000000000000;
ROMDATA[92] <= 32'b00000001010001000101000000100000;
ROMDATA[93] <= 32'b00000001010001010101000000100010;
ROMDATA[94] <= 32'b00000000000001010010100001000000;
ROMDATA[95] <= 32'b00001000000000000000000001100111;
ROMDATA[96] <= 32'b00110001100010100000000000001111;
ROMDATA[97] <= 32'b00000000000010100101000010000000;
ROMDATA[98] <= 32'b10001101010010100000000000000000;
ROMDATA[99] <= 32'b00000001010001000101000000100000;
ROMDATA[100] <= 32'b00000001010001010101000000100010;
ROMDATA[101] <= 32'b00000000000001010010100001000000;
ROMDATA[102] <= 32'b00001000000000000000000001100111;
ROMDATA[103] <= 32'b10101110000010100000000000010100;
ROMDATA[104] <= 32'b10101110000101100000000000001000;
ROMDATA[105] <= 32'b00001000000000000000000001111101;
ROMDATA[106] <= 32'b00100001101011010000000000000001;
ROMDATA[107] <= 32'b10001110000010100000000000100000;
ROMDATA[108] <= 32'b00110001010010100000000000010111;
ROMDATA[109] <= 32'b10101110000010100000000000100000;
ROMDATA[110] <= 32'b00000000000100010101011111000010;
ROMDATA[111] <= 32'b00010101010000000000000000000101;
ROMDATA[112] <= 32'b10001110000100100000000000011100;
ROMDATA[113] <= 32'b00000010010000000011100000100101;
ROMDATA[114] <= 32'b00000010010000000110100000100101;
ROMDATA[115] <= 32'b00100000000000100000000000000001;
ROMDATA[116] <= 32'b00001000000000000000000001111101;
ROMDATA[117] <= 32'b10001110000100010000000000011100;
ROMDATA[118] <= 32'b00000010001000000011000000100101;
ROMDATA[119] <= 32'b00000010001000000110000000100101;
ROMDATA[120] <= 32'b00001000000000000000000001111101;
ROMDATA[121] <= 32'b10001110000010100000000000100000;
ROMDATA[122] <= 32'b00110001010010100000000000001011;
ROMDATA[123] <= 32'b10101110000010100000000000100000;
ROMDATA[124] <= 32'b00001000000000000000000001111101;
ROMDATA[125] <= 32'b00000011010000000000000000001000;
ROMDATA[126] <= 32'b00000011010000000000000000001000;
	    for (i=127;i<ROM_SIZE;i=i+1) begin
            ROMDATA[i] <= 32'b0;
        end
end
endmodule
