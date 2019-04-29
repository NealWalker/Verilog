`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output [`DATA_WIDTH - 1:0] Result
);

	// TODO: Please add your logic code here
	//reg CarryOut;
	//reg Overflow;
	//reg Zero;
	wire c;
	wire d;
	wire [33:0]a1;
	wire [33:0]a2;
	wire [33:0]a3;
	wire [33:0]a4;
	wire [33:0]a5;
	wire [33:0]a6;
	wire [33:0]b1;
	wire [31:0]b2;
	wire [33:0]a7;
	assign b1=(ALUop==3'b110)? {~{1'b0,B},1'b1}:(ALUop==3'b111)?{~{1'b0,B},1'b1}: {1'b0,B,1'b0}; 
	//assign Zero=0;
	//assign Overflow=0;
	//assign CarryOut=0;
	assign a1={1'b0,A,1'b1}&b1;
	assign a2={1'b0,A,1'b1}|b1;
	assign a3={1'b0,A,1'b1}+b1;
	assign a7={1'b0,A,1'b1}^b1;
	assign a4=a3;//{1'b0,A}+(~{1'b0,B}+1'b1);
	assign a5=(A[31]==0)? 0:3;
	assign b2=B<<A;
	assign {c,Result,d}=(ALUop==3'b101)? a7:(ALUop==3'b011)? ~a2:(ALUop==3'b100)? {1'b0,b2,1'b1}:(ALUop==3'b000)?a1:(ALUop==3'b001)? a2:(ALUop==3'b010)? a3:(ALUop==3'b110)? a4:(ALUop==3'b111)? ((A[31]^B[31]==1)? a5:(a4[32]==1)? 3:0):0;
	assign Overflow=c^Result[31]^A[31]^B[31];
	assign CarryOut=c;
	assign Zero=(Result==0)?1:0;
	//assign Result=(ALUop==3'b100)? B<<A:Result;
	//assign Result=(ALUop!=3'b111)? Result:(a4[31]==1)? 0:1;
	


endmodule
