`include "head.h"

module mycpu_top(
    input  wire        clk,
    input  wire        resetn,            //low active

    output wire        inst_sram_en,
    output wire [ 3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input  wire [31:0] inst_sram_rdata,
    
    output wire        data_sram_en,
    output wire [ 3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input  wire [31:0] data_sram_rdata, 

    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_wen,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata,
    input  wire [ 5:0] hard_interrupt
);

	reg [31:0] HI;
	reg [31:0] LO;
	reg [31:0] CP0_STATUS;
	reg [31:0] CP0_CAUSE;
	reg [31:0] CP0_COMPARE;
	reg [31:0] CP0_COUNT;
	reg [31:0] CP0_BADVADDR;
	reg [31:0] CP0_EPC;
	wire        interrupt;

//regfile	
	wire [31:0] ID_reg_rdata1;
    wire [31:0] ID_reg_rdata2;
	
//next_pc
	wire [31:0] next_pc;
	
//IF_stage
	wire [31:0] IF_pc;
	wire [31:0] IF_inst;
	wire        IF_BD;
	wire        IF_inst_addr_err;
	wire        IF_interrupt;
//ID_stage
	wire [4:0]  ID_reg_raddr1;
	wire [4:0]  ID_reg_raddr2;
	wire        ID_br_taken;    //1: branch taken,go to the branch target
	wire        ID_br_type;    //1: inst is branch type
    wire        ID_j_type;      //1: inst is jump type
    wire        ID_jr_type;     //1: inst is jump register type
    wire [15:0] ID_br_index;    //offset for type "br"
    wire [25:0] ID_j_index;     //instr_index for type "j"
    wire [31:0] ID_jr_index;    //target for type "jr"
    wire [31:0] ID_pc_out;
    wire [31:0] ID_inst_out;          //instr code @decode stage		
	wire [4:0]  ID_src1_out;           
	wire [4:0]  ID_src2_out;
    wire [4:0]  ID_dest_out;         //reg num of dest operand, zero if no dest
	wire        ID_memtoreg_out;      //1: mem   0:result
	wire [5:0]  ID_ALUop_out;
    wire [31:0] ID_vsrc1_out;        //value of source operand 1
    wire [31:0] ID_vsrc2_out;        //value of source operand 2
	wire [31:0] ID_reg_rt_out;
	wire        ID_HI_we_out;
	wire        ID_LO_we_out;
	wire [31:0] ID_inst;
	wire [4:0]  ID_src1;           
	wire [4:0]  ID_src2;
	
	wire        ID_eret_out;
	wire        ID_break_out;
	wire        ID_syscall_out;
	wire        ID_no_inst_out;
    wire        ID_delay_slot;
	wire        ID_BD_out;
	wire        ID_inst_addr_err_out;
	wire        ID_interrupt_out;
	
//EXE_stage	
	wire [31:0] EXE_pc_out;
	wire [31:0] EXE_inst_out;
	wire [4:0]  EXE_src1_out;            
	wire [4:0]  EXE_src2_out;
    wire [4:0]  EXE_dest_out;         //reg num of dest operand, zero if no dest
	wire        EXE_memtoreg_out;      //1: mem   0:result
	wire [31:0] EXE_result_out;        
	wire [31:0] EXE_reg_rt_out;
    wire        EXE_HI_we_out;
    wire        EXE_LO_we_out;

	wire [31:0] EXE_reg1_for;	
	wire [31:0] EXE_vsrc1;

	wire [31:0] EXE_inst;          //instr code @decode stage	
	wire [4:0]  EXE_src1;           
	wire [4:0]  EXE_src2;
    wire [4:0]  EXE_dest;
	wire [31:0] EXE_memaddr;
	wire [31:0] HI_to_write;
	wire [31:0] LO_to_write;
	wire        EXE_mul_div_validout;
	wire        EXE_data_sram_ren;
	
	wire        EXE_overflow;
	wire        rdata_addr_err;
	wire        wdata_addr_err;
    wire        EXE_break;
	wire        EXE_BD;
	wire        inst_addr_err;
	wire        EXE_no_inst;
	wire        EXE_syscall;
	wire [31:0] EXE_pc;
	wire [31:0] CP0_wdata;
	wire [4:0]  MTC0_waddr;
	wire        EXE_interrupt;
	
//MEM_stage	
	wire [31:0] MEM_pc_out;
	wire [31:0] MEM_inst_out;
	wire [1:0]  MEM_reg_we_out;
    wire [4:0]  MEM_dest_out;
	wire        MEM_memtoreg_out;
	wire [31:0] MEM_result_out;
	wire [31:0] MEM_mem_rdata_out;
    wire [31:0] MEM_reg_rt_out;
	wire [31:0] MEM_for;
	wire [4:0]  MEM_src2;	
	wire        MEM_delay_slot;
	
	
//WB_stage
	wire        WB_reg_write_en;
    wire [31:0] WB_reg_wdata; 
	wire [4:0]  WB_reg_addr;
    wire [31:0] WB_pc;
    wire [31:0] WB_for;


//stall	
	wire        IF_stall;
	wire        ID_stall;
	wire        EXE_stall;
	wire [1:0]  ID_vsrc1_for;    //00: stay   01: EXE_reg1_for   10: MEM_for  11: WB_for 100:  
	wire [1:0]  ID_vsrc2_for;
	wire [1:0]  EXE_srcA_for;    //00: stay    01: MEM_for    10: WB_for
	wire [1:0]  EXE_srcB_for;
	wire [1:0]  EXE_reg_rt_for;
	wire        MEM_reg_rt_for;   //0:  stay    1: WB_for 
	
    wire        IF_clear;
    wire        ID_clear;
    wire        EXE_clear;


nextpc nextpc(
    .IF_pc             (IF_pc           	), //I, 32

    .ID_br_taken       (ID_br_taken     	), //I, 1 
    .ID_br_type        (ID_br_type          ), //I, 1
    .ID_j_type         (ID_j_type      	 	), //I, 1
    .ID_jr_type        (ID_jr_type     		), //I, 1
    .ID_br_index       (ID_br_index     	), //I, 16
    .ID_j_index        (ID_j_index      	), //I, 26
    .ID_jr_index       (ID_jr_index     	), //I, 32

    .inst_sram_en      (inst_sram_en    	), //O, 1
    .next_pc           (next_pc         	), //O, 32
    .CP0_EPC           (CP0_EPC             ),
    .ID_eret           (ID_eret_out         )
    );


IF_stage IF_stage(
    .clk               (clk             	), //I, 1
    .resetn            (resetn          	), //I, 1
    .IF_stall          (IF_stall            ),                  
    .next_pc           (next_pc         	), //I, 32
                                    
    .inst_sram_rdata   (inst_sram_rdata 	), //I, 32
    .inst_sram_addr    (inst_sram_addr  	),                     
    .IF_pc             (IF_pc           	), //O, 32  
    .IF_inst           (IF_inst         	), //O, 32
    .IF_clear          (IF_clear            ),
	.IF_inst_addr_err  (IF_inst_addr_err    ),
	.ID_delay_slot     (ID_delay_slot       ),
	.IF_BD             (IF_BD               ),
	.interrupt         (interrupt           ),
	.IF_interrupt      (IF_interrupt        )
    );


ID_stage ID_stage(
    .clk               (clk             	), //I, 1
    .resetn            (resetn          	), //I, 1
                                    
    .ID_stall          (ID_stall        	), //I, 32
    .IF_pc             (IF_pc           	), //I, 32                                    
    .IF_inst           (IF_inst         	), //O, 5
    .ID_reg_raddr1     (ID_reg_raddr1   	), //I, 32
    .ID_reg_rdata1     (ID_reg_rdata1   	), //O, 5
    .ID_reg_raddr2     (ID_reg_raddr2   	), //I, 32
                                    
    .ID_reg_rdata2     (ID_reg_rdata2   	), //O, 1
    .ID_br_taken       (ID_br_taken     	), //O, 1
    .ID_br_type        (ID_br_type      	), //O, 1
    .ID_j_type         (ID_j_type       	), //O, 1
    .ID_jr_type        (ID_jr_type      	), //O, 16
    .ID_br_index       (ID_br_index     	), //O, 26
    .ID_j_index        (ID_j_index      	), //O, 32
                                    
    .ID_jr_index       (ID_jr_index     	), //O, ??
    .ID_vsrc1_for      (ID_vsrc1_for    	), //O, 5 
    .ID_vsrc2_for      (ID_vsrc2_for    	), //O, 32
    .HI                (HI              	), //O, 32
    .LO                (LO              	),  //O, 32
	
    .MEM_for           (MEM_for         	), //I, 1                       
    .WB_for            (WB_for          	), //I, 32                            
    .EXE_reg1_for      (EXE_reg1_for    	), //O, 5
	
    .ID_pc_out         (ID_pc_out       	), //O, 5
    .ID_inst_out       (ID_inst_out     	), //I, 32
                                    
    .ID_src1_out       (ID_src1_out     	), //O, 1
    .ID_src2_out       (ID_src2_out     	), //O, 1
    .ID_dest_out       (ID_dest_out     	), //O, 1
    .ID_memtoreg_out   (ID_memtoreg_out 	), //O, 1
    .ID_ALUop_out      (ID_ALUop_out    	), //O, 16
    .ID_vsrc1_out      (ID_vsrc1_out    	), //O, 26
    .ID_vsrc2_out      (ID_vsrc2_out    	), //O, 32
                                    
    .ID_reg_rt_out     (ID_reg_rt_out   	), //O, ??
    .ID_HI_we_out      (ID_HI_we_out    	), //O, 5 
    .ID_LO_we_out      (ID_LO_we_out    	), //O, 32
	.ID_inst           (ID_inst         	),
	.ID_src1           (ID_src1         	),
	.ID_src2           (ID_src2         	),
	.ID_eret_out       (ID_eret_out         ),
    .ID_syscall_out    (ID_syscall_out      ),
    .ID_break_out      (ID_break_out        ),
    .ID_no_inst_out    (ID_no_inst_out      ),
    .CP0_STATUS        (CP0_STATUS          ),
    .CP0_CAUSE         (CP0_CAUSE           ),
    .CP0_COMPARE       (CP0_COMPARE         ),
    .CP0_COUNT         (CP0_COUNT           ),
    .CP0_EPC           (CP0_EPC             ),
    .CP0_BADVADDR      (CP0_BADVADDR        ),
    .ID_clear          (ID_clear            ),
	.IF_BD             (IF_BD               ), 
	.IF_inst_addr_err  (IF_inst_addr_err    ),
    .ID_delay_slot     (ID_delay_slot       ),
	.ID_BD_out         (ID_BD_out           ),
	.ID_inst_addr_err_out(ID_inst_addr_err_out),
	.ID_interrupt_out  (ID_interrupt_out    ),
	.IF_interrupt      (IF_interrupt        )
    );


EXE_stage EXE_stage(
    .clk               (clk             	), //I, 1
    .resetn            (resetn          	), //I, 1	
	.EXE_stall         (EXE_stall			),
	
    .ID_pc             (ID_pc_out      		), //I, ??
    .ID_inst           (ID_inst_out      	), //I, 5 
	
    .ID_src1           (ID_src1_out         ), //I, 32
    .ID_src2           (ID_src2_out         ), //I, 32
    .ID_dest           (ID_dest_out         ), //I, 32
    .ID_memtoreg       (ID_memtoreg_out     ), //O, ??
    .ID_ALUop          (ID_ALUop_out        ), //O, 5
    .ID_vsrc1          (ID_vsrc1_out        ), //O, 32
    .ID_vsrc2          (ID_vsrc2_out        ), //O, 1
    .ID_reg_rt         (ID_reg_rt_out       ), //O, 4
    .ID_HI_we          (ID_HI_we_out        ), //O, 32
    .ID_LO_we          (ID_LO_we_out        ),  //O, 32
	
	.EXE_srcA_for      (EXE_srcA_for        ), //I, ??
    .EXE_srcB_for      (EXE_srcB_for        ), //I, 5 
    .EXE_reg_rt_for    (EXE_reg_rt_for      ), //I, 32
    .MEM_for           (MEM_for             ), //O, ??
    .WB_for            (WB_for              ), //O, 5
	
    .EXE_pc_out        (EXE_pc_out          ), //O, 32
    .EXE_inst_out      (EXE_inst_out        ), //O, 1
    .EXE_src1_out      (EXE_src1_out        ), //O, 4
    .EXE_src2_out      (EXE_src2_out        ), //O, 32
    .EXE_dest_out      (EXE_dest_out        ),  //O, 32
    .EXE_memtoreg_out  (EXE_memtoreg_out    ), //O, ??
    .EXE_result_out    (EXE_result_out      ), //O, 5
    .EXE_reg_rt_out    (EXE_reg_rt_out      ), //O, 32
	
    .EXE_HI_we_out     (EXE_HI_we_out       ), //O, 1
    .EXE_LO_we_out     (EXE_LO_we_out       ), //O, 4
    .EXE_reg1_for      (EXE_reg1_for        ), //O, 32
	.EXE_vsrc1         (EXE_vsrc1           ),
	
    .EXE_inst          (EXE_inst            ),
	.EXE_src1          (EXE_src1            ),
    .EXE_src2          (EXE_src2            ),
    .EXE_dest          (EXE_dest            ),
	.EXE_memaddr       (EXE_memaddr         ),
    .EXE_data_sram_ren (EXE_data_sram_ren   ),
	.HI_out            (HI_to_write         ),
	.LO_out            (LO_to_write         ),
	.EXE_mul_div_validout  (EXE_mul_div_validout),
	.EXE_overflow      (EXE_overflow        ),
    .rdata_addr_err    (rdata_addr_err      ),
    .wdata_addr_err    (wdata_addr_err      ),
	.EXE_break_out     (EXE_break           ),
	.EXE_BD_out        (EXE_BD              ),
	.EXE_inst_addr_err_out(inst_addr_err    ),
	.EXE_no_inst_out   (EXE_no_inst         ),
	.EXE_syscall_out   (EXE_syscall         ),
    .EXE_clear         (EXE_clear           ),
    .EXE_pc            (EXE_pc              ),
	.ID_break          (ID_break_out        ),
	.ID_syscall        (ID_syscall_out      ),
	.ID_no_inst        (ID_no_inst_out      ),
	.ID_BD             (ID_BD_out           ),
    .ID_inst_addr_err  (ID_inst_addr_err_out),
	.CP0_wdata         (CP0_wdata           ),
    .MTC0_waddr        (MTC0_waddr          ),
    .ID_interrupt      (ID_interrupt_out    ),
    .EXE_interrupt_out (EXE_interrupt       )
);


MEM_stage MEM_stage(
    .clk               (clk                 ), //I, 1
    .resetn            (resetn              ), //I, 1
                                    
    .EXE_pc            (EXE_pc_out          ), //I, ??
    .EXE_inst          (EXE_inst_out        ), //I, 5
    .EXE_src1          (EXE_src1_out        ), //I, 32
    .EXE_src2          (EXE_src2_out        ),        
	.EXE_dest          (EXE_dest_out        ),
	.EXE_memtoreg      (EXE_memtoreg_out    ),
	.EXE_result        (EXE_result_out      ),
	.EXE_reg_rt        (EXE_reg_rt_out      ),
	.EXE_memaddr       (EXE_memaddr         ),
	.EXE_data_sram_ren (EXE_data_sram_ren   ),
	.MEM_reg_rt_for    (MEM_reg_rt_for      ),
	.WB_for            (WB_for              ),
	
	.data_sram_rdata   (data_sram_rdata     ),
	.data_sram_en      (data_sram_en        ),
	.data_sram_wen     (data_sram_wen       ),
	.data_sram_wdata   (data_sram_wdata     ),
	.data_sram_addr    (data_sram_addr      ),
	
	.MEM_pc_out        (MEM_pc_out          ),
	.MEM_inst_out      (MEM_inst_out        ),
	.MEM_reg_we_out    (MEM_reg_we_out      ),
	.MEM_dest_out      (MEM_dest_out        ),
	.MEM_memtoreg_out  (MEM_memtoreg_out    ),
	.MEM_result_out    (MEM_result_out      ),
	.MEM_mem_rdata_out (MEM_mem_rdata_out   ),
	.MEM_reg_rt_out    (MEM_reg_rt_out      ),
    .MEM_for           (MEM_for             ),               
	.MEM_src2          (MEM_src2            ),
    .MEM_delay_slot    (MEM_delay_slot      )
    );


WB_stage WB_stage(
    .clk               (clk                 ), //I, 1
    .resetn            (resetn              ), //I, 1
                                    
    .MEM_pc            (MEM_pc_out          ), //I, ??
    .MEM_inst          (MEM_inst_out        ), //I, 5
    .MEM_reg_we        (MEM_reg_we_out      ), //I, 32
    .MEM_dest          (MEM_dest_out        ),
	.MEM_memtoreg      (MEM_memtoreg_out    ),
	.MEM_result        (MEM_result_out      ),
	.MEM_mem_rdata     (MEM_mem_rdata_out   ),
	.MEM_reg_rt        (MEM_reg_rt_out      ),

    .WB_reg_write_en   (WB_reg_write_en     ), //O, 1
    .WB_reg_wdata      (WB_reg_wdata        ), //O, 5
    .WB_reg_addr      (WB_reg_addr         ),  //O, 32
    .WB_pc             (WB_pc               ),
    .WB_for            (WB_for              )
    );


regfile regfile(
    .clk               (clk                 ), //I, 1

    .raddr1            (ID_reg_raddr1       ), //I, 5
    .rdata1            (ID_reg_rdata1       ), //O, 32

    .raddr2            (ID_reg_raddr2       ), //I, 5
    .rdata2            (ID_reg_rdata2       ), //O, 32

    .we                (WB_reg_write_en     ), //I, 1
    .waddr             (WB_reg_addr         ), //I, 5
    .wdata             (WB_reg_wdata        )  //O, 32
    );

stall stall(
	.WB_reg_dst        (WB_reg_addr         ),
	
	.MEM_src2          (MEM_src2            ),
	.MEM_reg_dst       (MEM_dest_out        ),
	.MEM_inst          (MEM_inst_out        ),
	
	.EXE_src1          (EXE_src1            ),
	.EXE_src2          (EXE_src2            ),
	.EXE_reg_dst       (EXE_dest            ),
	.EXE_inst          (EXE_inst            ),
	.ID_eret           (ID_eret_out         ),
	.ID_src1           (ID_src1             ),
	.ID_src2           (ID_src2             ),
	.ID_inst           (ID_inst             ),
	.EXE_mul_div_validout (EXE_mul_div_validout),
	
	.IF_stall          (IF_stall            ),
	.ID_stall          (ID_stall            ),
	.EXE_stall         (EXE_stall           ),
	.ID_vsrc1_for      (ID_vsrc1_for        ),
	.ID_vsrc2_for      (ID_vsrc2_for        ),
	.EXE_srcA_for      (EXE_srcA_for        ),
	.EXE_srcB_for      (EXE_srcB_for        ),
	.EXE_reg_rt_for    (EXE_reg_rt_for      ),
	.MEM_reg_rt_for    (MEM_reg_rt_for      )
	);
	
	
	always @(posedge clk)
	begin
		if (EXE_HI_we_out)
			HI <= EXE_vsrc1;
		else if (EXE_mul_div_validout)
			HI <= HI_to_write;
			
		if (EXE_LO_we_out)
			LO <= EXE_vsrc1;
		else if (EXE_mul_div_validout)
			LO <= LO_to_write;
	end	
	
	assign inst_sram_wen   = 4'b0;
	assign inst_sram_wdata = 32'b0;
	
	assign debug_wb_pc       = WB_pc;
	assign debug_wb_rf_wen   = {4{WB_reg_write_en}};
	assign debug_wb_rf_wnum  = WB_reg_addr;
	assign debug_wb_rf_wdata = WB_reg_wdata;
	
	

    
    wire [31:0] status_mask;
    wire [31:0] cause_mask;
    reg         temp;
    wire [31:0] CP0_CAUSE_towrite;
    assign status_mask = 32'h0000ff03;
    assign cause_mask = 32'h00000300;
    assign interrupt = (CP0_CAUSE[15:8] & CP0_STATUS[15:8] || CP0_CAUSE[30] & CP0_STATUS[15]) && CP0_STATUS[0] && !CP0_STATUS[1];
    assign CP0_CAUSE_towrite[31] = (CP0_STATUS[1]) ? CP0_CAUSE[31] : EXE_BD;
    assign CP0_CAUSE_towrite[30] = (MTC0_waddr == 5'd11 && !EXE_clear && !EXE_stall) ? 1'b0 : CP0_CAUSE[30]| CP0_COMPARE == CP0_COUNT;
    assign CP0_CAUSE_towrite[29:16] = 14'd0;
   // assign CP0_CAUSE_towrite[15:10] = hard_interrupt;
    assign CP0_CAUSE_towrite[9:8] = CP0_CAUSE[9:8];
    assign CP0_CAUSE_towrite[7] = 1'b0;
    assign CP0_CAUSE_towrite[6:2] = (inst_addr_err || rdata_addr_err) ? 5'h4 :
                                    (wdata_addr_err) ? 5'h5 :
                                    (EXE_overflow) ? 5'hc :
                                    (EXE_syscall) ? 5'h8 :
                                    (EXE_break) ? 5'h9 :
                                    (EXE_no_inst) ? 5'ha : 
                                    (interrupt) ? 5'h0 : 5'h0;
    assign CP0_CAUSE_towrite[1:0] = 2'b0;
	
    assign IF_clear = EXE_break || EXE_syscall || EXE_no_inst || EXE_overflow || inst_addr_err || rdata_addr_err || wdata_addr_err || EXE_interrupt;
    assign ID_clear =  EXE_break || EXE_syscall || EXE_no_inst || EXE_overflow || inst_addr_err || rdata_addr_err || wdata_addr_err|| EXE_interrupt;
    assign EXE_clear = EXE_break || EXE_syscall || EXE_no_inst || EXE_overflow || inst_addr_err || rdata_addr_err || wdata_addr_err|| EXE_interrupt;
    
    //CP0_STATUS
    always @(posedge clk)
        begin
            if (!resetn)
                CP0_STATUS <= 32'h00400000;
            else if (EXE_clear)
                CP0_STATUS <= CP0_STATUS | 32'h00000002;
            else if (ID_eret_out)
                CP0_STATUS <= CP0_STATUS & 32'hfffffffd;
            else if (MTC0_waddr == 5'd12 && !EXE_clear && !EXE_stall)
                CP0_STATUS <= (CP0_wdata & status_mask) | (CP0_STATUS & ~status_mask);
        end

    //CP0_CAUSE
    always @(posedge clk)
        begin
                
            if (!resetn)
                CP0_CAUSE <= 32'h00000000;
            else if (EXE_clear)
            begin
                CP0_CAUSE[31]    <= CP0_CAUSE_towrite[31];
                CP0_CAUSE[30:16] <= CP0_CAUSE_towrite[30:16];
                CP0_CAUSE[15]    <= hard_interrupt[5] | CP0_CAUSE_towrite[30];
                CP0_CAUSE[14:10] <= hard_interrupt[4:0]; 
                CP0_CAUSE[9:0]   <= CP0_CAUSE_towrite[9:0];
            end
            else if (MTC0_waddr == 5'd13 && !EXE_clear && !EXE_stall)
            begin
                CP0_CAUSE[31]    <= CP0_CAUSE[31];
                CP0_CAUSE[30:16] <= CP0_CAUSE_towrite[30:16];
                CP0_CAUSE[15]    <= hard_interrupt[5] | CP0_CAUSE_towrite[30];
                CP0_CAUSE[14:10] <= hard_interrupt[4:0]; 
                CP0_CAUSE[9:8]   <= CP0_wdata[9:8] & cause_mask[9:8];
                CP0_CAUSE[7:0]   <= CP0_CAUSE[7:0];
            end
            else
            begin
                CP0_CAUSE[31]    <= CP0_CAUSE[31];
                CP0_CAUSE[30:16] <= CP0_CAUSE_towrite[30:16];
                CP0_CAUSE[15]    <= hard_interrupt[5] | CP0_CAUSE_towrite[30];
                CP0_CAUSE[14:10] <= hard_interrupt[4:0]; 
                CP0_CAUSE[9:0]   <= CP0_CAUSE[9:0];
            end
        end
        
    //CP0_COMPARE
        always @(posedge clk)
            begin
                if (!resetn)
                    CP0_COMPARE <= 32'h00000000;
                else if (MTC0_waddr == 5'd11 && !EXE_clear && !EXE_stall)
                    CP0_COMPARE <= CP0_wdata;
            end
         
    //CP0_COUNT
            always @(posedge clk)
                begin
                    if (!resetn)
                    begin
                        CP0_COUNT <= 32'h00000000;
                        temp <= 0;
                    end
                    else if (MTC0_waddr == 5'd9 && !EXE_clear && !EXE_stall)
                    begin
                        CP0_COUNT <= CP0_wdata;
                        temp <= 0;
                    end
                    else if (temp == 1'b1)
                    begin
                        CP0_COUNT <= CP0_COUNT + 1;
                        temp <= 0;
                    end
                    else temp <= temp + 1;
                end
                
                
    //CP0_BADVADDR
                always @(posedge clk)
                    begin
                        if (!resetn)
                            CP0_BADVADDR <= 32'h00000000;
                        else if (rdata_addr_err || wdata_addr_err)
                            CP0_BADVADDR <= CP0_wdata;  
                        else if (inst_addr_err)
                            CP0_BADVADDR <= EXE_pc;  
                        else if (MTC0_waddr == 5'd8 && !EXE_clear && !EXE_stall)
                            CP0_BADVADDR <= CP0_wdata;                    
                    end


    //CP0_EPC
    always @(posedge clk)
        begin
            if (!resetn)
                CP0_EPC <= 32'h00000000;
            else if ((EXE_clear) && !CP0_STATUS[1])
                if (EXE_BD && !inst_addr_err)
                    CP0_EPC <= EXE_pc - 4;
                else 
                    CP0_EPC <= EXE_pc;
            else if (inst_addr_err)
                CP0_EPC <= EXE_pc;
            else if (MTC0_waddr == 5'd14 && !EXE_clear && !EXE_stall)
                CP0_EPC <= CP0_wdata;
        end	
endmodule
