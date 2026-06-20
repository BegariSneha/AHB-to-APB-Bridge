module crc_checker(
input [71:0] fifo_data,
output reg error
);

wire [31:0] addr;
wire [31:0] data;
wire [7:0] crc_rx;
wire [7:0] crc_calc;

assign addr = fifo_data[71:40];
assign data = fifo_data[39:8];
assign crc_rx = fifo_data[7:0];

crc8_generator crc_gen(
addr,
data,
crc_calc
);

always @(*)
begin
if(crc_calc != crc_rx)
error = 1;
else
error = 0;
end

endmodule