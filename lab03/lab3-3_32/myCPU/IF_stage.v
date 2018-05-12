module IF_stage(
    input  wire        clk,
    input  wire        resetn,            //low active
	input  wire        IF_stall,
	input  wire [31:0] next_pc,

	input  wire [31:0] inst_sram_rdata,
	output wire [31:0] inst_sram_addr,
    output reg  [31:0] IF_pc,
	output wire [31:0] IF_inst
);
	
	always @(posedge clk)
	begin
		IF_pc <= inst_sram_addr;
	end
	
	assign inst_sram_addr = (!resetn) ? 32'hbfc00000 : (!IF_stall) ? next_pc : IF_pc;
	assign IF_inst = inst_sram_rdata;
	
endmodule
