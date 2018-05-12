`include "head.h"
module ID_stage(
    input  wire        clk,
    input  wire        resetn,
	input  wire        ID_stall,
    input  wire [31:0] IF_inst,
	input  wire [31:0] IF_pc,
    output wire [4:0]  ID_reg_raddr1,
    input  wire [31:0] ID_reg_rdata1,
    output wire [4:0]  ID_reg_raddr2,
    input  wire [31:0] ID_reg_rdata2,

	output wire        ID_br_taken,    //1: branch taken,go to the branch target
    output wire        ID_br_type,     //1: inst is branch type
    output wire        ID_j_type,      //1: inst is jump type
    output wire        ID_jr_type,     //1: inst is jump register type
    output wire [15:0] ID_br_index,    //offset for type "br"
    output wire [25:0] ID_j_index,     //instr_index for type "j"
    output wire [31:0] ID_jr_index,    //target for type "jr"

	input  wire [2:0]  ID_vsrc1_for,    //000: stay   001: EXE_for   010: MEM_for  011: WB_for 100: EXE_reg1_for 
	input  wire [1:0]  ID_vsrc2_for,	
	input  wire [31:0] HI,
	input  wire [31:0] LO,
	input  wire [31:0] EXE_for,
	input  wire [31:0] MEM_for,
	input  wire [31:0] WB_for,
	input  wire [31:0] EXE_reg1_for,
	

    output wire [31:0] ID_pc_out,
    output wire [31:0] ID_inst_out,          //instr code @decode stage
		
	output wire [4:0]  ID_src1_out,            
	output wire [4:0]  ID_src2_out,
    output wire [4:0]  ID_dest_out,         //reg num of dest operand, zero if no dest
	output wire        ID_memtoreg_out,      //1: mem   0:result
	output wire [5:0]  ID_ALUop_out,
    output wire [31:0] ID_vsrc1_out,        //value of source operand 1
    output wire [31:0] ID_vsrc2_out,        //value of source operand 2
	output wire [31:0] ID_reg_rt_out,
	output wire        ID_HI_we_out,
	output wire        ID_LO_we_out,
	output reg  [31:0] ID_inst,
	output wire [4:0]  ID_src1,           
	output wire [4:0]  ID_src2
);


	wire        ID_s_type;      //1: inst is store type
    wire        ID_l_type;      //1: inst is load type
	wire        ID_mo_type;     //1: inst is move data type

	wire [31:0] ID_vsrc1_temp;
	wire [31:0] ID_vsrc2_temp;

	
	
	wire [1:0]  ID_vsrc1_op;     //00: reg_rdata1   01: PC       10: sa 
	wire [1:0]  ID_vsrc2_op;     //00: reg_rdata2   01: sign-16  10: zero-16   11: 8
	reg  [31:0] ID_pc;

    wire [4:0]  ID_dest;         //reg num of dest operand, zero if no dest
	wire        ID_memtoreg;      //1: mem   0:result
	wire [5:0]  ID_ALUop;
    wire [31:0] ID_vsrc1;        //value of source operand 1
    wire [31:0] ID_vsrc2;        //value of source operand 2
	wire [31:0] ID_reg_rt;
	wire        ID_HI_we;
	wire        ID_LO_we;
	
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			ID_pc   <= 32'hbfc00000;
			ID_inst <= 32'h00000000;
		end
		else if (ID_stall) begin
			ID_pc   <= ID_pc;
			ID_inst <= ID_inst;
		end 
		else begin
			ID_pc   <= IF_pc;
			ID_inst <= IF_inst;
		end
	end

	
	assign ID_reg_raddr1 = ID_src1;
	assign ID_reg_raddr2 = ID_src2;
	
	assign ID_vsrc1_temp = (ID_vsrc1_for == 3'b000) ? (
						   (`ID_func == `MFHI && ID_inst[5:0] == `MFHI_2) ? HI :
						   (`ID_func == `MFLO && ID_inst[5:0] == `MFLO_2) ? LO :
							ID_reg_rdata1
						   ) :
						   (ID_vsrc1_for == 3'b001) ? EXE_for :
					       (ID_vsrc1_for == 3'b010) ? MEM_for :
					       (ID_vsrc1_for == 3'b011) ? WB_for :
					       EXE_reg1_for;
	
	assign ID_vsrc2_temp = (ID_vsrc2_for == 2'b00) ? ID_reg_rdata2 :
					       (ID_vsrc2_for == 2'b01) ? EXE_for :
					       (ID_vsrc2_for == 2'b10) ? MEM_for :
					        WB_for; 

	assign ID_l_type = (`ID_func == `LB || `ID_func == `LBU || 
						`ID_func == `LH || `ID_func == `LHU || 
						`ID_func == `LW || `ID_func == `LWL || 
						`ID_func == `LWR) ? 1'b1 : 1'b0;
						
	assign ID_s_type = (`ID_func == `SB || `ID_func == `SH ||
						`ID_func == `SW || `ID_func == `SWL||
						`ID_func == `SWR) ? 1'b1 : 1'b0;
						
	assign ID_br_type = (`ID_func == `BEQ   || `ID_func== `BNE ||
						 `ID_func == `BGEZ  && ID_inst[20:16] == `BGEZ_2||
						 `ID_func == `BGTZ  || `ID_func== `BLEZ|| 
						 `ID_func == `BLTZ  && ID_inst[20:16] == `BLTZ_2||
						 `ID_func == `BGEZAL&& ID_inst[20:16] == `BGEZAL_2||
						 `ID_func == `BLTZAL&& ID_inst[20:16] == `BLTZAL_2) ? 1'b1 : 1'b0;
						 
	assign ID_j_type = (`ID_func == `J || `ID_func == `JAL) ? 1'b1 : 1'b0;
	
	assign ID_jr_type = (`ID_func == `JR   && ID_inst[5:0] == `JR_2 || 
						 `ID_func == `JALR && ID_inst[5:0] == `JALR_2) ? 1'b1 : 1'b0;
						 
						 
	assign ID_mo_type = (`ID_func == `MFHI && ID_inst[5:0] == `MFHI_2 ||
					     `ID_func == `MFLO && ID_inst[5:0] == `MFLO_2 ||
						 `ID_func == `MTHI && ID_inst[5:0] == `MTHI_2 ||
					     `ID_func == `MTLO && ID_inst[5:0] == `MTLO_2) ? 1'b1 : 1'b0;
						 
	assign ID_jr_index = ID_vsrc1_temp;
	assign ID_j_index = ID_inst[25:0];
	assign ID_br_index = ID_inst[15:0];

	
	assign ID_src1 = (ID_j_type) ? 5'b00000 : ID_inst[25:21];
				  
	assign ID_src2 = (`ID_func == `LWL || `ID_func == `LWR) ? ID_inst[20:16] :
					 (ID_j_type || ID_l_type) ? 5'b00000 :
					 (`ID_func == 6'b000001) ? 5'b00000 : //represent BGEZ BLTZ BGEZAL BLTZAL
					 (`ID_func == `ANDI || `ID_func == `LUI  ||
    				  `ID_func == `ORI  || `ID_func == `XORI || 
					  `ID_func == `ADDI || `ID_func == `ADDIU||
					  `ID_func == `SLTI || `ID_func == `SLTIU) ? 5'b00000 : 
					  ID_inst[20:16];
					  
	assign ID_dest = (`ID_func == 6'b000000) ? ID_inst[15:11] :
				 	 (`ID_func == `JAL || `ID_func == `BGEZAL && ID_inst[20:16] == `BGEZAL_2 || 
				 	  `ID_func == `BLTZAL && ID_inst[20:16] == `BLTZAL_2) ? 5'b11111 :
				 	 (`ID_func == `ANDI || `ID_func == `LUI  ||
    				  `ID_func == `ORI  || `ID_func == `XORI || 
					  `ID_func == `ADDI || `ID_func == `ADDIU||
					  `ID_func == `SLTI || `ID_func == `SLTIU) ? ID_inst[20:16] :
					 (ID_l_type) ? ID_inst[20:16] : 5'b00000;
	
	assign ID_ALUop = (ID_l_type || ID_s_type || ID_mo_type || ID_j_type || ID_jr_type) ? 6'b001001 :
					  (`ID_func == 6'b000000) ? ID_inst[5:0] : 
					  (`ID_func == `BGEZAL && ID_inst[20:16] == `BGEZAL_2||
					   `ID_func == `BLTZAL && ID_inst[20:16] == `BLTZAL_2) ? 6'b001001 :
					  (ID_br_type) ? 6'b111111 :     //represent no action
					   `ID_func;
					   
	assign ID_reg_rt = ID_vsrc2_temp;
	
//	wire        ID_vsrc1_op;     //00 : reg_rdata1   01 : PC       10: sa 
//	wire        ID_vsrc2_op;     //00 : reg_rdata2   01 : sign-16  10 : zero-16   11 : 8
	
	assign ID_vsrc1_op = (`ID_func == `BGEZAL && ID_inst[20:16] == `BGEZAL_2 ||
						  `ID_func == `BLTZAL && ID_inst[20:16] == `BLTZAL_2 || 
						  `ID_func == `JALR && ID_inst[5:0] == `JALR_2||
						  `ID_func == `JAL) ? 2'b01 :
                         (`ID_func == 6'b000000 && (ID_inst[5:0] == `SRA_2 || 
						   ID_inst[5:0] == `SRL_2 || ID_inst[5:0] == `SLL_2)) ? 2'b10 :
						  2'b00;
						  
	assign ID_vsrc2_op = (ID_l_type || ID_s_type || `ID_func == `ADDI ||
						  `ID_func == `ADDIU || `ID_func == `SLTI || `ID_func == `SLTIU) ? 2'b01 : 
						 (`ID_func == `ANDI || `ID_func == `ORI || 
						  `ID_func == `LUI || `ID_func == `XORI) ? 2'b10 :
						 (`ID_func == `BGEZAL && ID_inst[20:16] == `BGEZAL_2 ||
						  `ID_func == `BLTZAL && ID_inst[20:16] == `BLTZAL_2 || 
						  `ID_func == `JALR && ID_inst[5:0] == `JALR_2||
						  `ID_func == `JAL) ? 2'b11 : 
						  2'b00;
	
	assign ID_vsrc1 = (ID_vsrc1_op == 2'b00) ? ID_vsrc1_temp :
					  (ID_vsrc1_op == 2'b01) ? ID_pc :
					  (ID_vsrc1_op == 2'b10) ? {27'd0,ID_inst[10:6]} : 32'd0;
					  
	assign ID_vsrc2 = (ID_vsrc2_op == 2'b00) ? ID_vsrc2_temp :
					  (ID_vsrc2_op == 2'b01) ? {{16{ID_inst[15]}},ID_inst[15:0]} :
					  (ID_vsrc2_op == 2'b10) ? {16'd0,ID_inst[15:0]} :
					   32'd8;
					   
//  wire        ID_memtoreg,      //1: mem   0:result
	assign ID_memtoreg = (ID_l_type) ? 1'b1 : 1'b0;
	
	assign ID_br_taken = (`ID_func == `BEQ  &&  ID_vsrc1_temp == ID_vsrc2_temp ||
						  `ID_func == `BNE  &&  ID_vsrc1_temp != ID_vsrc2_temp ||
						  `ID_func == `BGTZ &&  ID_vsrc1_temp[31] == 1'b0 && ID_vsrc1_temp != 32'd0 ||
						  `ID_func == `BLEZ && (ID_vsrc1_temp[31] == 1'b1 || ID_vsrc1_temp == 32'd0)||
						  `ID_func == `BGEZ && (ID_inst[20:16] == `BGEZ_2 || ID_inst[20:16] == `BGEZAL_2) && ID_vsrc1_temp[31] == 1'b0||
						  `ID_func == `BLTZ && (ID_inst[20:16] == `BLTZ_2 || ID_inst[20:16] == `BLTZAL_2) && ID_vsrc1_temp[31] == 1'b1) ? 1'b1 : 1'b0;					  					  

	assign ID_HI_we = (`ID_func == `MTHI && ID_inst[5:0] == `MTHI_2) ? 1'b1 : 1'b0;		
	assign ID_LO_we = (`ID_func == `MTLO && ID_inst[5:0] == `MTLO_2) ? 1'b1 : 1'b0;	

						
	assign ID_pc_out       = (ID_stall) ? 32'hbfc00000 : ID_pc;
    assign ID_inst_out     = (ID_stall) ? 32'h00000000 : ID_inst;          //instr code @decode stage
	assign ID_src1_out     = (ID_stall) ? 5'd0 : 
	                         (ID_br_type || ID_jr_type) ? 5'd0 :
	                         ID_src1;            
	assign ID_src2_out     = (ID_stall) ? 5'd0 : ID_src2; 
    assign ID_dest_out     = (ID_stall) ? 5'd0 : ID_dest;         //reg num of dest operand, zero if no dest
	assign ID_memtoreg_out = (ID_stall) ? 1'b0 : ID_memtoreg;      //1: mem   0:result
    assign ID_ALUop_out    = (ID_stall) ? 6'b111111 : ID_ALUop;
    assign ID_vsrc1_out    = (ID_stall) ? 32'd0 : ID_vsrc1;        //value of source operand 1
    assign ID_vsrc2_out    = (ID_stall) ? 32'd0 : ID_vsrc2;        //value of source operand 2
	assign ID_reg_rt_out   = (ID_stall) ? 32'd0 : ID_reg_rt;
	assign ID_HI_we_out    = (ID_stall) ? 1'b0 : ID_HI_we;
	assign ID_LO_we_out    = (ID_stall) ? 1'b0 : ID_LO_we;	
endmodule 