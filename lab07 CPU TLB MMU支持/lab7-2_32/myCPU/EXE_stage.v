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
	output reg  [31:0] EXE_vsrc1,        //value of source operand 1
	
	output reg  [31:0]  EXE_inst,          //instr code @decode stage	
	output reg  [4:0]   EXE_src1,           
	output reg  [4:0]   EXE_src2,
    output reg  [4:0]   EXE_dest,         //reg num of dest operand, zero if no dest
	
	output wire [31:0]  EXE_memaddr,
	output wire [1:0]   EXE_memsize,
	output wire 	    EXE_data_sram_ren,
	//mul & div section
	output wire [31:0] HI_out,
	output wire [31:0] LO_out,
	output wire        EXE_mul_div_validout,
	output wire        EXE_overflow,
	output wire        rdata_addr_err,
	output wire        wdata_addr_err,
	output wire        EXE_break_out,
	output wire        EXE_BD_out,
	output wire        EXE_inst_addr_err_out,
	output wire        EXE_no_inst_out,
	output wire        EXE_syscall_out,
	input  wire        EXE_clear,
	output reg  [31:0] EXE_pc,
	input  wire        ID_break,
	input  wire        ID_syscall,
	input  wire        ID_no_inst,
	input  wire        ID_BD,
    input  wire        ID_inst_addr_err,
	output wire [31:0] CP0_wdata,
    output wire [4:0]  MTC0_waddr,
    input  wire        ID_interrupt,
    output wire        EXE_interrupt_out,
	input  wire        ID_TLBinvalid,
	input  wire        ID_TLBrefill,
	output wire        EXE_inst_invalid_out,
	output wire        EXE_inst_refill_out,
	output wire        EXE_data_invalid_out,
	output wire        EXE_data_refill_out,
	output wire        EXE_data_modified_out,
	output wire        EXE_TLBWI,
	output wire        EXE_TLBR,
	output wire        EXE_TLBP,
	input  wire        data_V_flag,
	input  wire        data_D_flag,
	input  wire        data_found,
	output wire [31:0] EXE_result
);

    
	reg         EXE_memtoreg;      //1: mem   0:result
	reg  [5:0]  EXE_ALUop;
    reg  [31:0] EXE_vsrc2;        //value of source operand 2
	reg  [31:0] EXE_reg_rt;


	wire [31:0] EXE_srcA;
	wire [31:0] EXE_srcB;
	wire [31:0] EXE_reg_rt_temp;
	wire        EXE_l_type;
	wire        EXE_s_type;
	wire        EXE_MTC0;
	//mul & div section
	wire        EXE_mul_div_validin;
    wire        EXE_mul_div_type;
	
	wire        EXE_div_validin;
	wire        EXE_div_validout;
	wire [63:0] EXE_div_dataout;
	wire        sign;
    
	wire        EXE_mul_validin;
	wire        EXE_mul_validout;
    wire [63:0] EXE_mul_dataout;
    

	reg         EXE_mul_div_doing;
	reg         EXE_stall_last;
	wire        EXE_br_type;
	wire        EXE_j_type;
	wire        EXE_jr_type;
	wire        EXE_overflow_temp;
	reg         EXE_break;
	reg         EXE_syscall;
	reg         EXE_no_inst;
	reg         EXE_BD;
    reg         EXE_inst_addr_err;
    reg         EXE_interrupt;
	reg         EXE_inst_invalid;
	reg         EXE_inst_refill;
	
	
alu alu(
    .aluop  (EXE_ALUop      ), //I, 6
    .vsrc1  (EXE_srcA      ),  //I, 32
    .vsrc2  (EXE_srcB      ),  //I, 32
    .result (EXE_result     ),  //O, 32
    .overflow (EXE_overflow_temp )   //0, 1
    );
    
    assign EXE_overflow = EXE_overflow_temp && !EXE_stall;
    
    assign rdata_addr_err = ((`EXE_func == `LH || `EXE_func == `LHU) && EXE_result[0] != 1'b0 ||
                              `EXE_func == `LW && EXE_result[1:0] != 2'b00) && !EXE_stall ? 1'b1 : 1'b0;
    assign wdata_addr_err = (`EXE_func == `SH && EXE_result[0] != 1'b0 ||
                             `EXE_func == `SW && EXE_result[1:0] != 2'b00) && !EXE_stall ? 1'b1 : 1'b0;
    assign CP0_wdata = EXE_result;
    assign MTC0_waddr = (EXE_MTC0) ? EXE_inst[15:11] : 5'd0;                         
                             
                             


divider divider(
	.clk(clk),                                      // input wire aclk
	.resetn(resetn),                                // input wire aresetn
	.div_A_valid(EXE_div_validin),    // input wire s_axis_divisor_tvalid
    .sign(sign),
	.divisor(EXE_srcB),      // input wire [31 : 0] s_axis_divisor_tdata
	.div_B_valid(EXE_div_validin),  // input wire s_axis_dividend_tvalid

	.dividend(EXE_srcA),    // input wire [31 : 0] s_axis_dividend_tdata
	.div_validout(EXE_div_validout),          // output wire m_axis_dout_tvalid
	.div_out(EXE_div_dataout)            // output wire [63 : 0] m_axis_dout_tdata
);



multiplier multiplier(
	.mul_clk(clk),
	.resetn(resetn),
	.mul_signed(sign),
	.x(EXE_srcA),
	.y(EXE_srcB),
	.valid_in_x(EXE_mul_validin),
	.valid_in_y(EXE_mul_validin),
	.result(EXE_mul_dataout),
	.valid_out(EXE_mul_validout)
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
    assign sign = (EXE_inst[5:0] == `DIV_2 || EXE_inst[5:0] == `MULT_2) ? 1 : 0;
	assign EXE_div_validin   = EXE_mul_div_validin && (EXE_ALUop ==  6'b011010 || EXE_ALUop ==  6'b011011); 
	assign EXE_mul_validin   = EXE_mul_div_validin && (EXE_ALUop ==  6'b011000 || EXE_ALUop ==  6'b011001);
	
	assign EXE_mul_div_validin = !EXE_stall_last && !EXE_mul_div_doing && 
	                             (EXE_ALUop ==  6'b011010 || EXE_ALUop ==  6'b011011 || 
	                              EXE_ALUop ==  6'b011000 || EXE_ALUop ==  6'b011001);
								  
	assign EXE_mul_div_validout = EXE_div_validout || EXE_mul_validout;
	
	assign HI_out = (EXE_ALUop ==  6'b011010) ? EXE_div_dataout[63:32] :    //DIV
					(EXE_ALUop ==  6'b011011) ? EXE_div_dataout[63:32] :  //DIVU
					(EXE_ALUop ==  6'b011000) ? EXE_mul_dataout[63:32] :   //MULT
					(EXE_ALUop ==  6'b011001) ? EXE_mul_dataout[63:32] : //MULTU
					32'd0;
					
	assign LO_out = (EXE_ALUop ==  6'b011010) ? EXE_div_dataout[31:0] :    //DIV
					(EXE_ALUop ==  6'b011011) ? EXE_div_dataout[31:0] :  //DIVU
 					(EXE_ALUop ==  6'b011000) ? EXE_mul_dataout[31:0] :     //MULT
					(EXE_ALUop ==  6'b011001) ? EXE_mul_dataout[31:0] :   //MULTU
					32'd0;
	
	
	always @(posedge clk)
	begin
		if (!resetn || EXE_clear) begin
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
			EXE_BD       <= 1'b0;
		    EXE_break    <= 1'b0;
	        EXE_syscall  <= 1'b0;
	        EXE_no_inst  <= 1'b0;
            EXE_inst_addr_err <= 1'b0;
            EXE_interrupt<= 1'b0;
			EXE_inst_invalid <= 1'b0;
			EXE_inst_refill <= 1'b0;
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
			EXE_BD       <= EXE_BD;
		    EXE_break    <= EXE_break;
	        EXE_syscall  <= EXE_syscall;
	        EXE_no_inst  <= EXE_no_inst;
            EXE_inst_addr_err <= EXE_inst_addr_err;
            EXE_interrupt<= EXE_interrupt;
			EXE_inst_invalid <= EXE_inst_invalid;
			EXE_inst_refill <= EXE_inst_refill;
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
			EXE_BD       <= ID_BD;
		    EXE_break    <= ID_break;
	        EXE_syscall  <= ID_syscall;
	        EXE_no_inst  <= ID_no_inst;
            EXE_inst_addr_err <= ID_inst_addr_err;
            EXE_interrupt<= ID_interrupt;
			EXE_inst_invalid <= ID_TLBinvalid;
			EXE_inst_refill <= ID_TLBrefill;
		end
	end
	
	assign EXE_l_type = (`EXE_func == `LB || `EXE_func == `LBU || 
						 `EXE_func == `LH || `EXE_func == `LHU || 
						 `EXE_func == `LW || `EXE_func == `LWL || 
						 `EXE_func == `LWR) ? 1'b1 : 1'b0;
	assign EXE_s_type = EXE_inst[31:26] == `SB || EXE_inst[31:26] == `SH ||
                        EXE_inst[31:26] == `SW || EXE_inst[31:26] == `SWL||
                        EXE_inst[31:26] == `SWR;					
	
	
	
	
	assign EXE_reg1_for = EXE_srcA;
	
	assign EXE_srcA = (EXE_srcA_for == 2'b00) ? EXE_vsrc1 :
					  (EXE_srcA_for == 2'b01) ? MEM_for :
					   WB_for;
	assign EXE_srcB = (EXE_srcB_for == 2'b00) ? EXE_vsrc2 :
					  (EXE_srcB_for == 2'b01) ? MEM_for :
					   WB_for;
	assign EXE_reg_rt_temp = (EXE_reg_rt_for == 2'b00) ? EXE_reg_rt :
					         (EXE_reg_rt_for == 2'b01) ? MEM_for :
					          WB_for;
					        

	assign EXE_br_type = (`EXE_func == `BEQ   || `EXE_func== `BNE ||
						  `EXE_func == `BGEZ  && EXE_inst[20:16] == `BGEZ_2||
			 			  `EXE_func == `BGTZ  || `EXE_func== `BLEZ|| 
		 				  `EXE_func == `BLTZ  && EXE_inst[20:16] == `BLTZ_2||
	 					  `EXE_func == `BGEZAL&& EXE_inst[20:16] == `BGEZAL_2||
						  `EXE_func == `BLTZAL&& EXE_inst[20:16] == `BLTZAL_2) ? 1'b1 : 1'b0;
						 
	assign EXE_j_type = (`EXE_func == `J || `EXE_func == `JAL) ? 1'b1 : 1'b0;
	
	assign EXE_jr_type = (`EXE_func == `JR   && EXE_inst[5:0] == `JR_2 || 
						  `EXE_func == `JALR && EXE_inst[5:0] == `JALR) ? 1'b1 : 1'b0;
    assign EXE_MTC0 = `EXE_func == `MTC0 && EXE_inst[25:21] == `MTC0_2 && EXE_inst[10:3] == 8'd0;
	
	
	assign EXE_pc_out       = (EXE_stall || EXE_clear) ? 32'hbfc00000 : EXE_pc;
    assign EXE_inst_out     = (EXE_stall || EXE_clear) ? 32'h00000000 : EXE_inst;          //instr code @decode stage
	assign EXE_src1_out     = (EXE_stall || EXE_clear) ? 5'd0 : EXE_src1;            
	assign EXE_src2_out     = (EXE_stall || EXE_clear) ? 5'd0 : EXE_src2; 
    assign EXE_dest_out     = (EXE_stall || EXE_clear) ? 5'd0 : EXE_dest;         //reg num of dest operand, zero if no dest
	assign EXE_memtoreg_out = (EXE_stall || EXE_clear) ? 1'b0 : EXE_memtoreg;      //1: mem   0:result
    assign EXE_result_out   = (EXE_stall || EXE_clear) ? 32'd0 : EXE_result;
	assign EXE_reg_rt_out   = (EXE_stall || EXE_clear) ? 32'd0 : EXE_reg_rt;
	assign EXE_memaddr      = (EXE_stall || EXE_clear) ? 32'd0 : (EXE_l_type) ? EXE_result :32'd0;
	assign EXE_memsize      = (EXE_stall || EXE_clear) ? 2'b11 : 
							  (`EXE_func == `LB || `EXE_func == `LBU) ? 2'b00 :
							  (`EXE_func == `LH || `EXE_func == `LHU) ? 2'b01 :
							  (`EXE_func == `LW || `EXE_func == `LWL || `EXE_func == `LWR) ? 2'b10 : 
							  2'b11;
	assign EXE_data_sram_ren= (EXE_stall || EXE_clear) ? 1'b0 : 
	                          (EXE_l_type) ? 1'b1 : 1'b0;
							  
	assign EXE_BD_out       = (EXE_stall) ? 1'b0 : EXE_BD;
	assign EXE_inst_addr_err_out = (EXE_stall) ? 1'b0 : EXE_inst_addr_err;	
	assign EXE_syscall_out  = (EXE_stall) ? 1'b0 : EXE_syscall;
	assign EXE_break_out    = (EXE_stall) ? 1'b0 : EXE_break;
	assign EXE_no_inst_out  = (EXE_stall) ? 1'b0 : EXE_no_inst;
	assign EXE_interrupt_out= (EXE_stall) ? 1'b0 : EXE_interrupt;
	assign EXE_TLBWI = (EXE_stall) ? 1'b0 : EXE_inst == 32'b01000010000000000000000000000010;
	assign EXE_TLBP  = (EXE_stall) ? 1'b0 : EXE_inst == 32'b01000010000000000000000000001000;
	assign EXE_TLBR  = (EXE_stall) ? 1'b0 : EXE_inst == 32'b01000010000000000000000000000001;
	assign EXE_inst_invalid_out = (EXE_stall) ? 1'b0 : EXE_inst_invalid;
	assign EXE_inst_refill_out = (EXE_stall) ? 1'b0 : EXE_inst_refill;
	assign EXE_data_invalid_out = (EXE_stall) ? 1'b0 : (EXE_l_type || EXE_s_type) && data_found && !data_V_flag;
	assign EXE_data_refill_out = (EXE_stall) ? 1'b0 : (EXE_l_type || EXE_s_type) && !data_found;
	assign EXE_data_modified_out = (EXE_stall) ? 1'b0 : (EXE_s_type && data_found && data_V_flag && !data_D_flag);
	
endmodule