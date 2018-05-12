`ifdef PRJ1_FPGA_IMPL
	// the board does not have enough GPIO, so we implement 4 4-bit registers
    `define DATA_WIDTH 4
	`define ADDR_WIDTH 2
`else
    `define DATA_WIDTH 32
	`define ADDR_WIDTH 5
`endif

module reg_file(
	input clk,
	input resetn,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output wire [`DATA_WIDTH - 1:0] rdata1,
	output wire [`DATA_WIDTH - 1:0] rdata2
);

	// TODO: insert your code
	reg [`DATA_WIDTH - 1:0] r [(1 << `ADDR_WIDTH)-1:0];
	integer i;

    always @(posedge clk)
    begin
        if (resetn==0) for (i=0; i<1 << `ADDR_WIDTH; i=i+1) 
                      r[i] <= 0;
        else if (wen && waddr!=0) r[waddr] <= wdata; 
    end
    
    assign  rdata1 = raddr1==0 ? 0: r[raddr1];
    assign  rdata2 = raddr2==0 ? 0: r[raddr2];
endmodule
