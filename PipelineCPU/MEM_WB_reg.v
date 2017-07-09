module MEM_WB_reg (clk, reset, data_in, data_out, ctr_in, ctr_out);
    input clk, reset;
    input [132:0] data_in;
    input [2:0] ctr_in;
    output reg [36:0] data_out;
    output reg [2:0] ctr_out;
    always@(posedge clk or negedge reset) begin
        if (~reset) begin
            data_out <= 37'b0;
            ctr_out <= 3'b0;
        end
        else begin
            ctr_out <= ctr_in;
            data_out[4:0] <= data_in[4:0];
            case(ctr_in[2:1])
            2'b00: data_out[36:5] <= data_in[68:37];
            2'b01: data_out[36:5] <= data_in[36:5];
            2'b10: data_out[36:5] <= data_in[100:69];
            default : data_out[36:5] <= data_in[132:101];
            endcase
        end
    end
endmodule