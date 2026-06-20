module ahb_slave_interface(
input HCLK,
input HRESETn,
input [31:0] HADDR,
input [31:0] HWDATA,
input [1:0] HTRANS,
input HWRITE,
input HREADYin,
output valid,
output fifo_wr,
output [71:0] fifo_din
);

wire [7:0] crc;

crc8_generator crc_gen(
HADDR,
HWDATA,
crc
);

assign valid = HREADYin & HTRANS[1];
assign fifo_wr = valid;
assign fifo_din = {HADDR,HWDATA,crc};

endmodule