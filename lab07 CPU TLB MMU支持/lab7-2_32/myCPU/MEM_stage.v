`include "head.h"
module MEM_stage(
    input  wire        clk,
    input  wire        resetn,
	input  wire        MEM_stall,
	
	input  wire [31:0] EXE_pc,
	input  wire [31:0] EXE_inst,
	input  wire [4:0]  EXE_src1,             //32: HI     33: LO 
	input  wire [4:0]  EXE_src2,
    input  wire [4:0]  EXE_dest,         //reg num of dest operand, zero if no dest
	input  wire        EXE_memtoreg,      //1: mem   0:result
	input  wire [31:0] EXE_result,        //value of source operand 2
	input  wire [31:0] EXE_reg_rt,
    input  wire [31:0] EXE_memaddr,
	input  wire [1:0]  EXE_memsize,
	input  wire        EXE_data_sram_ren,
	input  wire        MEM_reg_rt_for,
	input  wire [31:0] WB_for,

    input  wire [31:0] data_rdata,
	
	output wire        data_req,
	output wire        data_wr,
	output wire [3:0]  data_wen,
	output wire [31:0] data_wdata,
	output wire [1:0]  data_size,
	input  wire        data_addr_ok,
    input  wire        data_data_ok,
	
	output wire [31:0] MEM_pc_out,
	output wire [31:0] MEM_inst_out,
	output wire [1:0]  MEM_reg_we_out,
	output wire [4:0]  MEM_dest_out,
	output wire        MEM_memtoreg_out,
	output wire [31:0] MEM_result_out,
	output wire [31:0] MEM_mem_rdata_out,
	output wire [31:0] MEM_reg_rt_out,
	
	output wire [31:0] MEM_for,
	output wire [4:0]  MEM_src2_out,
	output reg  [31:0] MEM_inst,
	output reg  [4:0]  MEM_src2,
	output reg  [4:0]  MEM_dest,
	input  wire [31:0] data_paddr,
	output reg  [31:0] MEM_data_paddr
	);
	
	reg [31:0] MEM_pc;
	reg [31:0] MEM_reg_rt;

	
	reg        MEM_memtoreg;
	reg [31:0] MEM_result;
	
	wire       MEM_l_type;
	wire       MEM_s_type;
	wire       MEM_j_type;
	wire       MEM_jr_type;
	wire       MEM_br_type;
	reg        do_mem;
	
	always @(posedge clk)
	begin
		if (!resetn) 
			MEM_data_paddr <= 32'h0;
		else if (MEM_stall)
		    MEM_data_paddr <= MEM_data_paddr;
		else 
		    MEM_data_paddr <= data_paddr;
	end
	
	always @(posedge clk)
	begin
		if (!resetn) 
			do_mem <= 1'b0;
		else if (data_addr_ok)
		    do_mem <= 1'b1;
		else if (data_data_ok)
		    do_mem <= 1'b0;
	end
	
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			MEM_pc           <= 32'hbfc00000;
			MEM_inst         <= 32'h00000000;         
			MEM_src2         <= 5'd0;
			MEM_dest         <= 5'd0;      		 
			MEM_memtoreg     <= 1'b0;    
			MEM_result       <= 32'd0;     
			MEM_reg_rt       <= 32'd0;	
		end
		else if (MEM_stall) begin
			MEM_pc           <= MEM_pc;
			MEM_inst         <= MEM_inst;         
			MEM_src2         <= MEM_src2;
			MEM_dest         <= MEM_dest;      		 
			MEM_memtoreg     <= MEM_memtoreg;    
			MEM_result       <= MEM_result;     
			MEM_reg_rt       <= MEM_reg_rt;	
		end else begin
			MEM_pc           <= EXE_pc;
			MEM_inst         <= EXE_inst;         
			MEM_src2         <= EXE_src2;
			MEM_dest         <= EXE_dest;      		 
			MEM_memtoreg     <= EXE_memtoreg;    
			MEM_result       <= EXE_result;     
			MEM_reg_rt       <= EXE_reg_rt;	
		end
	end
	
	
	assign MEM_pc_out       = (MEM_stall) ? 32'd0 : MEM_pc;
	assign MEM_inst_out     = (MEM_stall) ? 32'd0 : MEM_inst;         
	assign MEM_src2_out     = (MEM_stall) ? 5'd0  : MEM_src2;
	assign MEM_dest_out     = (MEM_stall) ? 5'd0  : MEM_dest;      		  
	assign MEM_memtoreg_out = (MEM_stall) ? 1'd0  : MEM_memtoreg;    
	assign MEM_result_out   = (MEM_stall) ? 32'd0 : MEM_result;    
	assign MEM_for = (MEM_stall) ? 32'd0 : MEM_result_out;
	assign MEM_reg_rt_out = (MEM_stall) ? 32'd0 :
	                        (MEM_reg_rt_for == 1'b0) ? MEM_reg_rt : WB_for;
	
	
	//MEM_dest ensure that if the inst actually does not need to change the register, the dest is 5'b00000
	assign MEM_reg_we_out = (MEM_stall) ? 2'd0 : MEM_result_out[1:0];
	
	
	assign data_wen = (`MEM_func == `SB)  ? (MEM_data_paddr[1:0] == 2'b00 ? 4'b0001:
												  MEM_data_paddr[1:0] == 2'b01 ? 4'b0010:
												  MEM_data_paddr[1:0] == 2'b10 ? 4'b0100:
												  MEM_data_paddr[1:0] == 2'b11 ? 4'b1000:
												  4'b0000) :
						   (`MEM_func == `SH)  ? (MEM_data_paddr[1] == 1'b0 ? 4'b0011:
												  MEM_data_paddr[1] == 1'b1 ? 4'b1100:
												  4'b0000) :
	                       (`MEM_func == `SW)  ?  4'b1111 :
						   (`MEM_func == `SWL) ? (MEM_data_paddr[1:0] == 2'b00 ? 4'b0001:
												  MEM_data_paddr[1:0] == 2'b01 ? 4'b0011:
												  MEM_data_paddr[1:0] == 2'b10 ? 4'b0111:
												  MEM_data_paddr[1:0] == 2'b11 ? 4'b1111:
												  4'b0000) :
						   (`MEM_func == `SWR) ? (MEM_data_paddr[1:0] == 2'b00 ? 4'b1111:
												  MEM_data_paddr[1:0] == 2'b01 ? 4'b1110:
												  MEM_data_paddr[1:0] == 2'b10 ? 4'b1100:
											  	  MEM_data_paddr[1:0] == 2'b11 ? 4'b1000:
										   		  4'b0000) :
							4'b0000;
	assign data_size = (`MEM_func == `SB || `MEM_func == `LB || `MEM_func == `LBU) ? 2'b00:
	                   (`MEM_func == `SH || `MEM_func == `LH || `MEM_func == `LHU) ? 2'b01:
					   2'b10;
	assign data_req = (|data_wen || MEM_l_type)&& !do_mem;
	assign data_wr = |data_wen;
	assign MEM_mem_rdata_out = (MEM_stall) ? 32'd0 : data_rdata;

	
	assign data_wdata = (`MEM_func == `SB) ? (MEM_reg_rt << (MEM_data_paddr[1:0] *8)) :
							 (`MEM_func == `SH) ? (MEM_reg_rt << (MEM_data_paddr[1] *16)) :
							 (`MEM_func == `SWL)? (MEM_reg_rt >> ((2'd3 -MEM_data_paddr[1:0]) *8)) : 
							 (`MEM_func == `SWR)? (MEM_reg_rt << (MEM_data_paddr[1:0] *8)) : 
							  MEM_reg_rt;

	
	assign MEM_s_type = (`MEM_func == `SB || `MEM_func == `SH ||
						 `MEM_func == `SW || `MEM_func == `SWL||
						 `MEM_func == `SWR) ? 1'b1 : 1'b0;	
	assign MEM_l_type = (`MEM_func == `LB || `MEM_func == `LBU || 
						 `MEM_func == `LH || `MEM_func == `LHU || 
						 `MEM_func == `LW || `MEM_func == `LWL || 
						 `MEM_func == `LWR) ? 1'b1 : 1'b0;
						

	
	
	/*assign MEM_br_type = (`MEM_func == `BEQ   || `MEM_func== `BNE ||
						  `MEM_func == `BGEZ  && MEM_inst_out[20:16] == `BGEZ_2||
			 			  `MEM_func == `BGTZ  || `MEM_func== `BLEZ|| 
		 				  `MEM_func == `BLTZ  && MEM_inst_out[20:16] == `BLTZ_2||
	 					  `MEM_func == `BGEZAL&& MEM_inst_out[20:16] == `BGEZAL_2||
						  `MEM_func == `BLTZAL&& MEM_inst_out[20:16] == `BLTZAL_2) ? 1'b1 : 1'b0;
						 
	assign MEM_j_type = (`MEM_func == `J || `MEM_func == `JAL) ? 1'b1 : 1'b0;
	
	assign MEM_jr_type = (`MEM_func == `JR   && MEM_inst_out[5:0] == `JR_2 || 
						  `MEM_func == `JALR && MEM_inst_out[5:0] == `JALR) ? 1'b1 : 1'b0;
	*/

endmodule