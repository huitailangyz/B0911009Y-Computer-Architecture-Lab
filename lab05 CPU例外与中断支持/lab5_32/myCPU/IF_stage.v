module IF_stage(
    input  wire        clk,
    input  wire        resetn,            //low active
	input  wire        IF_stall,
	input  wire [31:0] next_pc,

	input  wire [31:0] inst_sram_rdata,
	output wire [31:0] inst_sram_addr,
    output reg  [31:0] IF_pc,
	output wire [31:0] IF_inst,
	input  wire        IF_clear,
	output wire        IF_inst_addr_err,
	input  wire        ID_delay_slot,
	output wire        IF_BD,
	output wire        IF_interrupt,
	input  wire        interrupt
);
	
	always @(posedge clk)
	begin
		IF_pc <= inst_sram_addr;
	end
	
	assign inst_sram_addr = (!resetn) ? 32'hbfc00000 : 
	                        (IF_clear) ? 32'hbfc00380 : 
	                        (!IF_stall ) ? next_pc : IF_pc;
	assign IF_inst = inst_sram_rdata;
	assign IF_BD = ID_delay_slot;
    assign IF_inst_addr_err = (IF_pc[1:0] != 2'd0) ? 1'b1 : 1'b0;
    assign IF_interrupt = interrupt;
endmodule
