`include "head.h"
module MEM_stage(
    input  wire        clk,
    input  wire        resetn,
	
	input  wire [31:0] EXE_pc,
	input  wire [31:0] EXE_inst,
	input  wire [4:0]  EXE_src1,             //32: HI     33: LO 
	input  wire [4:0]  EXE_src2,
    input  wire [4:0]  EXE_dest,         //reg num of dest operand, zero if no dest
	input  wire        EXE_memtoreg,      //1: mem   0:result
	input  wire [31:0] EXE_result,        //value of source operand 2
	input  wire [31:0] EXE_reg_rt,
    input  wire [31:0] EXE_memaddr,
	input  wire        EXE_data_sram_ren,
	input  wire        MEM_reg_rt_for,
	input  wire [31:0] WB_for,

    input  wire [31:0] data_sram_rdata,
	output wire        data_sram_en,
	output wire [3:0]  data_sram_wen,
	output wire [31:0] data_sram_wdata,
	output wire [31:0] data_sram_addr,
	
	output reg  [31:0] MEM_pc_out,
	output reg  [31:0] MEM_inst_out,
	output wire [1:0]  MEM_reg_we_out,
	output reg  [4:0]  MEM_dest_out,
	output reg         MEM_memtoreg_out,
	output reg  [31:0] MEM_result_out,
	output wire [31:0] MEM_mem_rdata_out,
	output wire [31:0] MEM_reg_rt_out,
	
	output wire [31:0] MEM_for,
	output reg  [4:0]  MEM_src2,
	output wire        MEM_delay_slot
);
	

	reg [31:0] MEM_reg_rt;

	wire       MEM_l_type;
	wire       MEM_s_type;
	wire       MEM_j_type;
	wire       MEM_jr_type;
	wire       MEM_br_type;
	
	
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			MEM_pc_out       <= 32'hbfc00000;
			MEM_inst_out     <= 32'h00000000;         
			MEM_src2         <= 5'd0;
			MEM_dest_out     <= 5'd0;      		 
			MEM_memtoreg_out <= 1'b0;    
			MEM_result_out   <= 32'd0;     
			MEM_reg_rt       <= 32'd0;			
		end
		else begin
			MEM_pc_out       <= EXE_pc;
			MEM_inst_out     <= EXE_inst;         
			MEM_src2         <= EXE_src2;
			MEM_dest_out     <= EXE_dest;      		 
			MEM_memtoreg_out <= EXE_memtoreg;    
			MEM_result_out   <= EXE_result;     
			MEM_reg_rt       <= EXE_reg_rt;	
		end
	end
	
	assign MEM_for = MEM_result_out;
	assign MEM_reg_rt_out = (MEM_reg_rt_for == 1'b0) ? MEM_reg_rt : WB_for;
	
	
	//MEM_dest ensure that if the inst actually does not need to change the register, the dest is 5'b00000
	assign MEM_reg_we_out = MEM_result_out[1:0];
	
	
	assign data_sram_wen = (`MEM_func == `SB)  ? (data_sram_addr[1:0] == 2'b00 ? 4'b0001:
												  data_sram_addr[1:0] == 2'b01 ? 4'b0010:
												  data_sram_addr[1:0] == 2'b10 ? 4'b0100:
												  data_sram_addr[1:0] == 2'b11 ? 4'b1000:
												  4'b0000) :
						   (`MEM_func == `SH)  ? (data_sram_addr[1] == 1'b0 ? 4'b0011:
												  data_sram_addr[1] == 1'b1 ? 4'b1100:
												  4'b0000) :
	                       (`MEM_func == `SW)  ?  4'b1111 :
						   (`MEM_func == `SWL) ? (data_sram_addr[1:0] == 2'b00 ? 4'b0001:
												  data_sram_addr[1:0] == 2'b01 ? 4'b0011:
												  data_sram_addr[1:0] == 2'b10 ? 4'b0111:
												  data_sram_addr[1:0] == 2'b11 ? 4'b1111:
												  4'b0000) :
						   (`MEM_func == `SWR) ? (data_sram_addr[1:0] == 2'b00 ? 4'b1111:
												  data_sram_addr[1:0] == 2'b01 ? 4'b1110:
												  data_sram_addr[1:0] == 2'b10 ? 4'b1100:
											  	  data_sram_addr[1:0] == 2'b11 ? 4'b1000:
										   		  4'b0000) :
							4'b0000;
	
	assign data_sram_en = |data_sram_wen || EXE_data_sram_ren;
	
	assign MEM_mem_rdata_out = data_sram_rdata;
	assign data_sram_addr = EXE_memaddr | MEM_result_out & {32{MEM_s_type}};
	
	assign data_sram_wdata = (`MEM_func == `SB) ? (MEM_reg_rt_out << (data_sram_addr[1:0] *8)) :
							 (`MEM_func == `SH) ? (MEM_reg_rt_out << (data_sram_addr[1] *16)) :
							 (`MEM_func == `SWL)? (MEM_reg_rt_out >> ((2'd3 -data_sram_addr[1:0]) *8)) : 
							 (`MEM_func == `SWR)? (MEM_reg_rt_out << (data_sram_addr[1:0] *8)) : 
							  MEM_reg_rt_out;

	
	assign MEM_s_type = (`MEM_func == `SB || `MEM_func == `SH ||
						 `MEM_func == `SW || `MEM_func == `SWL||
						 `MEM_func == `SWR) ? 1'b1 : 1'b0;	
	assign MEM_l_type = (`MEM_func == `LB || `MEM_func == `LBU || 
						 `MEM_func == `LH || `MEM_func == `LHU || 
						 `MEM_func == `LW || `MEM_func == `LWL || 
						 `MEM_func == `LWR) ? 1'b1 : 1'b0;
						

	
	
	assign MEM_br_type = (`MEM_func == `BEQ   || `MEM_func== `BNE ||
						  `MEM_func == `BGEZ  && MEM_inst_out[20:16] == `BGEZ_2||
			 			  `MEM_func == `BGTZ  || `MEM_func== `BLEZ|| 
		 				  `MEM_func == `BLTZ  && MEM_inst_out[20:16] == `BLTZ_2||
	 					  `MEM_func == `BGEZAL&& MEM_inst_out[20:16] == `BGEZAL_2||
						  `MEM_func == `BLTZAL&& MEM_inst_out[20:16] == `BLTZAL_2) ? 1'b1 : 1'b0;
						 
	assign MEM_j_type = (`MEM_func == `J || `MEM_func == `JAL) ? 1'b1 : 1'b0;
	
	assign MEM_jr_type = (`MEM_func == `JR   && MEM_inst_out[5:0] == `JR_2 || 
						  `MEM_func == `JALR && MEM_inst_out[5:0] == `JALR) ? 1'b1 : 1'b0;
    assign MEM_delay_slot = (MEM_br_type || MEM_j_type || MEM_jr_type) ? 1'b1 : 1'b0;					 


endmodule