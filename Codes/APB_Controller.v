module apb_controller_fsm(
input PCLK,
input PRESETn,
input fifo_empty,
input [71:0] fifo_dout,
input crc_error,
input [31:0] PRDATA,
output reg fifo_rd,
output reg [31:0] PADDR,
output reg [31:0] PWDATA,
output reg PWRITE,
output reg PENABLE,
output reg [3:0] PSEL,
output reg [31:0] HRDATA
);

parameter IDLE=2'b00;
parameter SETUP=2'b01;
parameter ENABLE=2'b10;

reg [1:0] state;
reg [1:0] next;

wire [31:0] addr;
wire [31:0] data;

assign addr = fifo_dout[71:40];
assign data = fifo_dout[39:8];

always @(posedge PCLK or negedge PRESETn)
begin
if(!PRESETn)
state<=IDLE;
else
state<=next;
end

always @(*)
begin
case(state)

IDLE:
if(!fifo_empty && !crc_error)
next=SETUP;
else
next=IDLE;

SETUP:
next=ENABLE;

ENABLE:
next=IDLE;

default:
next=IDLE;

endcase
end

always @(posedge PCLK or negedge PRESETn)
begin
if(!PRESETn)
begin
PENABLE<=0;
fifo_rd<=0;
PADDR<=0;
PWDATA<=0;
PWRITE<=0;
PSEL<=0;
HRDATA<=0;
end
else
begin
case(state)

IDLE:
begin
PENABLE<=0;
fifo_rd<=0;
PSEL<=0;
PWRITE<=0;
end

SETUP:
begin
fifo_rd<=0; // Don't read yet
PADDR<=addr;
PWDATA<=data;
PWRITE<=1;
PSEL<=4'b0001;
end

ENABLE:
begin
PENABLE<=1;
HRDATA<=PRDATA;
fifo_rd<=1; // Pop from FIFO at the end of the transaction
end

endcase
end
end

endmodule