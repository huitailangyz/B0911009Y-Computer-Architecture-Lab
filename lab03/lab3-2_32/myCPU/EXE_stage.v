`include "head.h"
module EXE_stage(
    input  wire        clk,
    input  wire        resetn,
	input  wire        EXE_stall,

	input  wire [31:0] ID_pc,
    input  wire [31:0] ID_inst,          //instr code @decode stage
		
	input  wire [4:0]  ID_src1,            
	input  wire [4:0]  ID_src2,
    input  wire [4:0]  ID_dest,         //reg num of dest operand, zero if no dest
	input  wire        ID_memtoreg,      //1: mem   0:result
	input  wire [5:0]  ID_ALUop,
    input  wire [31:0] ID_vsrc1,        //value of source operand 1
    input  wire [31:0] ID_vsrc2,        //value of source operand 2
	input  wire [31:0] ID_reg_rt,
	input  wire        ID_HI_we,
	input  wire        ID_LO_we,
	
	
	input  wire [1:0]  EXE_srcA_for,    //00: stay   01: MEM_for   10: WB_for
	input  wire [1:0]  EXE_srcB_for,
	input  wire [1:0]  EXE_reg_rt_for,
	input  wire [31:0] MEM_for,
	input  wire [31:0] WB_for,

	output wire [31:0] EXE_pc_out,
	output wire [31:0] EXE_inst_out,
	output wire [4:0]  EXE_src1_out,            
	output wire [4:0]  EXE_src2_out,
    output wire [4:0]  EXE_dest_out,         //reg num of dest operand, zero if no dest
	output wire        EXE_memtoreg_out,      //1: mem   0:result
	output wire [31:0] EXE_result_out,        
	output wire [31:0] EXE_reg_rt_out,

	output reg         EXE_HI_we_out,
	output reg         EXE_LO_we_out,
	
	output wire [31:0] EXE_reg1_for,
	output wire [31:0] EXE_for,
	output reg  [31:0] EXE_vsrc1,        //value of source operand 1
	
	output reg  [31:0]  EXE_inst,          //instr code @decode stage	
	output reg  [4:0]   EXE_src1,           
	output reg  [4:0]   EXE_src2,
    output reg  [4:0]   EXE_dest,         //reg num of dest operand, zero if no dest
	
	output wire [31:0]  EXE_memaddr,
	output wire 	    EXE_data_sram_ren,
	//mul & div section
	output wire [31:0] HI_out,
	output wire [31:0] LO_out,
	output wire        EXE_mul_div_validout
	);
	reg  [31:0] EXE_pc;
   
	reg         EXE_memtoreg;      //1: mem   0:result
	reg  [5:0]  EXE_ALUop;
    reg  [31:0] EXE_vsrc2;        //value of source operand 2
	reg  [31:0] EXE_reg_rt;

	wire [31:0] EXE_result;
	wire [31:0] EXE_srcA;
	wire [31:0] EXE_srcB;
	wire [31:0] EXE_reg_rt_temp;
	wire        EXE_l_type;
	
	//mul & div section
	wire        EXE_mul_div_validin;
    wire        EXE_mul_div_type;
	
	wire        EXE_signed_div_validin;
	wire        EXE_signed_div_validout;
	wire [63:0] EXE_signed_div_dataout;
	
	wire        EXE_unsigned_div_validin;
	wire        EXE_unsigned_div_validout;
    wire [63:0] EXE_unsigned_div_dataout;
    
	wire        EXE_signed_mul_validin;
	wire        EXE_signed_mul_validout;
    wire [63:0] EXE_signed_mul_dataout;
    
	wire        EXE_unsigned_mul_validin;
	wire        EXE_unsigned_mul_validout;
    wire [63:0] EXE_unsigned_mul_dataout;

	reg         EXE_mul_div_doing;
	reg         EXE_stall_last;
	
alu alu(
    .aluop  (EXE_ALUop      ), //I, 6
    .vsrc1  (EXE_srcA      ),  //I, 32
    .vsrc2  (EXE_srcB      ),  //I, 32
    .result (EXE_result     )  //O, 32
    );

divider_signed divider_signed(
	.clk(clk),                                      // input wire aclk
	.resetn(resetn),                                // input wire aresetn
	.div_A_valid(EXE_signed_div_validin),    // input wire s_axis_divisor_tvalid

	.divisor(EXE_srcB),      // input wire [31 : 0] s_axis_divisor_tdata
	.div_B_valid(EXE_signed_div_validin),  // input wire s_axis_dividend_tvalid

	.dividend(EXE_srcA),    // input wire [31 : 0] s_axis_dividend_tdata
	.div_validout(EXE_signed_div_validout),          // output wire m_axis_dout_tvalid
	.div_out(EXE_signed_div_dataout)            // output wire [63 : 0] m_axis_dout_tdata
);







divider_unsigned divider_unsigned(
	.clk(clk),                                      // input wire aclk
	.resetn(resetn),                                // input wire aresetn
	.div_A_valid(EXE_unsigned_div_validin),    // input wire s_axis_divisor_tvalid

	.divisor(EXE_srcB),      // input wire [31 : 0] s_axis_divisor_tdata
	.div_B_valid(EXE_unsigned_div_validin),  // input wire s_axis_dividend_tvalid

	.dividend(EXE_srcA),    // input wire [31 : 0] s_axis_dividend_tdata
	.div_validout(EXE_unsigned_div_validout),          // output wire m_axis_dout_tvalid
	.div_out(EXE_unsigned_div_dataout)            // output wire [63 : 0] m_axis_dout_tdata
);

multiplier_signed multiplier_signed(
	.clk(clk),
	.resetn(resetn),
	.mul_A(EXE_srcA),
	.mul_B(EXE_srcB),
	.mul_A_valid(EXE_signed_mul_validin),
	.mul_B_valid(EXE_signed_mul_validin),
	.mul_out(EXE_signed_mul_dataout),
	.mul_validout(EXE_signed_mul_validout)
	);
	
multiplier_unsigned multiplier_unsigned(
	.clk(clk),
	.resetn(resetn),
	.mul_A(EXE_srcA),
	.mul_B(EXE_srcB),
	.mul_A_valid(EXE_unsigned_mul_validin),
	.mul_B_valid(EXE_unsigned_mul_validin),
	.mul_out(EXE_unsigned_mul_dataout),
	.mul_validout(EXE_unsigned_mul_validout)
	);

    always @(posedge clk)
    begin
        if (!resetn || EXE_mul_div_validout) 
            EXE_mul_div_doing <= 0;
        else if (EXE_mul_div_validin)
            EXE_mul_div_doing <= 1;
        EXE_stall_last <= EXE_stall;
    end
	assign EXE_mul_div_type = (EXE_inst[31:26] == 6'b000000) && (EXE_inst[5:0] == `DIV_2 || EXE_inst[5:0] == `DIVU_2 ||
                               EXE_inst[5:0] == `MULT_2 || EXE_inst[5:0] == `MULTU_2); 
	assign EXE_signed_div_validin   = EXE_mul_div_validin && EXE_ALUop ==  6'b011010; 
	assign EXE_unsigned_div_validin = EXE_mul_div_validin && EXE_ALUop ==  6'b011011;
	assign EXE_signed_mul_validin   = EXE_mul_div_validin && EXE_ALUop ==  6'b011000;
	assign EXE_unsigned_mul_validin = EXE_mul_div_validin && EXE_ALUop ==  6'b011001;
	
	assign EXE_mul_div_validin = !EXE_stall_last && !EXE_mul_div_doing && 
	                             (EXE_ALUop ==  6'b011010 || EXE_ALUop ==  6'b011011 || 
	                              EXE_ALUop ==  6'b011000 || EXE_ALUop ==  6'b011001);
								  
	assign EXE_mul_div_validout = EXE_unsigned_div_validout || EXE_signed_div_validout || 
	                              EXE_unsigned_mul_validout || EXE_signed_mul_validout;
	
	assign HI_out = (EXE_ALUop ==  6'b011010) ? EXE_signed_div_dataout[63:32] :    //DIV
					(EXE_ALUop ==  6'b011011) ? EXE_unsigned_div_dataout[63:32] :  //DIVU
					(EXE_ALUop ==  6'b011000) ? EXE_signed_mul_dataout[63:32] :   //MULT
					(EXE_ALUop ==  6'b011001) ? EXE_unsigned_mul_dataout[63:32] : //MULTU
					32'd0;
					
	assign LO_out = (EXE_ALUop ==  6'b011010) ? EXE_signed_div_dataout[31:0] :    //DIV
					(EXE_ALUop ==  6'b011011) ? EXE_unsigned_div_dataout[31:0] :  //DIVU
 					(EXE_ALUop ==  6'b011000) ? EXE_signed_mul_dataout[31:0] :     //MULT
					(EXE_ALUop ==  6'b011001) ? EXE_unsigned_mul_dataout[31:0] :   //MULTU
					32'd0;
	
	
	
	
	
	
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			EXE_pc       <= 32'hbfc00000;
			EXE_inst     <= 32'h00000000;
			EXE_src1     <= 5'd0;          
			EXE_src2     <= 5'd0;
			EXE_dest     <= 5'd0;      		 
			EXE_memtoreg <= 1'b0;    
			EXE_ALUop    <= 6'b111111;
			EXE_vsrc1    <= 32'd0;        
			EXE_vsrc2    <= 32'd0;       
			EXE_reg_rt   <= 32'd0;
			
			EXE_HI_we_out<= 1'b0;
            EXE_LO_we_out<= 1'b0;			
		end
		else if (EXE_stall) begin
			EXE_pc       <= EXE_pc;
			EXE_inst     <= EXE_inst;
			EXE_src1     <= EXE_src1;          
			EXE_src2     <= EXE_src2;
			EXE_dest     <= EXE_dest;      		 
			EXE_memtoreg <= EXE_memtoreg;    
			EXE_ALUop    <= EXE_ALUop;
			EXE_vsrc1    <= EXE_vsrc1;        
			EXE_vsrc2    <= EXE_vsrc2;       
			EXE_reg_rt   <= EXE_reg_rt;
			
			EXE_HI_we_out<= EXE_HI_we_out;
			EXE_LO_we_out<= EXE_LO_we_out;	
		end 
		else begin
			EXE_pc       <= ID_pc;
			EXE_inst     <= ID_inst;
			EXE_src1     <= ID_src1;          
			EXE_src2     <= ID_src2;
			EXE_dest     <= ID_dest;      		 
			EXE_memtoreg <= ID_memtoreg;    
			EXE_ALUop    <= ID_ALUop;
			EXE_vsrc1    <= ID_vsrc1;        
			EXE_vsrc2    <= ID_vsrc2;       
			EXE_reg_rt   <= ID_reg_rt;
			
			EXE_HI_we_out<= ID_HI_we;
			EXE_LO_we_out<= ID_LO_we;
		end
	end
	
	assign EXE_l_type = (`EXE_func == `LB || `EXE_func == `LBU || 
						 `EXE_func == `LH || `EXE_func == `LHU || 
						 `EXE_func == `LW || `EXE_func == `LWL || 
						 `EXE_func == `LWR) ? 1'b1 : 1'b0;
						
	
	
	
	
	assign EXE_for = EXE_result;
	assign EXE_reg1_for = EXE_vsrc1;
	
	assign EXE_srcA = (EXE_srcA_for == 2'b00) ? EXE_vsrc1 :
					  (EXE_srcA_for == 2'b01) ? MEM_for :
					   WB_for;
	assign EXE_srcB = (EXE_srcB_for == 2'b00) ? EXE_vsrc2 :
					  (EXE_srcB_for == 2'b01) ? MEM_for :
					   WB_for;
	assign EXE_reg_rt_temp = (EXE_reg_rt_for == 2'b00) ? EXE_reg_rt :
					         (EXE_reg_rt_for == 2'b01) ? MEM_for :
					          WB_for;
	
	assign EXE_pc_out       = (EXE_stall) ? 32'hbfc00000 : EXE_pc;
    assign EXE_inst_out     = (EXE_stall) ? 32'h00000000 : EXE_inst;          //instr code @decode stage
	assign EXE_src1_out     = (EXE_stall) ? 5'd0 : EXE_src1;            
	assign EXE_src2_out     = (EXE_stall) ? 5'd0 : EXE_src2; 
    assign EXE_dest_out     = (EXE_stall) ? 5'd0 : EXE_dest;         //reg num of dest operand, zero if no dest
	assign EXE_memtoreg_out = (EXE_stall) ? 1'b0 : EXE_memtoreg;      //1: mem   0:result
    assign EXE_result_out   = (EXE_stall) ? 32'd0 : EXE_result;
	assign EXE_reg_rt_out   = (EXE_stall) ? 32'd0 : EXE_reg_rt;
	assign EXE_memaddr      = (EXE_stall) ? 32'd0 : (EXE_l_type) ? EXE_result :32'd0;	
	assign EXE_data_sram_ren= (EXE_stall) ? 1'b0 : 
	                          (EXE_l_type) ? 1'b1 : 1'b0;
endmodule