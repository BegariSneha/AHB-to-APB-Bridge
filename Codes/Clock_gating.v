module clock_gating(
input clk,
input enable,
output gclk
);

assign gclk = clk & enable;

endmodule