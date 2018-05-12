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

	input  wire [1:0]  ID_vsrc1_for,    //00: stay   01: EXE_reg1_for   10: MEM_for  11: WB_for 100:  
	input  wire [1:0]  ID_vsrc2_for,	
	input  wire [31:0] HI,
	input  wire [31:0] LO,
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
	output wire [4:0]  ID_src2,
	
	output wire        ID_eret_out,
	output wire        ID_syscall_out,
	output wire        ID_break_out,
	output wire        ID_no_inst_out,
	input  wire [31:0] CP0_STATUS,
	input  wire [31:0] CP0_CAUSE,
	input  wire [31:0] CP0_COMPARE,
	input  wire [31:0] CP0_COUNT,
	input  wire [31:0] CP0_EPC,
	input  wire [31:0] CP0_BADVADDR,
	input  wire [31:0] CP0_INDEX,
	input  wire [31:0] CP0_ENTRYHI,
	input  wire [31:0] CP0_PAGEMASK,
	input  wire [31:0] CP0_ENTRYLO0,
	input  wire [31:0] CP0_ENTRYLO1,
	input  wire        ID_clear,
	input  wire        IF_BD,
	input  wire        IF_inst_addr_err,
	input  wire        IF_TLBrefill,
	input  wire        IF_TLBinvalid,
	output wire        ID_delay_slot,
	output wire        ID_BD_out,
	output wire        ID_inst_addr_err_out,
	input  wire        IF_interrupt,
	output wire        ID_interrupt_out,
	output wire        ID_TLBinvalid_out,
	output wire        ID_TLBrefill_out
);

	wire        ID_eret;
	reg         ID_BD;
	reg         ID_inst_addr_err;
	reg         ID_TLBrefill;
	reg         ID_TLBinvalid;
	reg         ID_interrupt;
	wire        ID_syscall;
	wire        ID_break;  
	wire        ID_no_inst;
	
	reg  [31:0] ID_pc;
	wire        ID_s_type;      //1: inst is store type
    wire        ID_l_type;      //1: inst is load type
	wire        ID_mo_type;     //1: inst is move data type
	wire        ID_arithmetic_type;
	wire        ID_logic_type;
	wire        ID_shift_type;
    wire        ID_MTC0;
    wire        ID_MFC0;
	wire        ID_TLBWI;
	wire        ID_TLBR;
	wire        ID_TLBP;
	wire [31:0] ID_vsrc1_temp;
	wire [31:0] ID_vsrc2_temp;

	
	
	wire [1:0]  ID_vsrc1_op;     //00: reg_rdata1   01: PC       10: sa 
	wire [1:0]  ID_vsrc2_op;     //00: reg_rdata2   01: sign-16  10: zero-16   11: 8


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
		if (!resetn || ID_clear) begin
			ID_pc   <= 32'hbfc00000;
			ID_inst <= 32'h00000000;
			ID_BD   <= 1'b0;
			ID_inst_addr_err <= 1'b0;
			ID_interrupt     <= 1'b0;
			ID_TLBrefill     <= 1'b0;
			ID_TLBinvalid    <= 1'b0;
		end
		else if (ID_stall) begin
			ID_pc   <= ID_pc;
			ID_inst <= ID_inst;
			ID_BD   <= ID_BD;
			ID_inst_addr_err <= ID_inst_addr_err;
			ID_interrupt     <= ID_interrupt;
			ID_TLBrefill     <= ID_TLBrefill;
			ID_TLBinvalid    <= ID_TLBinvalid;
		end 
		else if (ID_eret) begin
			ID_pc   <= 32'hbfc00000;
			ID_inst <= 32'h00000000;
			ID_BD   <= 1'b0;
			ID_inst_addr_err <= 1'b0;
			ID_interrupt     <= 1'b0;
			ID_TLBrefill     <= 1'b0;
			ID_TLBinvalid    <= 1'b0;
		end
		else begin
			ID_pc   <= IF_pc;
			ID_inst <= IF_inst;
			ID_BD   <= IF_BD;
			ID_inst_addr_err <= IF_inst_addr_err;
			ID_interrupt     <= IF_interrupt;
			ID_TLBrefill     <= IF_TLBrefill;
			ID_TLBinvalid    <= IF_TLBinvalid;
		end
	end

	
	assign ID_reg_raddr1 = ID_src1;
	assign ID_reg_raddr2 = ID_src2;
	
	assign ID_vsrc1_temp = (ID_vsrc1_for == 2'b00) ? (
	                       (ID_MFC0) ? (
						   (ID_inst[15:11] == 5'd0 ) ? CP0_INDEX :
	                       (ID_inst[15:11] == 5'd2 ) ? CP0_ENTRYLO0 :
	                       (ID_inst[15:11] == 5'd3 ) ? CP0_ENTRYLO1 :
	                       (ID_inst[15:11] == 5'd5 ) ? CP0_PAGEMASK :
	                       (ID_inst[15:11] == 5'd8 ) ? CP0_BADVADDR :
	                       (ID_inst[15:11] == 5'd9 ) ? CP0_COUNT :
						   (ID_inst[15:11] == 5'd10) ? CP0_ENTRYHI :
	                       (ID_inst[15:11] == 5'd11) ? CP0_COMPARE :
	                       (ID_inst[15:11] == 5'd12) ? CP0_STATUS :
	                       (ID_inst[15:11] == 5'd13) ? CP0_CAUSE :
	                       (ID_inst[15:11] == 5'd14) ? CP0_EPC : 32'd0) :
						   (`ID_func == `MFHI && ID_inst[5:0] == `MFHI_2) ? HI :
						   (`ID_func == `MFLO && ID_inst[5:0] == `MFLO_2) ? LO :
							ID_reg_rdata1
						   ) :
						   (ID_vsrc1_for == 2'b01) ? EXE_reg1_for :
					       (ID_vsrc1_for == 2'b10) ? MEM_for :
					        WB_for;
	
	assign ID_vsrc2_temp = (ID_vsrc2_for == 2'b00) ? ID_reg_rdata2 :
					       (ID_vsrc2_for == 2'b10) ? MEM_for :
					        WB_for; 

    assign ID_eret = (`ID_func == `ERET && ID_inst[25] == 1'b1 && ID_inst[24:6] == 19'd0 && ID_inst[5:0] == `ERET_2) ? 1'b1 : 1'b0;
    assign ID_break = (`ID_func == `BREAK && ID_inst[5:0] == `BREAK_2) ? 1'b1 : 1'b0;
    assign ID_syscall = (`ID_func == `SYSCALL && ID_inst[5:0] == `SYSCALL_2) ? 1'b1 : 1'b0;
    
    assign ID_MFC0 = `ID_func == `MFC0 && ID_inst[25:21] == `MFC0_2 && ID_inst[10:3] == 8'd0;
    assign ID_MTC0 = `ID_func == `MTC0 && ID_inst[25:21] == `MTC0_2 && ID_inst[10:3] == 8'd0;
    
	assign ID_TLBWI = ID_inst == 32'b01000010000000000000000000000010;
	assign ID_TLBP  = ID_inst == 32'b01000010000000000000000000001000;
	assign ID_TLBR  = ID_inst == 32'b01000010000000000000000000000001;
	
	
	assign ID_l_type = (`ID_func == `LB || `ID_func == `LBU || 
						`ID_func == `LH || `ID_func == `LHU || 
						`ID_func == `LW || `ID_func == `LWL || 
						`ID_func == `LWR) ? 1'b1 : 1'b0;
						
	assign ID_s_type = (`ID_func == `SB || `ID_func == `SH ||
						`ID_func == `SW || `ID_func == `SWL||
						`ID_func == `SWR) ? 1'b1 : 1'b0;
						
	assign ID_br_type = (`ID_func == `BEQ   || `ID_func== `BNE ||
						 `ID_func == `BGEZ  && ID_inst[20:16] == `BGEZ_2||
						 `ID_func == `BGTZ  && ID_inst[20:16] == 5'd0 || 
						 `ID_func == `BLEZ  && ID_inst[20:16] == 5'd0 || 
						 `ID_func == `BLTZ  && ID_inst[20:16] == `BLTZ_2||
						 `ID_func == `BGEZAL&& ID_inst[20:16] == `BGEZAL_2||
						 `ID_func == `BLTZAL&& ID_inst[20:16] == `BLTZAL_2) ? 1'b1 : 1'b0;
						 
	assign ID_j_type = (`ID_func == `J || `ID_func == `JAL) ? 1'b1 : 1'b0;
	
	assign ID_jr_type = (`ID_func == `JR   && ID_inst[20:6] == 15'd0 && ID_inst[5:0] == `JR_2 || 
						 `ID_func == `JALR && ID_inst[20:16] == 5'd0 && ID_inst[10:6] == 5'd0 && ID_inst[5:0] == `JALR_2) ? 1'b1 : 1'b0;
						 
	assign ID_delay_slot = (ID_br_type || ID_j_type || ID_jr_type) ? 1'b1 : 1'b0;
						 
	assign ID_mo_type = (`ID_func == `MFHI && ID_inst[25:16] == 10'd0 && ID_inst[10:6] == 5'd0 && ID_inst[5:0] == `MFHI_2 ||
					     `ID_func == `MFLO && ID_inst[25:16] == 10'd0 && ID_inst[10:6] == 5'd0 && ID_inst[5:0] == `MFLO_2 ||
						 `ID_func == `MTHI && ID_inst[20:6] == 15'd0 && ID_inst[5:0] == `MTHI_2 ||
					     `ID_func == `MTLO && ID_inst[20:6] == 15'd0 && ID_inst[5:0] == `MTLO_2) ? 1'b1 : 1'b0;
			
    assign ID_arithmetic_type = (`ID_func == 6'b000000 && (
                                  ID_inst[5:0] == `ADD_2  && ID_inst[10:6] == 5'd0 ||
                                  ID_inst[5:0] == `ADDU_2 && ID_inst[10:6] == 5'd0 ||
                                  ID_inst[5:0] == `SUB_2  && ID_inst[10:6] == 5'd0 ||
                                  ID_inst[5:0] == `SUBU_2 && ID_inst[10:6] == 5'd0 ||
                                  ID_inst[5:0] == `SLT_2  && ID_inst[10:6] == 5'd0 || 
                                  ID_inst[5:0] == `SLTU_2 && ID_inst[10:6] == 5'd0 ||
                                  ID_inst[5:0] == `DIV_2  && ID_inst[15:6] == 10'd0 || 
                                  ID_inst[5:0] == `DIVU_2 && ID_inst[15:6] == 10'd0 ||
                                  ID_inst[5:0] == `MULT_2 && ID_inst[15:6] == 10'd0 || 
                                  ID_inst[5:0] == `MULTU_2&& ID_inst[15:6] == 10'd0) 
                                || `ID_func == `ADDI || `ID_func == `ADDIU || `ID_func == `SLTI || `ID_func == `SLTIU) ? 1'b1 : 1'b0;
    
    assign ID_logic_type = (`ID_func == 6'b000000 && (
                             ID_inst[5:0] == `AND_2 && ID_inst[10:6] == 5'd0 || 
                             ID_inst[5:0] == `NOR_2 && ID_inst[10:6] == 5'd0 ||
                             ID_inst[5:0] == `OR_2  && ID_inst[10:6] == 5'd0 ||
                             ID_inst[5:0] == `XOR_2 && ID_inst[10:6] == 5'd0) 
                           || `ID_func == `ANDI || `ID_func == `LUI && ID_inst[25:21] == 5'd0 || `ID_func == `ORI || `ID_func == `XORI) ? 1'b1 : 1'b0;
    
    assign ID_shift_type = (`ID_func == 6'b000000 && (
                            ID_inst[5:0] == `SLLV_2 && ID_inst[10:6] == 5'd0 ||
                            ID_inst[5:0] == `SLL_2  && ID_inst[25:21] == 5'd0 ||
                            ID_inst[5:0] == `SRAV_2 && ID_inst[10:6] == 5'd0 || 
                            ID_inst[5:0] == `SRA_2  && ID_inst[25:21] == 5'd0 || 
                            ID_inst[5:0] == `SRLV_2 && ID_inst[10:6] == 5'd0 || 
                            ID_inst[5:0] == `SRL_2  && ID_inst[25:21] == 5'd0)) ? 1'b1 : 1'b0;
                            
    assign ID_no_inst = (ID_j_type || ID_jr_type || ID_br_type || ID_mo_type || ID_l_type || ID_s_type || ID_arithmetic_type || 
                         ID_logic_type || ID_shift_type || ID_syscall || ID_eret || ID_break || ID_MFC0 || ID_MTC0 || ID_TLBWI || ID_TLBR || ID_TLBP) ? 1'b0 : 1'b1 ;


	assign ID_jr_index = ID_vsrc1_temp;
	assign ID_j_index = ID_inst[25:0];
	assign ID_br_index = ID_inst[15:0];

	
	assign ID_src1 = (ID_j_type || ID_eret || ID_break || ID_syscall ||
	                  ID_MFC0 || ID_MTC0 || ID_TLBWI || ID_TLBR || ID_TLBP) ? 5'b00000 : ID_inst[25:21];
				  
	assign ID_src2 = (`ID_func == `LWL || `ID_func == `LWR) ? ID_inst[20:16] :
					 (ID_j_type || ID_l_type) ? 5'b00000 :
					 (`ID_func == 6'b000001) ? 5'b00000 : //represent BGEZ BLTZ BGEZAL BLTZAL
					 (`ID_func == `ANDI || `ID_func == `LUI  ||
    				  `ID_func == `ORI  || `ID_func == `XORI || 
					  `ID_func == `ADDI || `ID_func == `ADDIU||
					  `ID_func == `SLTI || `ID_func == `SLTIU||
					  ID_MFC0) ? 5'b00000 : 
					  ID_inst[20:16];
					  
	assign ID_dest = (ID_break || ID_syscall) ? 5'd0 :
	                 (`ID_func == 6'b000000) ? ID_inst[15:11] :
				 	 (`ID_func == `JAL || `ID_func == `BGEZAL && ID_inst[20:16] == `BGEZAL_2 || 
				 	  `ID_func == `BLTZAL && ID_inst[20:16] == `BLTZAL_2) ? 5'b11111 :
				 	 (`ID_func == `ANDI || `ID_func == `LUI  ||
    				  `ID_func == `ORI  || `ID_func == `XORI || 
					  `ID_func == `ADDI || `ID_func == `ADDIU||
					  `ID_func == `SLTI || `ID_func == `SLTIU || 
					  ID_MFC0) ? ID_inst[20:16] :
					 (ID_l_type) ? ID_inst[20:16] : 5'b00000;
	
	assign ID_ALUop = (ID_no_inst) ? 6'b111111 :
	                  (ID_l_type || ID_s_type || ID_mo_type || ID_j_type ||
	                   ID_jr_type || ID_MFC0 || ID_MTC0) ? 6'b001001 :
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

						
	assign ID_pc_out       = (ID_stall || ID_clear) ? 32'hbfc00000 : ID_pc;
    assign ID_inst_out     = (ID_stall || ID_clear) ? 32'h00000000 : ID_inst;          //instr code @decode stage
	assign ID_src1_out     = (ID_stall || ID_clear) ? 5'd0 : 
	                         (ID_br_type || ID_jr_type) ? 5'd0 :
	                         ID_src1;            
	assign ID_src2_out     = (ID_stall || ID_clear) ? 5'd0 : ID_src2; 
    assign ID_dest_out     = (ID_stall || ID_clear) ? 5'd0 : ID_dest;         //reg num of dest operand, zero if no dest
	assign ID_memtoreg_out = (ID_stall || ID_clear) ? 1'b0 : ID_memtoreg;      //1: mem   0:result
    assign ID_ALUop_out    = (ID_stall || ID_clear) ? 6'b111111 : ID_ALUop;
    assign ID_vsrc1_out    = (ID_stall || ID_clear) ? 32'd0 : ID_vsrc1;        //value of source operand 1
    assign ID_vsrc2_out    = (ID_stall || ID_clear) ? 32'd0 : ID_vsrc2;        //value of source operand 2
	assign ID_reg_rt_out   = (ID_stall || ID_clear) ? 32'd0 : ID_reg_rt;
	assign ID_HI_we_out    = (ID_stall || ID_clear) ? 1'b0 : ID_HI_we;
	assign ID_LO_we_out    = (ID_stall || ID_clear) ? 1'b0 : ID_LO_we;	
	assign ID_BD_out       = (ID_stall || ID_clear) ? 1'b0 : ID_BD;
	assign ID_inst_addr_err_out = (ID_stall || ID_clear) ? 1'b0 : ID_inst_addr_err;	
	assign ID_interrupt_out = (ID_stall || ID_clear) ? 1'b0 : ID_interrupt;
	//assign ID_eret_out     = (ID_stall || ID_clear) ? 1'b0 : ID_eret;
	assign ID_eret_out = ID_eret;
	assign ID_syscall_out  = (ID_stall || ID_clear) ? 1'b0 : ID_syscall;
	assign ID_break_out    = (ID_stall || ID_clear) ? 1'b0 : ID_break;
	assign ID_no_inst_out  = (ID_stall || ID_clear) ? 1'b0 : ID_no_inst;
	assign ID_TLBinvalid_out = (ID_stall || ID_clear) ? 1'b0 : ID_TLBinvalid;
	assign ID_TLBrefill_out = (ID_stall || ID_clear) ? 1'b0 : ID_TLBrefill;
endmodule 