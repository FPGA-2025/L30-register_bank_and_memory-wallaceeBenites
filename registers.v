module Registers (
    input  wire        clk,
    input  wire        wr_en_i,

    input  wire [4:0]  RS1_ADDR_i,
    input  wire [4:0]  RS2_ADDR_i,
    input  wire [4:0]  RD_ADDR_i,

    input  wire [31:0] data_i,
    output wire [31:0] RS1_data_o,
    output wire [31:0] RS2_data_o
);

    reg [31:0] regs [31:0];
    assign RS1_data_o = (RS1_ADDR_i == 5'd0) ? 32'd0 : regs[RS1_ADDR_i];
    assign RS2_data_o = (RS2_ADDR_i == 5'd0) ? 32'd0 : regs[RS2_ADDR_i];

    always @(posedge clk) begin
        if (wr_en_i && (RD_ADDR_i != 5'd0)) begin
            regs[RD_ADDR_i] <= data_i;
        end
    end

endmodule