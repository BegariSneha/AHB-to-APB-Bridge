module async_fifo(
input wclk,
input rclk,
input wrst,
input rrst,
input wr_en,
input rd_en,
input [71:0] din,
output [71:0] dout,
output full,
output empty
);

reg [71:0] mem [0:15];
reg [4:0] wptr;
reg [4:0] rptr;

assign full = (wptr[4]!=rptr[4]) && (wptr[3:0]==rptr[3:0]);
assign empty = (wptr==rptr);

always @(posedge wclk or negedge wrst)
begin
if(!wrst)
wptr<=0;
else if(wr_en && !full)
begin
mem[wptr[3:0]]<=din;
wptr<=wptr+1;
end
end

assign dout = mem[rptr[3:0]];

always @(posedge rclk or negedge rrst)
begin
if(!rrst)
rptr<=0;
else if(rd_en && !empty)
rptr<=rptr+1;
end

endmodule