`timescale 10ns / 1ns
`define R_type 6'b000000
`define lw     6'b100011
`define sw     6'b101011
`define addiu  6'b001001
`define beq    6'b000100
`define bne    6'b000101
`define lui    6'b001111
`define slti   6'b001010
`define jump   6'b000010
`define jal    6'b000011
`define sltiu  6'b001011
`define andi   6'b001100
`define bgez   6'b000001
`define blez   6'b000110
`define lb     6'b100000
`define lbu    6'b100100
`define lh     6'b100001
`define lhu    6'b100101
`define lwl    6'b100010
`define lwr    6'b100110
`define ori    6'b001101
`define sb     6'b101000
`define sh     6'b101001
`define swl    6'b101010
`define swr    6'b101110
`define xori   6'b001110
//the exisiting translation
`define R_type_out 10'b0100100010
`define lw_out     10'b0011110000
`define sw_out     10'b0010001000
`define beq_out    10'b0000000101
`define addiu_out  10'b0010100000
`define bne_out    10'b0000000101
`define lui_out	   10'b0010100000
`define slti_out   10'b0010100000
`define sltiu_out  10'b0010100000
`define jump_out   10'b1000000000
`define jal_out    10'b1000100000
`define andi_out   10'b0010100000
`define bgez_out   10'b0000000101
`define blez_out   10'b0000000101
`define lb_out     10'b0011110000
`define ori_out    10'b0010100000
`define xori_out   10'b0010100000
//`define lbu_out    10'b0011110000
//`define lh_out     10'b0011110000


//some variebles are actually undefined,here we assign them with zero

module mips_cpu(
	input  rst,
	input  clk,

	output reg [31:0] PC,
	input  [31:0] Instruction,

	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,

	input  [31:0] Read_data,
	output MemRead
);

	// THESE THREE SIGNALS ARE USED IN OUR TESTBENCH
	// PLEASE DO NOT MODIFY SIGNAL NAMES
	// AND PLEASE USE THEM TO CONNECT PORTS
	// OF YOUR INSTANTIATION OF THE REGISTER FILE MODULE
	wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;
	
	// TODO: PLEASE ADD YOUT CODE BELOW
	wire RegDst;
	wire ALUsrc;
	wire MemtoReg;
	wire RegWrite;
	wire Branch;
	//wire Sllpos;to deal with the operation sll, a new variable is added
	wire [1:0] ALUop;
	wire [2:0] ALU_ctr;
	//reg_file	
	wire [4:0] RF_raddr1, RF_raddr2;
    	//wire RF_in_wen;
    	//wire [31:0] RF_in_wdata;
    	wire [31:0] RF_rdata1, RF_rdata2;
	//alu
	wire [31:0] alu1_A;
	wire [31:0] alu1_B;
	wire [31:0] alu1_R;
	wire alu1_Overflow;
	wire alu1_Carryout;
	wire alu1_Zero;
	/*wire [31:0] alu2_A;
	wire [31:0] alu2_B;
	wire [31:0] alu2_R;
	wire alu2_Overflow;
	wire alu2_Carryout;
	wire alu2_Zero;*/
	//others	
	wire [31:0] PC_next;
	wire [31:0] PC_final;
	wire [31:0] PC_jump;
	wire [31:0] Sign_extend;
	wire [9:0] Control_out;
	wire [5:0] OP;
	wire [5:0] Funct;
	wire [2:0] Half_ctr;
	wire BranchSelect;
	wire Jum;
	wire [1:0] byte;
	wire [31:0] Address_a;//aligned one
	wire [31:0] Address_b;
	wire [31:0] byte_data_1;
	wire [31:0] byte_data_2;
	wire [31:0] byte_data_l;
	wire [31:0] byte_data_r;
	wire [31:0] movn_rd_data;
	wire [31:0] data_sllv;
	wire [4:0] sa;
	wire [31:0] data_sra;
	//wire [31:0] data_srav;
	wire [31:0] data_srl;
	//wire [31:0] data_srlv;
	always @(posedge clk or posedge rst)
	begin
        if(rst)

            PC<=0;

        else

            PC<=PC_final;
	end
	//related module
	
	
	
	//lots of calculation
	assign Write_strb=(OP==`swl)?((byte==2'b00)?4'b0001:(byte==2'b01)?4'b0011:(byte==2'b10)?4'b0111:4'b1111):
	(OP==`swr)?((byte==2'b00)?4'b1111:(byte==2'b01)?4'b1110:(byte==2'b10)?4'b1100:4'b1000):
	(OP==`sb)?((byte==2'b00)?4'b0001:(byte==2'b01)?4'b0010:(byte==2'b10)?4'b0100:4'b1000):
	(OP==`sh)?((byte==2'b11||byte==2'b10)?4'b1100:4'b0011):4'b1111;
	assign OP=Instruction[31:26];
	assign Control_out=(OP==`xori)?`xori_out:(OP==`sb||OP==`sh||OP==`swl||OP==`swr)?`sw_out:(OP==`ori)? `ori_out:(OP==`lb||OP==`lbu||OP==`lh||OP==`lhu||OP==`lwr||OP==`lwl)? `lb_out:(OP==`blez)? `blez_out:(OP==`bgez)? `bgez_out:(OP==`andi)? `andi_out:(OP==`sltiu)? `sltiu_out:(OP==6'b000000 && Funct==6'b001000)? 10'b0000000000:(OP==`jal)? `jal_out: (OP==`jump)? `jump_out: (OP==`slti)? `slti_out:(OP==`lui)? `lui_out:(OP==`R_type)? `R_type_out:((OP==`lw)? `lw_out:((OP==`sw)? `sw_out:((OP==`beq)? `beq_out:((OP==`addiu)? `addiu_out:((OP==`bne)? `bne_out:10'd0)))));
	assign {Jum,RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUop}=Control_out;
	assign Funct=Instruction[5:0];
	assign Half_ctr[2]=ALUop[0]|(ALUop[1]&Funct[1]);
	assign Half_ctr[1]=(~ALUop[1])|(~Funct[2]);
	assign Half_ctr[0]=ALUop[1]&(Funct[3]|Funct[0]);
	assign ALU_ctr=(OP==6'b000000&&Funct==6'b101011)?3'b110:(OP==`xori)? 3'b101:(OP==6'b000000&&Funct==6'b100110)?3'b101:(OP==6'b000000&&Funct==6'b100011)? 3'b110:(OP==`ori)? 3'b001:(Funct==6'b100111&&OP==6'b000000)? 3'b011:(OP==`lb||OP==`lbu||OP==`lh||OP==`lhu||OP==`lwr||OP==`lwl)? 3'b010:(OP==`bgez||OP==`blez)? 3'b111:(OP==`andi)? 3'b000:(OP==6'b000000 && Funct==6'b001000)? 3'b010:(OP==`sltiu)? 3'b110:(OP==`slti)? 3'b111:(OP==`lui)? 3'b010: (OP==6'b000000&&Funct==6'b100001)? 3'b010:(OP==6'b000000&&Funct==6'b000000)? 3'b100:(OP==6'b000100)? 3'b110:(OP==6'b000101)? 3'b110:Half_ctr;
	//assign ALU_ctr=0:Half_ctr;   3'b011:NOR;
	
	//bne/beq control
	assign BranchSelect=(OP==`bgez&&Instruction[20:16]==5'd0)? (alu1_R==32'd1):(OP==`blez)? (alu1_R==32'd1)|(RF_rdata1==0):(OP==`bgez&&Instruction[20:16]==5'd1)? (alu1_R==32'd0):(OP==6'b000100)? alu1_Zero:~alu1_Zero;
// whether it's ok to use (==) to represent 1/0 is not sure
	
	//reg: read and write
	//wire necarryout;
	//assign necarryout=alu1_Carryout;
	assign RF_raddr1 = Instruction[25:21];
	assign RF_raddr2 = Instruction[20:16];
	assign RF_waddr = (OP==`jal)? 31:(RegDst == 1)?Instruction[15:11]:Instruction[20:16];
	assign RF_wen=(OP==6'b000000&&Funct==6'b001011&&RF_rdata2==32'd0)?1'b0:(OP==6'b000000&&Funct==6'b001010&&RF_rdata2!=32'd0)?1'b0:(RF_waddr==5'd0)?1'b0:RegWrite;//not yet done
	assign RF_wdata=(OP==6'b000000&&Funct==6'b000110)?data_srl:(OP==6'b000000&&Funct==6'b000010)? data_srl:(OP==6'b000000&&Funct==6'b000111)?data_sra:(OP==6'b000000&&Funct==6'b000011)? data_sra:(OP==6'b000000&&Funct==6'b101011)?{31'd0,alu1_CarryOut}: (OP==6'b000000&&Funct==6'b000100)? data_sllv:(OP==`lwl)? byte_data_l:(OP==`lwr)? byte_data_r:(OP==`lbu||OP==`lhu)? byte_data_2:(OP==`lb||OP==`lh)? byte_data_1:(OP==6'b000000&&Funct==6'b001001)? (PC+32'd8):(OP==`jal)? (PC+32'd8):(OP==`sltiu)? {31'd0,alu1_CarryOut}:(MemtoReg==1'b1)? Read_data:(OP==6'b000000&&Funct==6'b001011)?((RF_rdata2!=32'd0)?RF_rdata1:32'd0):(OP==6'b000000&&Funct==6'b001010&&RF_rdata2==32'd0)?RF_rdata1:alu1_R;// not done //LB sltu notsure
	//lb process, deal with byte
	assign sa=(Funct==6'b000111||Funct==6'b000100||Funct==6'b000110)?RF_rdata1[4:0]:Instruction[10:6];
	assign data_sllv=RF_rdata2 << sa;
	assign data_sra=(RF_rdata2[31]==1'b0)? (RF_rdata2>>sa):~((~RF_rdata2)>>sa);
	/*assign data_srav=(RF_rdata2[31]==1'b0)? (RF_rdata2>>sa):~((~RF_rdata2)>>sa);*/
	assign data_srl=RF_rdata2>>sa;
	//assign data_srlv=RF_rdata2>>sa;
	
		


	assign byte=Address_b[1:0];
	assign byte_data_1=(OP==`lb)? ((byte==2'b00)? {{24{Read_data[7]}},Read_data[7:0]}:(byte==2'b01)? {{24{Read_data[15]}},Read_data[15:8]}:(byte==2'b10)?{{24{Read_data[23]}},Read_data[23:16]}:{{24{Read_data[31]}},Read_data[31:24]}):((byte==2'b00)? {{16{Read_data[15]}},Read_data[15:0]}:(byte==2'b01)? {{16{Read_data[23]}},Read_data[23:8]}:{{16{Read_data[31]}},Read_data[31:16]});// signed one
	
	assign byte_data_2=(OP==`lbu)? ((byte==2'b00)? {{24{1'b0}},Read_data[7:0]}:(byte==2'b01)? {{24{1'b0}},Read_data[15:8]}:(byte==2'b10)?{{24{1'b0}},Read_data[23:16]}:{{24{1'b0}},Read_data[31:24]}):((byte==2'b00)? {{16{1'b0}},Read_data[15:0]}:(byte==2'b01)? {{16{1'b0}},Read_data[23:8]}:{{16{1'b0}},Read_data[31:16]});
	//	unsigned one    half duiqi?

	assign byte_data_l=(byte==2'b00)?{Read_data[7:0],RF_rdata2[23:0]}:(byte==2'b01)?{Read_data[15:0],RF_rdata2[15:0]}:(byte==2'b10)?{Read_data[23:0],RF_rdata2[7:0]}:Read_data;
	
	assign byte_data_r=(byte==2'b00)?Read_data:(byte==2'b01)?{RF_rdata2[31:24],Read_data[31:8]}:(byte==2'b10)? {RF_rdata2[31:16],Read_data[31:16]}:{RF_rdata2[31:8],Read_data[31:24]};

	assign Sign_extend=(OP==`sltiu||OP==`ori||OP==`xori||OP==`andi)? {16'd0,Instruction[15:0]}: (OP==`lui)? {Instruction[15:0],16'd0}:{{16{Instruction[15]}}, Instruction[15:0]};
	assign alu1_A=(OP==6'b000000&&Funct==6'b000000)?{27'd0,Instruction[10:6]}:RF_rdata1;
   	assign alu1_B=(OP==`bgez||OP==`blez)? 32'd0:ALUSrc?(Sign_extend):RF_rdata2;//&&BranchSelect==1'b1

	assign PC_next=(Branch==1'b1&&BranchSelect==1'b1)?PC+32'd4+(Sign_extend<<2):PC+32'd4;
	assign Address_b=alu1_R;
	assign Address_a=Address_b-byte;
	assign Address=(OP==`lwl||OP==`lwr||OP==`swl||OP==`swr||OP==`sb||OP==`sh||OP==`lb||OP== `lh||OP==`lbu||OP==`lhu)?Address_a:Address_b;
	//assign MemWrite=MemWrite;
	assign Write_data=(OP==`swl)?((byte==2'b00)?{24'b0,RF_rdata2[31:24]}:(byte==2'b01)?{16'b0, RF_rdata2[31:16]}:(byte==2'b10)?{8'b0,RF_rdata2[31:8]}:RF_rdata2):
	(OP==`swr)?((byte==2'b00)?RF_rdata2:(byte==2'b01)?{RF_rdata2[23:0],8'b0}:(byte==2'b10)?{RF_rdata2[15:0],16'b0}:{RF_rdata2[7:0],24'b0}):	(OP==`sb)?((byte==2'b00)?{24'b0, RF_rdata2[7:0]}:(byte==2'b01)?{16'b0,RF_rdata2[7:0],8'b0}:(byte==2'b10)?{8'b0,RF_rdata2[7:0],16'b0}:{RF_rdata2[7:0], 24'b0}):
	(OP==`sh)?((byte==2'b11||byte==2'b10)?{RF_rdata2[15:0],16'b0}:{16'b0, RF_rdata2}):RF_rdata2;
	assign PC_jump={PC_next[31:28],Instruction[25:0],2'b00};
	assign PC_final=(OP==6'b000000&&Funct==6'b001001)? RF_rdata1:(Jum==1'b1)? (PC_jump):(OP==6'b000000 && Funct==6'b001000)? (alu1_R):(PC_next);
	//assign PC_final=32'd122;

	alu alu(.A(alu1_A), .B(alu1_B), .ALUop(ALU_ctr), .Overflow(alu1_Overflow), .CarryOut(alu1_CarryOut), .Zero(alu1_Zero), .Result(alu1_R));
	reg_file reg_file(.rst(rst), .clk(clk), .waddr(RF_waddr), .raddr1(RF_raddr1), .raddr2(RF_raddr2), .wen(RF_wen), .wdata(RF_wdata), .rdata1(RF_rdata1), .rdata2(RF_rdata2));


endmodule	










