module ID_EX_reg(clk, reset, EX_Branch_EN, EX_ConBA, ID_PC, EX_PC, data_in, ctr_in, data_out, ctr_out, EX_Flush);
    input clk, reset;
    input EX_Branch_EN;
    input [31:0] EX_ConBA;
    input [147:0] data_in;
    input [16:0] ctr_in;
    input [31:0] ID_PC;
    input EX_Flush;
    output [147:0] data_out;
    output [16:0] ctr_out;
    output [31:0] EX_PC;
    always@(posedge clk or negedge reset) begin
        if (~reset) begin
            data_out <= 148'b0;
            ctr_out <= 17'b0;
        end
        else begin
            if (EX_Flush) begin
                data_out <= 148'b0;
                ctr_out <= 17'b0;
                EX_PC <= 32'b0;
            end
            else begin
                data_out <= data_in;
                ctr_out <= ctr_out;
                if (EX_Branch_EN & ID_IRQ) begin
                    EX_PC <= EX_ConBA;
                end
                else begin
                    EX_PC <= ID_PC;
                end
            end
        end
    end
endmodule
