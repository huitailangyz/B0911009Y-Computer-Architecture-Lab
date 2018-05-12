module nextpc(
    input  wire [31:0] IF_pc,
 
    input  wire        ID_br_taken,     //1: branch taken, go to the branch target
    input  wire        ID_br_type,     //1: target is PC+offset
    input  wire        ID_j_type,      //1: target is PC||offset
    input  wire        ID_jr_type,     //1: target is GR value
    input  wire [15:0] ID_br_index,    //offset for type "br"
    input  wire [25:0] ID_j_index,     //instr_index for type "j"
    input  wire [31:0] ID_jr_index,    //target for type "jr"
    output wire        inst_sram_en,
    output wire [31:0] next_pc,
    input  wire [31:0] CP0_EPC,
    input  wire        ID_eret
);

	assign inst_sram_en = 1;
	
	assign next_pc = (ID_eret) ? CP0_EPC : 
	                 (ID_j_type) ? {IF_pc[31:28],ID_j_index,2'b00} :
					 (ID_jr_type) ? ID_jr_index :
					 (ID_br_type & ID_br_taken) ? IF_pc + {{14{ID_br_index[15]}},ID_br_index,2'b00} :
					 IF_pc + 4;
endmodule