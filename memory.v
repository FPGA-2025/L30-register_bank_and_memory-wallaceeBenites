module Memory #(
    parameter MEMORY_FILE = "",
    parameter MEMORY_SIZE = 4096
)(
    input  wire        clk,

    input  wire        rd_en_i,
    input  wire        wr_en_i,

    input  wire [31:0] addr_i,
    input  wire [31:0] data_i,
    output reg  [31:0] data_o,

    output wire        ack_o
);

    reg [31:0] mem [0:MEMORY_SIZE-1];
    initial begin
        if (MEMORY_FILE != "") begin
            $readmemh(MEMORY_FILE, mem);
        end
    end

    always @(posedge clk) begin
        if (wr_en_i) begin
            mem[addr_i[31:2]] <= data_i;
        end
    end

    always @(posedge clk) begin
        if (rd_en_i) begin
            data_o <= mem[addr_i[31:2]];
        end else begin
            data_o <= 32'd0;
        end
    end

    assign ack_o = rd_en_i || wr_en_i;

endmodule
