module IF_stage(
    input  wire        clk,
    input  wire        resetn,            //low active
	input  wire        IF_stall,
	input  wire [31:0] next_pc,

	input  wire [31:0] inst_rdata,
	output reg  [31:0] inst_vaddr,
	output wire        inst_req,
    output wire [31:0] IF_pc,
	output wire [31:0] IF_inst,
	input  wire        IF_clear,
	output wire        IF_inst_addr_err,
	input  wire        ID_delay_slot,
	output wire        IF_BD,
	output wire        IF_interrupt,
	input  wire        interrupt,
	input  wire        inst_addr_ok,
    input  wire        inst_data_ok,
	input  wire        IF_redo,
	output wire        IF_TLBrefill,
	output wire        IF_TLBinvalid,
	input  wire        inst_V_flag,
	input  wire        inst_found,
	input  wire        TLBrefill_fault
);
	reg  re_do;
	reg  [1:0] is_clear;
	reg  do_mem;
	reg  inst_found_reg;
	reg  inst_V_flag_reg;

	
	
	always @(posedge clk)
	begin
		if (!resetn) 
			do_mem <= 1'b0;
		else if (inst_addr_ok)
		    do_mem <= 1'b1;
		else if (inst_data_ok)
		    do_mem <= 1'b0;
	end
	
	always @(posedge clk)
	begin
		if (!resetn)
			re_do <=1'b0;
		else if (inst_data_ok)
			re_do <= 1'b0;
		else if (IF_redo)
			re_do <= 1'b1;
	end
	
	always @(posedge clk)
	begin
		if (!resetn)
			inst_found_reg <=1'b0;
		else if (inst_addr_ok)
			inst_found_reg <= inst_found;
		else if (inst_data_ok)
			inst_found_reg <= 1'b0;
	end
	
	always @(posedge clk)
	begin
		if (!resetn)
			inst_V_flag_reg <=1'b0;
		else if (inst_addr_ok)
			inst_V_flag_reg <= inst_V_flag;
		else if (inst_data_ok)
			inst_V_flag_reg <= 1'b0;
	end
	
	always @(posedge clk)
	begin
		if (!resetn)
			is_clear <= 2'd0;
		else if (inst_data_ok)
			is_clear <= 2'd0;
		else if (IF_clear && TLBrefill_fault && !is_clear)
			is_clear <= 2'd2;
		else if (IF_clear && !TLBrefill_fault && !is_clear)
			is_clear <= 2'd1;
	end
	
	

	assign IF_pc = (inst_data_ok) ? ((is_clear || IF_stall || re_do) ? 32'd0 : inst_vaddr) : 32'd0;

	assign inst_req = !do_mem;
	
	always @(posedge clk)
	begin
		if (!resetn) 
			inst_vaddr <= 32'hbfc00000;
		else if (inst_data_ok && is_clear==2'd1) 
			inst_vaddr <= 32'hbfc00380;
		else if (inst_data_ok && is_clear==2'd2) 
			inst_vaddr <= 32'hbfc00200;
		else if (inst_data_ok && !IF_stall && !re_do)
			inst_vaddr <= next_pc;
		else 
			inst_vaddr <= inst_vaddr;
	end

							
	assign IF_inst = (inst_data_ok) ? ((is_clear || IF_inst_addr_err || IF_stall || re_do) ? 32'd0 : inst_rdata) : 32'd0;
	assign IF_BD = ID_delay_slot;
    assign IF_inst_addr_err = (IF_pc[1:0] != 2'd0) ? 1'b1 : 1'b0;
    assign IF_interrupt = (inst_data_ok && !is_clear) ? interrupt : 1'b0;
	assign IF_TLBrefill = (inst_data_ok) ? ((is_clear || IF_stall || re_do) ? 1'b0 : ~inst_found_reg) : 1'b0;
	assign IF_TLBinvalid = (inst_data_ok) ? ((is_clear || IF_stall || re_do) ? 1'b0 : ~inst_V_flag_reg) : 1'b0;
endmodule
