module ID_EX_reg(clk, reset, MEM_Branch_EN, EX_Branch_EN, EX_ConBA, IF_PC, ID_PC, EX_PC, data_in, ctr_in, data_out, ctr_out, EX_Flush, EX_ALU_out, MEM_PC, MEM_Rd, MEM_RegWr, MEM_ALU_out, MEM_MemtoReg, MEM_Read_data, MEM_PC_Plus_4, WB_Rd, WB_DatabusC, WB_RegWr, EX_DatabusB, EX_MEM_Rd);
    input clk, reset;
    input EX_Branch_EN;
    input MEM_Branch_EN;
    input [31:0] EX_ConBA;
    input [148:0] data_in;
    input [16:0] ctr_in;
    input [31:0] ID_PC;
    input [31:0] IF_PC;
    input EX_Flush;
    input [31:0] EX_ALU_out;
    input [31:0] EX_DatabusB;
    input [31:0] MEM_PC;
    input [4:0] MEM_Rd;
    input MEM_RegWr;
    input [31:0] MEM_ALU_out;
    input [1:0] MEM_MemtoReg;
    input [31:0] MEM_Read_data;
    input [31:0] MEM_PC_Plus_4;
    input [31:0] WB_DatabusC;
    input WB_RegWr;
    input [4:0] WB_Rd;
    input [4:0] EX_MEM_Rd;
    output reg [148:0] data_out;
    output reg [15:0] ctr_out;
    output reg [31:0] EX_PC;
    always@(posedge clk or negedge reset) begin
        if (~reset) begin
            data_out <= 149'b0;
            ctr_out <= 16'b0;
            EX_PC <= 32'b0;
        end
        else begin
            if (EX_Flush) begin
                data_out <= 149'b0;
                ctr_out <= 16'b0;
                EX_PC <= 32'b0;
            end
            else begin
                if (MEM_Branch_EN & ctr_in[0]) begin
                    EX_PC <= IF_PC;
                end
                else if (EX_Branch_EN & ctr_in[0]) begin
                    EX_PC <= EX_ConBA;
                end
                else begin
                    EX_PC <= ID_PC;
                end

                if (ctr_out[13] && (EX_MEM_Rd != 5'b0) && EX_MEM_Rd == data_in[148:144]) begin
                    if (ctr_out[2]) begin
                        data_out[64:33] <= EX_DatabusB;
                    end
                    else begin
                        data_out[64:33] <= EX_ALU_out;
                    end
                end
                else if (MEM_RegWr && MEM_Rd != 0 && (MEM_Rd == data_in[148:144])) begin
                	case (MEM_MemtoReg)
                	2'b00: data_out[64:33] <= MEM_ALU_out;
                	2'b01: data_out[64:33] <= MEM_Read_data;
                	2'b10: data_out[64:33] <= MEM_PC_Plus_4;
                	default: data_out[64:33] <= MEM_PC;
                	endcase
                end
                else if (WB_Rd == data_in[148:144] && WB_RegWr) begin
                	data_out[64:33] <= WB_DatabusC;
                end
                else begin
                	data_out[64:33] <= data_in[64:33];
                end

                if (ctr_out[13] && EX_MEM_Rd != 0 && EX_MEM_Rd == data_in[143:139]) begin
                	if(ctr_out[2]) begin
                        data_out[32:1] <= EX_DatabusB;   
                    end
                    else begin
                        data_out[32:1] <= EX_ALU_out;
                    end
                end
                else if (MEM_RegWr && MEM_Rd != 0 && MEM_Rd == data_in[143:139]) begin
                	case (MEM_MemtoReg)
                	2'b00: data_out[32:1] <= MEM_ALU_out;
                	2'b01: data_out[32:1] <= MEM_Read_data;
                	2'b10: data_out[32:1] <= MEM_PC_Plus_4;
                	default: data_out[32:1] <= MEM_PC;
                	endcase
                end
                else if (WB_Rd == data_in[143:139] && WB_RegWr) begin
                	data_out[32:1] <= WB_DatabusC;
                end
                else begin
                	data_out[32:1] <= data_in[32:1];
                end

                data_out[148:65] <= data_in[148:65];
                data_out[0] <= data_in[0];
                ctr_out <= ctr_in[16:1];
            end
        end
    end
endmodule