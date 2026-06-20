`timescale 1ns/1ps

module tb;

reg HCLK;
reg PCLK;
reg HRESETn;
reg PRESETn;

reg [31:0] HADDR;
reg [31:0] HWDATA;
reg [1:0] HTRANS;
reg HWRITE;
reg HREADYin;

reg [31:0] PRDATA;

wire [31:0] HRDATA;
wire HREADYout;
wire HRESP;
wire [31:0] PADDR;
wire [31:0] PWDATA;
wire PWRITE;
wire PENABLE;
wire [3:0] PSEL;

bridge_top dut(
HCLK,
PCLK,
HRESETn,
PRESETn,
HADDR,
HWDATA,
HTRANS,
HWRITE,
HREADYin,
PRDATA,
HRDATA,
HREADYout,
HRESP,
PADDR,
PWDATA,
PWRITE,
PENABLE,
PSEL
);

reg [31:0] apb_mem [0:255];
reg intent_fifo [0:15];
integer intent_wptr;
integer intent_rptr;

always #5 HCLK = ~HCLK;
always #10 PCLK = ~PCLK;

integer i, j;
initial
begin
    intent_wptr = 0;
    intent_rptr = 0;
    for(j=0;j<256;j=j+1)
        apb_mem[j]=0;
    
    for(i=0;i<16;i=i+1) begin
        dut.fifo.mem[i]=72'h0;
        intent_fifo[i]=0;
    end
    
    dut.fifo.wptr = 0;
    dut.fifo.rptr = 0;

    PRDATA=0;
end

always @(posedge PCLK)
begin
if(PSEL && PENABLE)
begin
    if(PWRITE && intent_fifo[intent_rptr[3:0]])
        apb_mem[PADDR[7:0]] <= PWDATA;
    
    PRDATA <= apb_mem[PADDR[7:0]];
    intent_fifo[intent_rptr[3:0]] <= 0;
    intent_rptr <= intent_rptr + 1;
end
else if (!PSEL)
begin
    PRDATA <= 0;
end
end

task ahb_write;
input [31:0] addr;
input [31:0] data;
begin
@(negedge HCLK);
while(!HREADYout) @(negedge HCLK);
HADDR  <= addr;
HWDATA <= data;
HTRANS <= 2'b10;
HWRITE <= 1;
intent_fifo[intent_wptr[3:0]] <= 1;
intent_wptr <= intent_wptr + 1;
@(negedge HCLK);
HTRANS <= 2'b00;
HWRITE <= 0;
HADDR  <= 0;
HWDATA <= 0;
end
endtask

task ahb_read;
input [31:0] addr;
begin
@(negedge HCLK);
while(!HREADYout) @(negedge HCLK);
HADDR  <= addr;
HTRANS <= 2'b10;
HWRITE <= 0;
HWDATA <= 0;
intent_fifo[intent_wptr[3:0]] <= 0;
intent_wptr <= intent_wptr + 1;
@(negedge HCLK);
HTRANS <= 2'b00;
HADDR  <= 0;
end
endtask

initial
begin
HCLK=0;
PCLK=0;
HRESETn=0;
PRESETn=0;
HADDR=0;
HWDATA=0;
HTRANS=0;
HWRITE=0;
HREADYin=1;
PRDATA=0;

#50;

HRESETn=1;
PRESETn=1;

#50;


ahb_write(32'h00000010,32'h11111111);
ahb_write(32'h00000014,32'h22222222);
ahb_write(32'h00000018,32'h33333333);

#200;

ahb_read(32'h00000010);
ahb_read(32'h00000014);
ahb_read(32'h00000018);

#200;

ahb_write(32'h00000020,32'h00000000);

#400;

$finish;

end



endmodule