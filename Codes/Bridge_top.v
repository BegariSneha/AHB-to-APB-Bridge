module bridge_top(
input HCLK,
input PCLK,
input HRESETn,
input PRESETn,
input [31:0] HADDR,
input [31:0] HWDATA,
input [1:0] HTRANS,
input HWRITE,
input HREADYin,
input [31:0] PRDATA,
output [31:0] HRDATA,
output HREADYout,
output HRESP,
output [31:0] PADDR,
output [31:0] PWDATA,
output PWRITE,
output PENABLE,
output [3:0] PSEL
);

wire valid;
wire fifo_wr;
wire fifo_rd;
wire fifo_full;
wire fifo_empty;

wire [71:0] fifo_din;
wire [71:0] fifo_dout;

wire gated_hclk;
wire gated_pclk;

wire crc_error;

ahb_slave_interface ahb_if(
HCLK,
HRESETn,
HADDR,
HWDATA,
HTRANS,
HWRITE,
HREADYin,
valid,
fifo_wr,
fifo_din
);

async_fifo fifo(
HCLK,
PCLK,
HRESETn,
PRESETn,
fifo_wr,
fifo_rd,
fifo_din,
fifo_dout,
fifo_full,
fifo_empty
);

crc_checker crc_chk(
fifo_dout,
crc_error
);

apb_controller_fsm apb_ctrl(
PCLK,
PRESETn,
fifo_empty,
fifo_dout,
crc_error,
PRDATA,
fifo_rd,
PADDR,
PWDATA,
PWRITE,
PENABLE,
PSEL,
HRDATA
);

assign HREADYout = !fifo_full;
assign HRESP = crc_error;

endmodule