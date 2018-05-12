`include "head.h"
module stall(

	input  wire [4:0]  WB_reg_dst,
	
	input  wire [4:0]  MEM_src2,
	input  wire [4:0]  MEM_reg_dst,
	input  wire [31:0] MEM_inst,
	
	input  wire [4:0]  EXE_src1,
	input  wire [4:0]  EXE_src2,
	input  wire [4:0]  EXE_reg_dst,
	input  wire [31:0] EXE_inst,
	
	input  wire [4:0]  ID_src1,
	input  wire [4:0]  ID_src2,
	input  wire [31:0] ID_inst,
	input  wire        EXE_mul_div_validout,
	
	output wire        IF_stall,
	output wire        ID_stall,
	output wire        EXE_stall,
	output wire [1:0]  ID_vsrc1_for,    //00: stay   01: EXE_reg1_for   10: MEM_for  11: WB_for 
	output wire [1:0]  ID_vsrc2_for,
	output wire [1:0]  EXE_srcA_for,    //00: stay    01: MEM_for    10: WB_for
	output wire [1:0]  EXE_srcB_for,
	output wire [1:0]  EXE_reg_rt_for,
	output wire        MEM_reg_rt_for   //0:  stay    1: WB_for 
);
	wire ID_br_type;
	wire MEM_l_type;
	wire MEM_s_type;
	wire EXE_l_type;
	wire EXE_s_type;
	wire EXE_mul_div_type;
	
	assign ID_br_type = (`ID_func == `BEQ   || `ID_func== `BNE ||
						 `ID_func == `BGEZ  && ID_inst[20:16] == `BGEZ_2||
						 `ID_func == `BGTZ  || `ID_func== `BLEZ|| 
						 `ID_func == `BLTZ  && ID_inst[20:16] == `BLTZ_2||
						 `ID_func == `BGEZAL&& ID_inst[20:16] == `BGEZAL_2||
						 `ID_func == `BLTZAL&& ID_inst[20:16] == `BLTZAL_2) ? 1'b1 : 1'b0;
	assign MEM_l_type = MEM_inst[31:26] == `LB  || MEM_inst[31:26] == `LBU ||
						MEM_inst[31:26] == `LH  || MEM_inst[31:26] == `LHU ||	
						MEM_inst[31:26] == `LW  || MEM_inst[31:26] == `LWL || 
						MEM_inst[31:26] == `LWR;
	assign MEM_s_type = MEM_inst[31:26] == `SB || MEM_inst[31:26] == `SH ||
                        MEM_inst[31:26] == `SW || MEM_inst[31:26] == `SWL||
                        MEM_inst[31:26] == `SWR;
						
	assign EXE_mul_div_type = (EXE_inst[31:26] == 6'b000000) && (EXE_inst[5:0] == `DIV_2 || EXE_inst[5:0] == `DIVU_2 ||
                               EXE_inst[5:0] == `MULT_2 || EXE_inst[5:0] == `MULTU_2);
	
	
	assign EXE_l_type = EXE_inst[31:26] == `LB  || EXE_inst[31:26] == `LBU ||
						EXE_inst[31:26] == `LH  || EXE_inst[31:26] == `LHU ||	
						EXE_inst[31:26] == `LW  || EXE_inst[31:26] == `LWL || 
						EXE_inst[31:26] == `LWR;
						
	assign EXE_s_type = EXE_inst[31:26] == `SB || EXE_inst[31:26] == `SH ||
                        EXE_inst[31:26] == `SW || EXE_inst[31:26] == `SWL||
                        EXE_inst[31:26] == `SWR;
						
	assign IF_stall = (MEM_l_type && (EXE_src1 == MEM_reg_dst && EXE_src1 != 5'd0 || EXE_src2 == MEM_reg_dst && EXE_src2 != 5'd0)) ||
	                  (MEM_l_type && (ID_src1  == MEM_reg_dst && ID_src1  != 5'd0 || ID_src2  == MEM_reg_dst && ID_src2  != 5'd0)) ||
					  (EXE_l_type && (ID_src1  == EXE_reg_dst && ID_src1  != 5'd0 || ID_src2  == EXE_reg_dst && ID_src2  != 5'd0)) ||
					  (EXE_mul_div_type && !EXE_mul_div_validout) ||
					  (EXE_mul_div_type && (ID_inst[31:26] == `MFHI && ID_inst[5:0] == `MFHI_2 || ID_inst[31:26] == `MFLO && ID_inst[5:0] == `MFLO_2)) ||
					  (ID_br_type && (ID_src1 == EXE_reg_dst && ID_src1 != 5'd0 || ID_src2 == EXE_reg_dst && ID_src2 != 5'd0)) ||
					  (EXE_l_type && MEM_s_type);
					  
	assign ID_stall = (MEM_l_type && (EXE_src1 == MEM_reg_dst && EXE_src1 != 5'd0 || EXE_src2 == MEM_reg_dst && EXE_src2 != 5'd0)) ||
	                  (MEM_l_type && (ID_src1  == MEM_reg_dst && ID_src1  != 5'd0 || ID_src2  == MEM_reg_dst && ID_src2  != 5'd0)) ||
					  (EXE_l_type && (ID_src1  == EXE_reg_dst && ID_src1  != 5'd0 || ID_src2  == EXE_reg_dst && ID_src2  != 5'd0)) ||
					  (EXE_mul_div_type && !EXE_mul_div_validout) ||
					  (EXE_mul_div_type && (ID_inst[31:26] == `MFHI && ID_inst[5:0] == `MFHI_2 || ID_inst[31:26] == `MFLO && ID_inst[5:0] == `MFLO_2)) ||
					  (ID_br_type && (ID_src1 == EXE_reg_dst && ID_src1 != 5'd0 || ID_src2 == EXE_reg_dst && ID_src2 != 5'd0)) ||
					  (EXE_l_type && MEM_s_type);
	
	assign EXE_stall = (MEM_l_type && (EXE_src1 == MEM_reg_dst && EXE_src1 != 5'd0 || EXE_src2 == MEM_reg_dst && EXE_src2 != 5'd0)) ||
					   (EXE_mul_div_type && !EXE_mul_div_validout) ||
					   (EXE_l_type && MEM_s_type);
	
	
	assign ID_vsrc1_for = (EXE_inst[31:26] == `MTHI && EXE_inst[5:0] == `MTHI_2 && ID_inst[31:26] == `MFHI && ID_inst[5:0] == `MFHI_2 ||
						   EXE_inst[31:26] == `MTLO && EXE_inst[5:0] == `MTLO_2 && ID_inst[31:26] == `MFLO && ID_inst[5:0] == `MFLO_2) ? 2'b01 :
	                      (ID_src1 == MEM_reg_dst && ID_src1 != 5'd0) ? 2'b10 : 
						  (ID_src1 == WB_reg_dst  && ID_src1 != 5'd0) ? 2'b11 :
						   2'b000;
						  
	assign ID_vsrc2_for = (ID_src2 == MEM_reg_dst && ID_src2 != 5'd0) ? 2'b10 : 
						  (ID_src2 == WB_reg_dst  && ID_src2 != 5'd0) ? 2'b11 : 2'b00;

	
	assign EXE_srcA_for = (EXE_src1 == MEM_reg_dst && EXE_src1 != 5'd0) ? 2'b01 :
						  (EXE_src1 == WB_reg_dst  && EXE_src1 != 5'd0) ? 2'b10 : 2'b00;

	
	
	assign EXE_srcB_for = (EXE_inst[31:26] != `LWL && EXE_inst[31:26] != `LWR && !EXE_s_type) && (EXE_src2 == MEM_reg_dst) && (EXE_src2 != 5'd0) ? 2'b01 :
						  (EXE_inst[31:26] != `LWL && EXE_inst[31:26] != `LWR && !EXE_s_type) && (EXE_src2 == WB_reg_dst ) && (EXE_src2 != 5'd0) ? 2'b10 : 2'b00;
						
	
	assign EXE_reg_rt_for = (EXE_inst[31:26] == `LWL || EXE_inst[31:26] == `LWR || EXE_s_type) && (EXE_src2 == MEM_reg_dst) && (EXE_src2 != 5'd0) ? 2'b01 :
	                        (EXE_inst[31:26] == `LWL || EXE_inst[31:26] == `LWR || EXE_s_type) && (EXE_src2 == WB_reg_dst ) && (EXE_src2 != 5'd0) ? 2'b10 : 2'b00;
	
	
	assign MEM_reg_rt_for = (MEM_inst[31:26] == `SB  || MEM_inst[31:26] == `SH  || MEM_inst[31:26] == `SW  ||
                             MEM_inst[31:26] == `SWL || MEM_inst[31:26] == `SWR || MEM_inst[31:26] == `LWL || 
							 MEM_inst[31:26] == `LWR ) && (MEM_src2 == WB_reg_dst) && (MEM_src2 != 5'd0) ? 1'b1 : 1'b0;
							 


endmodule