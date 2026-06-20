module crc8_generator(
input [31:0] addr,
input [31:0] data,
output reg [7:0] crc
);

integer i;
reg [63:0] d;
reg [7:0] c;

always @(*)
begin
d = {addr,data};
c = 8'h00;

for(i=0;i<64;i=i+1)
begin
if((c[7] ^ d[63-i])==1)
c = {c[6:0],1'b0} ^ 8'h07;
else
c = {c[6:0],1'b0};
end

crc = c;
end

endmodule