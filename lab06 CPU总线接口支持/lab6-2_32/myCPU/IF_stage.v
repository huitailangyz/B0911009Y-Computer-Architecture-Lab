module IF_stage(
    input  wire        clk,
    input  wire        resetn,            //low active
	input  wire        IF_stall,
	input  wire [31:0] next_pc,

	input  wire [31:0] inst_rdata,
	output reg  [31:0] inst_addr,
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
    input  wire        inst_data_ok
);
	
	reg  is_clear;
	reg  do_mem;
	
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
			is_clear <= 1'b0;
		else if (inst_data_ok)
			is_clear <= 1'b0;
		else if (IF_clear)
			is_clear <= 1'b1;
	end
	
	
	/*always @(posedge clk)
	begin
		if (!do_mem)
			IF_pc <= inst_addr;
	end*/
	assign IF_pc = (inst_data_ok) ? ((is_clear) ? 32'd0 : inst_addr) : 32'd0;

	assign inst_req = !do_mem;
	
	always @(posedge clk)
	begin
		if (!resetn) 
			inst_addr <= 32'hbfc00000;
		else if (inst_data_ok && is_clear) 
			inst_addr <= 32'hbfc00380;
		else if (inst_data_ok && !IF_stall)
			inst_addr <= next_pc;
		else 
			inst_addr <= inst_addr;
	end

							
	assign IF_inst = (inst_data_ok) ? ((is_clear || IF_inst_addr_err) ? 32'd0 : inst_rdata) : 32'd0;
	assign IF_BD = ID_delay_slot;
    assign IF_inst_addr_err = (IF_pc[1:0] != 2'd0) ? 1'b1 : 1'b0;
    assign IF_interrupt = (inst_data_ok && !is_clear) ? interrupt : 1'b0;
endmodule
