`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);
/*	reg [1023:0] r;
	wire waddr;
	wire raddr1;
	wire raddr2;
	wire clk;
	wire wen;
	wire wdata;
	r[31:0]=0;since addr is not a constant,
	refuse to use a reg [1023:0] */
	reg [`DATA_WIDTH-1:0]r[0:31];
	reg [`ADDR_WIDTH:0]i; 
	//initial
	  // for(i=0;i<32;i=i+1) r[i]<=0;
	always @(posedge clk or posedge rst)
	begin
		if(rst)
		   for(i=0;i<32;i=i+1) r[i]<=0;
		else 
		 if(wen&&waddr!=5'd0)
		  begin
			r[waddr] <= wdata;
		  end
		r[0]=32'b0;
	end
	
	assign rdata1=r[raddr1];
	assign rdata2=r[raddr2];
	// TODO: Please add your logic code here*/

endmodule
