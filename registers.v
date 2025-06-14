module Registers (
    input  wire clk,
    input  wire wr_en_i,
    
    input  wire [4:0] RS1_ADDR_i,
    input  wire [4:0] RS2_ADDR_i,
    input  wire [4:0] RD_ADDR_i,

    input  wire [31:0] data_i,
    output wire [31:0] RS1_data_o,
    output wire [31:0] RS2_data_o
);


endmodule