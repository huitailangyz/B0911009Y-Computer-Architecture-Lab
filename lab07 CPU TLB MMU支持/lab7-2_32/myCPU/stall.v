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
	input              ID_eret,
	input  wire [4:0]  ID_src1,
	input  wire [4:0]  ID_src2,
	input  wire [31:0] ID_inst,
	input  wire        EXE_mul_div_validout,
	
	
	input  wire        inst_data_ok,
	input  wire        data_data_ok,
	input  wire        data_addr_ok,
	input  wire        inst_addr_ok,
	
	output wire        IF_stall,
	output wire        IF_redo,
	output wire        ID_stall,
	output wire        EXE_stall,
	output wire        MEM_stall,
	output wire [1:0]  ID_vsrc1_for,    //00: stay   01: EXE_reg1_for   10: MEM_for  11: WB_for 
	output wire [1:0]  ID_vsrc2_for,
	output wire [1:0]  EXE_srcA_for,    //00: stay    01: MEM_for    10: WB_for
	output wire [1:0]  EXE_srcB_for,
	output wire [1:0]  EXE_reg_rt_for,
	output wire        MEM_reg_rt_for   //0:  stay    1: WB_for 
);
	wire ID_j_type;
	wire ID_br_type;
	wire ID_jr_type;
	wire ID_MFC0;
	wire ID_MTC0;
	wire EXE_MTC0;
	wire MEM_l_type;
	wire MEM_s_type;
	wire EXE_l_type;
	wire EXE_s_type;
	wire EXE_mul_div_type;
	wire ID_TLBWI;
	wire ID_TLBP;
	wire ID_TLBR;
	wire EXE_TLBWI;
	wire EXE_TLBP;
	wire EXE_TLBR;
	
	assign ID_TLBWI = ID_inst == 32'b01000010000000000000000000000010;
	assign ID_TLBP  = ID_inst == 32'b01000010000000000000000000001000;
	assign ID_TLBR  = ID_inst == 32'b01000010000000000000000000000001;
	assign EXE_TLBWI = EXE_inst == 32'b01000010000000000000000000000010;
	assign EXE_TLBP  = EXE_inst == 32'b01000010000000000000000000001000;
	assign EXE_TLBR  = EXE_inst == 32'b01000010000000000000000000000001;

	assign ID_MFC0 = `ID_func == `MFC0 && ID_inst[25:21] == `MFC0_2 && ID_inst[10:3] == 8'd0;
	assign ID_MTC0 = `ID_func == `MTC0 && ID_inst[25:21] == `MTC0_2 && ID_inst[10:3] == 8'd0;

    assign EXE_MTC0 = `EXE_func == `MTC0 && EXE_inst[25:21] == `MTC0_2 && EXE_inst[10:3] == 8'd0;
	
	assign ID_j_type = (`ID_func == `J || `ID_func == `JAL) ? 1'b1 : 1'b0;
	assign ID_jr_type = (`ID_func == `JR   && ID_inst[20:6] == 15'd0 && ID_inst[5:0] == `JR_2 || 
                         `ID_func == `JALR && ID_inst[20:16] == 5'd0 && ID_inst[10:6] == 5'd0 && ID_inst[5:0] == `JALR_2) ? 1'b1 : 1'b0;
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
	
	assign IF_redo = (ID_MTC0 && ID_inst[15:11] == 5'd10 || EXE_MTC0 && EXE_inst[15:11] == 5'd10 || ID_TLBWI || ID_TLBR || EXE_TLBWI || EXE_TLBR);
	
	
	assign IF_stall = (MEM_l_type && (EXE_src1 == MEM_reg_dst && EXE_src1 != 5'd0 || EXE_src2 == MEM_reg_dst && EXE_src2 != 5'd0)) ||
	                  (MEM_l_type && (ID_src1  == MEM_reg_dst && ID_src1  != 5'd0 || ID_src2  == MEM_reg_dst && ID_src2  != 5'd0)) ||
					  (EXE_l_type && (ID_src1  == EXE_reg_dst && ID_src1  != 5'd0 || ID_src2  == EXE_reg_dst && ID_src2  != 5'd0)) ||
					  (EXE_mul_div_type && !EXE_mul_div_validout) ||
					  (EXE_mul_div_type && (ID_inst[31:26] == `MFHI && ID_inst[5:0] == `MFHI_2 || ID_inst[31:26] == `MFLO && ID_inst[5:0] == `MFLO_2)) ||
					  ((ID_br_type || ID_jr_type) && (ID_src1 == EXE_reg_dst && ID_src1 != 5'd0 || ID_src2 == EXE_reg_dst && ID_src2 != 5'd0)) ||
					  (ID_MFC0 && EXE_MTC0 && ID_inst[15:11] == EXE_inst[15:11]) ||
					  (ID_MFC0 && (EXE_TLBR || EXE_TLBP)) ||
					  (ID_eret && EXE_MTC0 && EXE_inst[15:11] == 5'd14) ||
					  (EXE_l_type && MEM_s_type) ||
					  ((MEM_l_type || MEM_s_type) && !data_data_ok) ||
					  (!inst_data_ok);
					  
	assign ID_stall = (MEM_l_type && (EXE_src1 == MEM_reg_dst && EXE_src1 != 5'd0 || EXE_src2 == MEM_reg_dst && EXE_src2 != 5'd0)) ||
	                  (MEM_l_type && (ID_src1  == MEM_reg_dst && ID_src1  != 5'd0 || ID_src2  == MEM_reg_dst && ID_src2  != 5'd0)) ||
					  (EXE_l_type && (ID_src1  == EXE_reg_dst && ID_src1  != 5'd0 || ID_src2  == EXE_reg_dst && ID_src2  != 5'd0)) ||
					  (EXE_mul_div_type && !EXE_mul_div_validout) ||
					  (EXE_mul_div_type && (ID_inst[31:26] == `MFHI && ID_inst[5:0] == `MFHI_2 || ID_inst[31:26] == `MFLO && ID_inst[5:0] == `MFLO_2)) ||
					  ((ID_br_type || ID_jr_type)&& (ID_src1 == EXE_reg_dst && ID_src1 != 5'd0 || ID_src2 == EXE_reg_dst && ID_src2 != 5'd0)) ||
					  (ID_MFC0 && EXE_MTC0 && ID_inst[15:11] == EXE_inst[15:11]) ||
					  (ID_MFC0 && (EXE_TLBR || EXE_TLBP)) ||
				      (ID_eret && EXE_MTC0 && EXE_inst[15:11] == 5'd14) ||
					  (EXE_l_type && MEM_s_type) ||
					  ((MEM_l_type || MEM_s_type) && !data_data_ok) ||
					  ((ID_br_type || ID_j_type || ID_jr_type || ID_eret) && !inst_data_ok);
	
	assign EXE_stall = (MEM_l_type && (EXE_src1 == MEM_reg_dst && EXE_src1 != 5'd0 || EXE_src2 == MEM_reg_dst && EXE_src2 != 5'd0)) ||
					   (EXE_mul_div_type && !EXE_mul_div_validout) ||
					   (EXE_l_type && MEM_s_type) ||  //may be can delete
					   ((MEM_l_type || MEM_s_type) && !data_data_ok);
	
	
	
	assign MEM_stall = ((MEM_l_type || MEM_s_type) && !data_data_ok);
	
	
	
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