module MEM(Read_data_1, Read_data_2, Read_data);
    input [31:0] Read_data_1;
    input [31:0] Read_data_2;
    input Data_Read;
    output [31:0] Read_data;
	assign Read_data = Data_Read? Read_data_2:Read_data_1;
endmodule
