`include "head.h"
module WB_stage(
    input  wire        clk,
    input  wire        resetn,
	
	input  wire [31:0] MEM_pc,
	input  wire [31:0] MEM_inst,
	input  wire [1:0]  MEM_reg_we,
	input  wire [4:0]  MEM_dest,
	input  wire        MEM_memtoreg,
	input  wire [31:0] MEM_result,
	input  wire [31:0] MEM_mem_rdata,
	input  wire [31:0] MEM_reg_rt,


    output wire        WB_reg_write_en,
    output wire [31:0] WB_reg_wdata, 
	output reg  [4:0]  WB_reg_addr,

    output reg  [31:0] WB_pc,
	output wire [31:0] WB_for
);

	reg  [1:0]  WB_reg_we;
	reg  [31:0] WB_inst;
	reg         WB_memtoreg;
	reg  [31:0] WB_result;
	reg  [31:0] WB_reg_rt;
	reg  [31:0] WB_mem_rdata;
	wire [31:0] WB_memdata_temp;
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			WB_pc       <= 32'hbfc00000;
			WB_inst     <= 32'h00000000;
			WB_reg_we   <= 2'bXX;
			WB_reg_addr <= 5'd0;      		 
			WB_memtoreg <= 1'bX;    
			WB_result   <= 32'd0;     
			WB_reg_rt   <= 32'd0;		
            WB_mem_rdata <= 32'd0;			
		end
		else begin
			WB_pc       <= MEM_pc;
			WB_inst     <= MEM_inst;
			WB_reg_we   <= MEM_reg_we;
			WB_reg_addr <= MEM_dest;      		 
			WB_memtoreg <= MEM_memtoreg;    
			WB_result   <= MEM_result;     
			WB_reg_rt   <= MEM_reg_rt;
			WB_mem_rdata <= MEM_mem_rdata;
		end
	end

	assign WB_for = WB_reg_wdata;
	assign WB_reg_write_en = 1;

	//WB_memtoreg      1: mem   0: result
	assign WB_reg_wdata = (WB_memtoreg) ? WB_memdata_temp : WB_result;

	assign WB_memdata_temp = (`WB_func == `LB)  ? (WB_reg_we == 2'b00 ? {{24{WB_mem_rdata[7]}},WB_mem_rdata[7:0]} :
												   WB_reg_we == 2'b01 ? {{24{WB_mem_rdata[15]}},WB_mem_rdata[15:8]} :
												   WB_reg_we == 2'b10 ? {{24{WB_mem_rdata[23]}},WB_mem_rdata[23:16]} :
												  {{24{WB_mem_rdata[31]}},WB_mem_rdata[31:24]} ) :
							 (`WB_func == `LBU) ? (WB_reg_we == 2'b00 ? {{24{1'b0}},WB_mem_rdata[7:0]} :
												   WB_reg_we == 2'b01 ? {{24{1'b0}},WB_mem_rdata[15:8]} :
												   WB_reg_we == 2'b10 ? {{24{1'b0}},WB_mem_rdata[23:16]} :
												  {{24{1'b0}},WB_mem_rdata[31:24]} ) :
                             (`WB_func == `LH)  ? (WB_reg_we[1] == 1'b0 ? {{16{WB_mem_rdata[15]}},WB_mem_rdata[15:0]} :
												  {{16{WB_mem_rdata[31]}},WB_mem_rdata[31:16]} ) :
                             (`WB_func == `LHU) ? (WB_reg_we[1] == 1'b0 ? {{16{1'b0}},WB_mem_rdata[15:0]} :
												  {{16{1'b0}},WB_mem_rdata[31:16]} ) :	
                             (`WB_func == `LWL) ? (WB_reg_we == 2'b00 ? {WB_mem_rdata[7:0],WB_reg_rt[23:0]} :
												   WB_reg_we == 2'b01 ? {WB_mem_rdata[15:0],WB_reg_rt[15:0]} :
												   WB_reg_we == 2'b10 ? {WB_mem_rdata[23:0],WB_reg_rt[7:0]} :
												   WB_mem_rdata ) :
                             (`WB_func == `LWR) ? (WB_reg_we == 2'b00 ? WB_mem_rdata :
												   WB_reg_we == 2'b01 ? {WB_reg_rt[31:24],WB_mem_rdata[31:8]} :
												   WB_reg_we == 2'b10 ? {WB_reg_rt[31:16],WB_mem_rdata[31:16]} :
												  {WB_reg_rt[31:8],WB_mem_rdata[31:24]} ) :											   
							 WB_mem_rdata;

endmodule