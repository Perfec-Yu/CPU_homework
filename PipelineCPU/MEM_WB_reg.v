module MEM_WB_reg (clk, reset, data_in, data_out, ctr_in, ctr_out);
    input clk, reset;
    input [132:0] data_in;
    input [2:0] ctr_in;
    output reg [132:0] data_out;
    output reg [2:0] ctr_out;
    always@(posedge clk or negedge reset) begin
        if (~reset) begin
            data_out <= 133'b0;
            ctr_out <= 3'b0;
        end
        else begin
            data_out <= data_in;
            ctr_out <= ctr_in;
        end
    end
endmodule
