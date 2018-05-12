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
    output wire [31:0] debug_wb_rf_wdata
);

	reg [31:0] HI;
	reg [31:0] LO;

//regfile	
	wire [31:0] ID_reg_rdata1;
    wire [31:0] ID_reg_rdata2;
	
//next_pc
	wire [31:0] next_pc;
	
//IF_stage
	wire [31:0] IF_pc;
	wire [31:0] IF_inst;
	
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
	wire [31:0] EXE_for;	
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
	wire [2:0]  ID_vsrc1_for;    //000: stay   001: EXE_for   010: MEM_for  011: WB_for 100: EXE_reg1_for 
	wire [1:0]  ID_vsrc2_for;
	wire [1:0]  EXE_srcA_for;    //00: stay    01: MEM_for    10: WB_for
	wire [1:0]  EXE_srcB_for;
	wire [1:0]  EXE_reg_rt_for;
	wire        MEM_reg_rt_for;   //0:  stay    1: WB_for 
	



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
    .next_pc           (next_pc         	)  //O, 32
    );


IF_stage IF_stage(
    .clk               (clk             	), //I, 1
    .resetn            (resetn          	), //I, 1
    .IF_stall          (IF_stall            ),                  
    .next_pc           (next_pc         	), //I, 32
                                    
    .inst_sram_rdata   (inst_sram_rdata 	), //I, 32
    .inst_sram_addr    (inst_sram_addr  	),                     
    .IF_pc             (IF_pc           	), //O, 32  
    .IF_inst           (IF_inst         	)  //O, 32
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
	
    .EXE_for           (EXE_for         	), //I, 1
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
	.ID_src2           (ID_src2         	)
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
    .EXE_for           (EXE_for             ),  //O, 32
	.EXE_vsrc1         (EXE_vsrc1           ),
    .EXE_inst          (EXE_inst            ),
	.EXE_src1          (EXE_src1            ),
    .EXE_src2          (EXE_src2            ),
    .EXE_dest          (EXE_dest            ),
	.EXE_memaddr       (EXE_memaddr         ),
    .EXE_data_sram_ren (EXE_data_sram_ren   ),
	.HI_out            (HI_to_write         ),
	.LO_out            (LO_to_write         ),
	.EXE_mul_div_validout  (EXE_mul_div_validout)
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
	.MEM_src2          (MEM_src2            )
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


endmodule
