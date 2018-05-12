/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

`include "ls132r_define.h"

module ls132r_decode_stage(
  clock,
  reset,
  nmi_i,
  
  cpu_status_i,
  exbus_i,
  brbus_i,
  ex_int_i,
  irbus_i,
  wbbus_i,
  ejtag_inte_i,
  issuebus_o,
  dec_status_o
);

input                   clock;
input                   reset;
input                   nmi_i;

input  [`Lcpustbus-1:0] cpu_status_i;
input  [`Lexbus-1:0]    exbus_i;
input  [`Lbrbus-1:0]    brbus_i;
input                   ex_int_i;
input  [`Lirbus-1:0]    irbus_i;
input  [`Lwbbus-1:0]    wbbus_i;
input                   ejtag_inte_i;
output [`Lissuebus-1:0] issuebus_o;
output [`Ldecstbus-1:0] dec_status_o;


wire        kernel_mode = cpu_status_i[ 0: 0];
wire        super_mode  = cpu_status_i[ 1: 1];
wire        user_mode   = cpu_status_i[ 2: 2];
wire        cause_iv    = cpu_status_i[ 3: 3];
wire        status_bev  = cpu_status_i[ 4: 4];
wire        status_erl  = cpu_status_i[ 5: 5];
wire [ 2:0] status_cu   = cpu_status_i[ 8: 6];
wire [ 3:0] HWREna      = cpu_status_i[12: 9];
wire        debug_mode  = cpu_status_i[13:13];

wire        ex_valid        = exbus_i[ 0: 0];
wire        ex_valid_fetch  = exbus_i[ 1: 1];
wire [ 5:0] ex_excode_fetch = exbus_i[ 7: 2];

wire        br_taken    = brbus_i[ 0: 0]; 
wire        br_not_taken= brbus_i[ 1: 1];
wire        br_likely   = brbus_i[ 2: 2];
wire [31:0] br_base     = brbus_i[34: 3];
wire [31:0] br_offset   = brbus_i[66:35];

wire        ex_int      = ex_int_i;

wire        ir_valid    = irbus_i[ 0: 0];
wire [31:0] ir_pc       = irbus_i[32: 1];
wire [31:0] ir_inst     = irbus_i[64:33];
wire        ir_bd       = irbus_i[65:65];
wire        ir_ex_adel  = irbus_i[66:66];
wire        ir_ex_dib   = irbus_i[67:67];

wire        wb_gr_wen       = wbbus_i[  0: 0];
wire [ 4:0] wb_gr_num       = wbbus_i[  5: 1];
wire [31:0] wb_gr_value     = wbbus_i[ 37: 6];
wire        wb_fr_wen       = wbbus_i[ 38:38];
wire [ 4:0] wb_fr_num       = wbbus_i[ 43:39];
wire [31:0] wb_fr_value     = wbbus_i[ 75:44];
wire        wb_fr_wen_h     = wbbus_i[ 76:76];
wire [31:0] wb_fr_value_h   = wbbus_i[108:77];

wire        issue_valid      ;
wire        issue_bd         ;
wire        issue_ex         ;
wire [ 5:0] issue_excode     ;
wire [31:0] issue_pc         ;
wire [ 7:0] issue_op         ;
wire [ 4:0] issue_fmt        ;
wire        issue_float_mult ;
wire [ 6:0] issue_dest       ;
wire        issue_v1_en      ;
wire [31:0] issue_v1         ;
wire        issue_v2_en      ;
wire [31:0] issue_v2         ;
wire        issue_v3_en      ;
wire [31:0] issue_v3         ;
wire        issue_v1_h_en    ;
wire [31:0] issue_v1_h       ;
wire        issue_v2_h_en    ;
wire [31:0] issue_v2_h       ;
wire        issue_v3_h_en    ;
wire [31:0] issue_v3_h       ;

assign issuebus_o[  0:  0] = issue_valid      ;
assign issuebus_o[  1:  1] = issue_bd         ;
assign issuebus_o[  2:  2] = issue_ex         ;
assign issuebus_o[  8:  3] = issue_excode     ;
assign issuebus_o[ 40:  9] = issue_pc         ;
assign issuebus_o[ 48: 41] = issue_op         ;
assign issuebus_o[ 53: 49] = issue_fmt        ;
assign issuebus_o[ 54: 54] = issue_float_mult ;
assign issuebus_o[ 61: 55] = issue_dest       ;
assign issuebus_o[ 62: 62] = issue_v1_en      ;
assign issuebus_o[ 94: 63] = issue_v1         ;
assign issuebus_o[ 95: 95] = issue_v2_en      ;
assign issuebus_o[127: 96] = issue_v2         ;
assign issuebus_o[128:128] = issue_v3_en      ;
assign issuebus_o[160:129] = issue_v3         ;
assign issuebus_o[161:161] = issue_v1_h_en    ;
assign issuebus_o[193:162] = issue_v1_h       ;
assign issuebus_o[194:194] = issue_v2_h_en    ;
assign issuebus_o[226:195] = issue_v2_h       ;
assign issuebus_o[227:227] = issue_v3_h_en    ;
assign issuebus_o[259:228] = issue_v3_h       ;

wire        ctrl_stall_in_ir;
wire        br_in_ir        ;
wire        wait_wakeup     ;
wire        bd_in_ir        ;
wire [31:0] bd_pc           ;
wire        idle_in_ir      ;

assign dec_status_o[ 0: 0] = ctrl_stall_in_ir;
assign dec_status_o[ 1: 1] = br_in_ir        ;
assign dec_status_o[ 2: 2] = wait_wakeup     ;
assign dec_status_o[ 3: 3] = bd_in_ir        ;
assign dec_status_o[35: 4] = bd_pc           ;
assign dec_status_o[36:36] = idle_in_ir      ;

/*
 *   Internal Logic 
 */
wire [ 7:0] dec_op;
wire [ 4:0] dec_fmt;
wire [ 6:0] dec_dest;
wire        dec_ex;
wire [ 5:0] dec_excode;
wire        dec_ex_nmi;
wire        dec_ex_int;
wire        dec_ex_sys;
wire        dec_ex_bp;
wire        dec_ex_ri;
wire        dec_ex_cpu;
wire [ 1:0] dec_ex_ce;
wire        dec_ex_dbp;
wire        dec_ex_wait;

wire        dec_v1_rs;
wire        dec_v1_rt;
wire        dec_v1_imm_upper;
wire        dec_v1_fs; 
wire        dec_v1_fcr;

wire        dec_v2_rs;
wire        dec_v2_rt;
wire        dec_v2_imm_sign_extend;
wire        dec_v2_imm_zero_extend;
wire        dec_v2_imm_sa;
wire        dec_v2_rd_sel;
wire        dec_v2_ft;   
wire        dec_v2_cc; 

wire        dec_v3_rs;
wire        dec_v3_rt;
wire        dec_v3_imm_offset;
wire        dec_v3_imm_instr_index;
wire        dec_v3_imm_pos_size;
wire        dec_v3_fs;
wire        dec_v3_ft;
wire        dec_v3_fr;

wire        decdest_rd;
wire        decdest_rt;
wire        decdest_gr31;
wire        decdest_fd;
wire        decdest_ft;
wire        decdest_fs;
wire        decdest_fcr;
wire        decdest_cc; 
wire        decdest_ce;

wire        v1_en;
wire        v2_en;
wire        v3_en;
wire [31:0] v1;
wire [31:0] v2;
wire [31:0] v3;


wire [ 5:0] op          = ir_inst[31:26]; 
wire [ 4:0] rs          = ir_inst[25:21];   
wire [ 4:0] rt          = ir_inst[20:16];  
wire [ 4:0] rd          = ir_inst[15:11];  
wire [ 4:0] sa          = ir_inst[10: 6]; 
wire [ 5:0] func        = ir_inst[ 5: 0]; 
wire [15:0] imm         = ir_inst[15: 0]; 
wire [15:0] offset      = ir_inst[15: 0];
wire [ 2:0] cp0_sel     = ir_inst[ 2: 0];  
wire [ 2:0] cc_src      = ir_inst[20:18];
wire        nd          = ir_inst[   17];
wire        tf          = ir_inst[   16];
wire [ 4:0] fmt         = ir_inst[25:21];
wire [ 4:0] fr          = ir_inst[25:21];
wire [ 4:0] ft          = ir_inst[20:16];
wire [ 4:0] fs          = ir_inst[15:11];
wire [ 4:0] fd          = ir_inst[10: 6];
wire [ 2:0] cc_fcmp     = ir_inst[10: 8];
wire [25:0] instr_index = ir_inst[25: 0]; 

wire [63:0] op_d;
wire [31:0] rs_d;
wire [31:0] rt_d;
wire [31:0] rd_d;
wire [31:0] sa_d;
wire [63:0] func_d;

ls132r_decoder_6_64 u1_dec6to64(.in(op[5:0]  ), .out(op_d[63:0]  ));
ls132r_decoder_5_32 u1_dec5to32(.in(rs[4:0]  ), .out(rs_d[31:0]  ));
ls132r_decoder_5_32 u2_dec5to32(.in(rt[4:0]  ), .out(rt_d[31:0]  ));
ls132r_decoder_5_32 u3_dec5to32(.in(rd[4:0]  ), .out(rd_d[31:0]  ));
ls132r_decoder_5_32 u4_dec5to32(.in(sa[4:0]  ), .out(sa_d[31:0]  ));
ls132r_decoder_6_64 u2_dec6to64(.in(func[5:0]), .out(func_d[63:0]));


wire        fr_rvalid0;
wire [ 4:0] fr_raddr0;
wire [31:0] fr_rvalue0 = 32'd0;
wire        fr_rvalid1;
wire [ 4:0] fr_raddr1;
wire [31:0] fr_rvalue1 = 32'd0;
wire        fr_wvalid0;
wire [ 4:0] fr_waddr0;
wire [31:0] fr_wvalue0 = 32'd0;
wire        fr_fwd0    = 1'b0;
wire        fr_fwd1    = 1'b0;

/****** CPU Arithmetic ******/
wire inst_ADD       = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h20];

wire inst_ADDI      = 1'b0; //op_d[6'h08];

wire inst_ADDIU     = op_d[6'h09];

wire inst_ADDU      = op_d[6'h00]&sa_d[5'h00]&func_d[6'h21];        

wire inst_CLO       = 1'b0; //op_d[6'h1c]&sa_d[5'h00]&func_d[6'h21];
                                               
wire inst_CLZ       = 1'b0; //op_d[6'h1c]&sa_d[5'h00]&func_d[6'h20];
 
wire inst_DIV       = 1'b0; //op_d[6'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h1a];
        
wire inst_DIVU      = 1'b0; //op_d[6'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h1b];

wire inst_MADD      = 1'b0; //op_d[6'h1c]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h00];
                                                                       
wire inst_MADDU     = 1'b0; //op_d[6'h1c]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h01];
                                               
wire inst_MSUB      = 1'b0; //op_d[6'h1c]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h04];
                                                                       
wire inst_MSUBU     = 1'b0; //op_d[6'h1c]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h05];

wire inst_MUL       = 1'b0; //op_d[6'h1c]&sa_d[5'h00]&func_d[6'h02];
    
wire inst_MULT      = 1'b0; //op_d[6'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h18];
                                                                       
wire inst_MULTU     = 1'b0; //op_d[6'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h19];
                                               
wire inst_SLT       = op_d[6'h00]&sa_d[5'h00]&func_d[6'h2a];

wire inst_SLTI      = op_d[6'h0a];

wire inst_SLTIU     = op_d[6'h0b];

wire inst_SLTU      = op_d[6'h00]&sa_d[5'h00]&func_d[6'h2b];

wire inst_SUB       = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h22];

wire inst_SUBU      = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h23];

wire inst_SEB       = 1'b0; //op_d[6'h1f]&rs_d[5'h00]&sa_d[5'h10]&func_d[6'h20];

wire inst_SEH       = 1'b0; //op_d[6'h1f]&rs_d[5'h00]&sa_d[5'h18]&func_d[6'h20];

/****** CPU Branch and Jump ******/
wire inst_BEQ       = op_d[6'h04];

wire inst_BGEZ      = 1'b0; //op_d[6'h01]&rt_d[5'h01];        

wire inst_BGEZAL    = 1'b0; //op_d[6'h01]&rt_d[5'h11];    

wire inst_BGTZ      = 1'b0; //op_d[6'h07]&rt_d[5'h00];        

wire inst_BLEZ      = 1'b0; //op_d[6'h06]&rt_d[5'h00];

wire inst_BLTZ      = 1'b0; //op_d[6'h01]&rt_d[5'h00];

wire inst_BLTZAL    = 1'b0; //op_d[6'h01]&rt_d[5'h10];

wire inst_BNE       = op_d[6'h05];
    
wire inst_J         = op_d[6'h02];
    
wire inst_JAL       = op_d[6'h03];

wire inst_JALR      = 1'b0; //op_d[6'h00]&rt_d[5'h00]&sa_d[5'h00]&func_d[6'h09];

wire inst_JR        = op_d[6'h00]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h08];
    
wire inst_JALR_HB   = 1'b0; //op_d[6'h00]&rt_d[5'h00]&sa_d[5'h10]&func_d[6'h09];

wire inst_JR_HB     = 1'b0; //op_d[6'h00]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h10]&func_d[6'h08];


/****** CPU Instruction Control ******/
//wire inst_EHB       = op_d[6'h00]&rs_d[5'h00]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h03]&func_d[6'h00];

//wire inst_NOP       = op_d[6'h00]&rs_d[5'h00]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h00];

//wire inst_SSNOP     = op_d[6'h00]&rs_d[5'h00]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h01]&func_d[6'h00];


/****** CPU Load, Store and Memory Control ******/
wire inst_LB        = 1'b0; //op_d[6'h20];
    
wire inst_LBU       = 1'b0; //op_d[6'h24];

wire inst_LH        = 1'b0; //op_d[6'h21];
    
wire inst_LHU       = 1'b0; //op_d[6'h25];
    
wire inst_LL        = 1'b0; //op_d[6'h30];

wire inst_LW        = op_d[6'h23];
    
wire inst_LWL       = 1'b0; //op_d[6'h22];
    
wire inst_LWR       = 1'b0; //op_d[6'h26];
    
wire inst_PREF      = 1'b0; //op_d[6'h33];

wire inst_SB        = 1'b0; //op_d[6'h28];
    
wire inst_SC        = 1'b0; //op_d[6'h38];

wire inst_SH        = 1'b0; //op_d[6'h29];

wire inst_SW        = op_d[6'h2b];

wire inst_SWL       = 1'b0; //op_d[6'h2a];

wire inst_SWR       = 1'b0; //op_d[6'h2e];

wire inst_SYNC      = 1'b0; //op_d[6'h00]&rs_d[5'h00]&rt_d[5'h00]&rd_d[5'h00]&func_d[6'h0f];

wire inst_SYNCI     = 1'b0; //op_d[6'h01]&rt_d[5'h1f];


/****** CPU Logical ******/
wire inst_AND       = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h24];

wire inst_ANDI      = 1'b0; //op_d[6'h0c];

wire inst_LUI       = op_d[6'h0f]&rs_d[5'h00];

wire inst_NOR       = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h27];
                                               
wire inst_OR        = op_d[6'h00]&sa_d[5'h00]&func_d[6'h25];

wire inst_ORI       = 1'b0; //op_d[6'h0d];

wire inst_XOR       = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h26];

wire inst_XORI      = 1'b0; //op_d[6'h0e];


/****** CPU Insert/Extract ******/
wire inst_EXT       = 1'b0; //op_d[6'h1f]&func_d[6'h00];

wire inst_INS       = 1'b0; //op_d[6'h1f]&func_d[6'h04];

wire inst_WSBH      = 1'b0; //op_d[6'h1f]&rs_d[5'h00]&sa_d[5'h02]&func_d[6'h20];


/****** CPU Move ******/
wire inst_MFHI      = 1'b0; //op_d[6'h00]&rs_d[5'h00]&rt_d[5'h00]&sa_d[5'h00]&func_d[6'h10];
                                               
wire inst_MFLO      = 1'b0; //op_d[6'h00]&rs_d[5'h00]&rt_d[5'h00]&sa_d[5'h00]&func_d[6'h12];
                                               
wire inst_MOVF      = 1'b0; //op_d[6'h00]&(rt[1:0]==2'b00)&sa_d[5'h00]&func_d[6'h01];

wire inst_MOVN      = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h0b];
                                               
wire inst_MOVT      = 1'b0; //op_d[6'h00]&(rt[1:0]==2'b01)&sa_d[5'h00]&func_d[6'h01];

wire inst_MOVZ      = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h0a];

wire inst_MTHI      = 1'b0; //op_d[6'h00]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h11];
                                                                                   
wire inst_MTLO      = 1'b0; //op_d[6'h00]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h13];

wire inst_RDHWR     = 1'b0; //op_d[6'h1f]&sa_d[5'h00]&rs_d[5'h00]&func_d[6'h3b];


/****** CPU Shift ******/
wire inst_ROTR      = 1'b0; //op_d[6'h00]&rs_d[5'h01]&func_d[6'h02];

wire inst_ROTRV     = 1'b0; //op_d[6'h00]&sa_d[5'h01]&func_d[6'h06];

wire inst_SLL       = op_d[6'h00]&rs_d[5'h00]&func_d[6'h00];

wire inst_SLLV      = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h04];

wire inst_SRA       = 1'b0; //op_d[6'h00]&rs_d[5'h00]&func_d[6'h03];

wire inst_SRAV      = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h07];

wire inst_SRL       = 1'b0; //op_d[6'h00]&rs_d[5'h00]&func_d[6'h02];

wire inst_SRLV      = 1'b0; //op_d[6'h00]&sa_d[5'h00]&func_d[6'h06];


/****** CPU Trap ******/
wire inst_BREAK     = 1'b0; //op_d[6'h00]&func_d[6'h0d];
    
wire inst_SYSCALL   = 1'b0; //op_d[6'h00]&func_d[6'h0c];

wire inst_TEQ       = 1'b0; //op_d[6'h00]&func_d[6'h34];

wire inst_TEQI      = 1'b0; //op_d[6'h01]&rt_d[5'h0c];

wire inst_TGE       = 1'b0; //op_d[6'h00]&func_d[6'h30];

wire inst_TGEI      = 1'b0; //op_d[6'h01]&rt_d[5'h08];

wire inst_TGEIU     = 1'b0; //op_d[6'h01]&rt_d[5'h09];

wire inst_TGEU      = 1'b0; //op_d[6'h00]&func_d[6'h31];

wire inst_TLT       = 1'b0; //op_d[6'h00]&func_d[6'h32];

wire inst_TLTI      = 1'b0; //op_d[6'h01]&rt_d[5'h0a];

wire inst_TLTIU     = 1'b0; //op_d[6'h01]&rt_d[5'h0b];

wire inst_TLTU      = 1'b0; //op_d[6'h00]&func_d[6'h33];

wire inst_TNE       = 1'b0; //op_d[6'h00]&func_d[6'h36];

wire inst_TNEI      = 1'b0; //op_d[6'h01]&rt_d[5'h0e];


/****** Obsolete CPU Branch ******/
wire inst_BEQL      = 1'b0; //op_d[6'h14];    

wire inst_BGEZALL   = 1'b0; //op_d[6'h01]&rt_d[5'h13];        

wire inst_BGEZL     = 1'b0; //op_d[6'h01]&rt_d[5'h03];    

wire inst_BGTZL     = 1'b0; //op_d[6'h17]&rt_d[5'h00];

wire inst_BLEZL     = 1'b0; //op_d[6'h16]&rt_d[5'h00];

wire inst_BLTZALL   = 1'b0; //op_d[6'h01]&rt_d[5'h12];

wire inst_BLTZL     = 1'b0; //op_d[6'h01]&rt_d[5'h02];

wire inst_BNEL      = 1'b0; //op_d[6'h15];


/****** FPU Arithmetic ******/
wire fmt_s          = rs_d[`MIPS32_FMT_S];
wire fmt_w          = rs_d[`MIPS32_FMT_W];
wire fmt_d          = rs_d[`MIPS32_FMT_D];
wire fmt_ps         = rs_d[`MIPS32_FMT_PS];
wire fmt_l          = rs_d[`MIPS32_FMT_L];

wire inst_ABS_F     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&rt_d[5'h00]&func_d[6'h05];

wire inst_ADD_F     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&func_d[6'h00];

wire inst_DIV_F     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&func_d[6'h03];

wire inst_MUL_F     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&func_d[6'h02];

wire inst_NEG_F     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&func_d[6'h07];

wire inst_SUB_F     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&func_d[6'h01];

wire inst_MADD_F    = 1'b0; //op_d[6'h13]&(func_d[6'h10]|func_d[6'h11]|func_d[6'h16]);

wire inst_MSUB_F    = 1'b0; //op_d[6'h13]&(func_d[6'h18]|func_d[6'h19]|func_d[6'h1e]);

wire inst_NMADD_F   = 1'b0; //op_d[6'h13]&(func_d[6'h30]|func_d[6'h31]|func_d[6'h36]);

wire inst_NMSUB_F   = 1'b0; //op_d[6'h13]&(func_d[6'h38]|func_d[6'h39]|func_d[6'h3e]);

wire inst_RECIP     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h15];

wire inst_RSQRT     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h16];

wire inst_SQRT_F    = 1'b0; //op_d[6'h11]&&rt_d[5'h00]&&func_d[6'h04]&&(rs_d[5'h10]||rs_d[5'h11]);


/****** FPU Branch ******/
wire inst_BC1F      = 1'b0; //op_d[6'h11]&rs_d[5'h08]&(~nd)&(~tf);

wire inst_BC1T      = 1'b0; //op_d[6'h11]&rs_d[5'h08]&(~nd)&1'b0; //( tf);


/****** FPU Compare ******/
wire inst_C         = 1'b0;//op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&(sa[1:0]==2'b00)&(func[5:4]==2'b11);
wire inst_C_F       = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_F   ];
wire inst_C_UN      = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_UN  ];
wire inst_C_EQ      = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_EQ  ];
wire inst_C_UEQ     = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_UEQ ];
wire inst_C_OLT     = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_OLT ];
wire inst_C_ULT     = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_ULT ];
wire inst_C_OLE     = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_OLE ];
wire inst_C_ULE     = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_ULE ];
wire inst_C_SF      = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_SF  ];
wire inst_C_NGLE    = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_NGLE];
wire inst_C_SEQ     = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_SEQ ];
wire inst_C_NGL     = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_NGL ];
wire inst_C_LT      = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_LT  ];
wire inst_C_NGE     = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_NGE ];
wire inst_C_LE      = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_LE  ];
wire inst_C_NGT     = 1'b0;//inst_C&func_d[6'h30+`MIPS32_COND_NGT ];

/****** FPU Convert ******/
wire inst_ALNV_PS   = 1'b0; //op_d[6'h13]&func_d[6'h1e];

wire inst_CEIL_L    = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h0a];

wire inst_CEIL_W    = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h0e];

wire inst_CVT_D     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_w|fmt_l)&rt_d[5'h00]&func_d[6'h21];

wire inst_CVT_L     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h25];

wire inst_CVT_PS_S  = 1'b0; //op_d[6'h11]&fmt_s&func_d[6'h26];

wire inst_CVT_S_PL  = 1'b0; //op_d[6'h11]&fmt_ps&rt_d[5'h00]&func_d[6'h28];

wire inst_CVT_S_PU  = 1'b0; //op_d[6'h11]&fmt_ps&rt_d[5'h00]&func_d[6'h20];

wire inst_CVT_S     = 1'b0; //op_d[6'h11]&(fmt_d|fmt_w|fmt_l)&rt_d[5'h00]&func_d[6'h20];

wire inst_CVT_W     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h24];

wire inst_FLOOR_L   = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h0b];

wire inst_FLOOR_W   = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h0f];

wire inst_PLL_PS    = 1'b0; //op_d[6'h11]&fmt_ps&func_d[6'h2c];

wire inst_PLU_PS    = 1'b0; //op_d[6'h11]&fmt_ps&func_d[6'h2d];

wire inst_PUL_PS    = 1'b0; //op_d[6'h11]&fmt_ps&func_d[6'h2e];

wire inst_PUU_PS    = 1'b0; //op_d[6'h11]&fmt_ps&func_d[6'h2f];

wire inst_ROUND_L   = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h08];

wire inst_ROUND_W   = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h0c];

wire inst_TRUNC_L   = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h09];

wire inst_TRUNC_W   = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d)&rt_d[5'h00]&func_d[6'h0d];


/****** FPU Load, Store and Memory Control ******/
wire inst_LDC1      = 1'b0; //op_d[6'h35];

wire inst_LDXC1     = 1'b0; //op_d[6'h13]&rd_d[5'h00]&func_d[6'h01];

wire inst_LUXC1     = 1'b0; //op_d[6'h13]&rd_d[5'h00]&func_d[6'h05];

wire inst_LWC1      = 1'b0; //op_d[6'h31];

wire inst_LWXC1     = 1'b0; //op_d[6'h13]&rd_d[5'h00]&func_d[6'h00];

wire inst_PREFX     = 1'b0; //op_d[6'h13]&sa_d[5'h00]&func_d[6'h0f];

wire inst_SDC1      = 1'b0; //op_d[6'h3d];

wire inst_SDXC1     = 1'b0; //op_d[6'h13]&rd_d[5'h00]&func_d[6'h09];
  
wire inst_SUXC1     = 1'b0; //op_d[6'h13]&rd_d[5'h00]&func_d[6'h0d];

wire inst_SWC1      = 1'b0; //op_d[6'h39];
    
wire inst_SWXC1     = 1'b0; //op_d[6'h13]&rd_d[5'h00]&func_d[6'h08];


/****** FPU Move ******/
wire inst_CFC1      = 1'b0; //op_d[6'h11]&rs_d[5'h02]&sa_d[5'h00]&func_d[6'h00];

wire inst_CTC1      = 1'b0; //op_d[6'h11]&rs_d[5'h06]&sa_d[5'h00]&func_d[6'h00];

wire inst_MFC1      = 1'b0; //op_d[6'h11]&rs_d[5'h00]&sa_d[5'h00]&func_d[6'h00];

wire inst_MFHC1     = 1'b0; //op_d[6'h11]&rd_d[5'h03]&sa_d[5'h00]&func_d[6'h00];

wire inst_FMOV      = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&rt_d[5'h00]&func_d[6'h06];

wire inst_FMOVF     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&(rt[1:0]==2'b00)&func_d[6'h11];

wire inst_FMOVN     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&func_d[6'h13];

wire inst_FMOVT     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&(rt[1:0]==2'b01)&func_d[6'h11];

wire inst_FMOVZ     = 1'b0; //op_d[6'h11]&(fmt_s|fmt_d|fmt_ps)&func_d[6'h12];

wire inst_MTC1      = 1'b0; //op_d[6'h11]&rs_d[5'h04]&sa_d[5'h00]&func_d[6'h00];

wire inst_MTHC1     = 1'b0; //op_d[6'h11]&rd_d[5'h07]&sa_d[5'h00]&func_d[6'h00];


/****** Obsolete FPU Branch ******/
wire inst_BC1FL     = 1'b0; //op_d[6'h11]&rs_d[5'h08]&( nd)&(~tf);

wire inst_BC1TL     = 1'b0; //op_d[6'h11]&rs_d[5'h08]&( nd)&( tf);


/****** Coprocessor Branch ******/
wire inst_BC2F      = 1'b0; //op_d[6'h12]&rs_d[5'h08]&(~nd)&(~tf);

wire inst_BC2T      = 1'b0; //op_d[6'h12]&rs_d[5'h08]&(~nd)&( tf);



/****** Coprocessor Execute ******/
wire inst_COP2      = 1'b0; //op_d[6'h12]&ir_inst[25];


/****** Coprocessor Load and Store ******/
wire inst_LDC2      = 1'b0; //op_d[6'h36];

wire inst_LWC2      = 1'b0; //op_d[6'h32];

wire inst_SDC2      = 1'b0; //op_d[6'h3e];

wire inst_SWC2      = 1'b0; //op_d[6'h3a];


/****** Coprocessor Move ******/
wire inst_CFC2      = 1'b0; //op_d[6'h12]&rs_d[5'h02];

wire inst_CTC2      = 1'b0; //op_d[6'h12]&rs_d[5'h06];

wire inst_MFC2      = 1'b0; //op_d[6'h12]&rd_d[5'h00];

wire inst_MFHC2     = 1'b0; //op_d[6'h12]&rd_d[5'h03];

wire inst_MTC2      = 1'b0; //op_d[6'h12]&rd_d[5'h04];

wire inst_MTHC2     = 1'b0; //op_d[6'h12]&rd_d[5'h07];


/****** Obsolete Coprocessor Branch ******/
wire inst_BC2FL     = 1'b0; //op_d[6'h12]&rs_d[5'h08]&( nd)&(~tf);

wire inst_BC2TL     = 1'b0; //op_d[6'h12]&rs_d[5'h08]&( nd)&( tf);


/****** Privileged Instructions ******/
wire inst_CACHE     = 1'b0; //op_d[6'h2f];

wire inst_CACHE0    = 1'b0;//op_d[6'h2f]&rt_d[5'h00];
wire inst_CACHE4    = 1'b0;//op_d[6'h2f]&rt_d[5'h04];
wire inst_CACHE8    = 1'b0;//op_d[6'h2f]&rt_d[5'h08];
wire inst_CACHE12   = 1'b0;//op_d[6'h2f]&rt_d[5'h0c];
wire inst_CACHE16   = 1'b0;//op_d[6'h2f]&rt_d[5'h10];
wire inst_CACHE20   = 1'b0;//op_d[6'h2f]&rt_d[5'h14];
wire inst_CACHE24   = 1'b0;//op_d[6'h2f]&rt_d[5'h18];
wire inst_CACHE28   = 1'b0;//op_d[6'h2f]&rt_d[5'h1c];

wire inst_CACHE1    = 1'b0;//op_d[6'h2f]&rt_d[5'h01];
wire inst_CACHE5    = 1'b0;//op_d[6'h2f]&rt_d[5'h05];
wire inst_CACHE9    = 1'b0;//op_d[6'h2f]&rt_d[5'h09];
wire inst_CACHE13   = 1'b0;//op_d[6'h2f]&rt_d[5'h0d];
wire inst_CACHE17   = 1'b0;//op_d[6'h2f]&rt_d[5'h11];
wire inst_CACHE21   = 1'b0;//op_d[6'h2f]&rt_d[5'h15];
wire inst_CACHE25   = 1'b0;//op_d[6'h2f]&rt_d[5'h19];
wire inst_CACHE29   = 1'b0;//op_d[6'h2f]&rt_d[5'h1d];

wire inst_CACHE2    = 1'b0;//op_d[6'h2f]&rt_d[5'h02];
wire inst_CACHE6    = 1'b0;//op_d[6'h2f]&rt_d[5'h06];
wire inst_CACHE10   = 1'b0;//op_d[6'h2f]&rt_d[5'h0a];
wire inst_CACHE14   = 1'b0;//op_d[6'h2f]&rt_d[5'h0e];
wire inst_CACHE18   = 1'b0;//op_d[6'h2f]&rt_d[5'h12];
wire inst_CACHE22   = 1'b0;//op_d[6'h2f]&rt_d[5'h16];
wire inst_CACHE26   = 1'b0;//op_d[6'h2f]&rt_d[5'h1a];
wire inst_CACHE30   = 1'b0;//op_d[6'h2f]&rt_d[5'h1e];

wire inst_CACHE3    = 1'b0;//op_d[6'h2f]&rt_d[5'h03];
wire inst_CACHE7    = 1'b0;//op_d[6'h2f]&rt_d[5'h07];
wire inst_CACHE11   = 1'b0;//op_d[6'h2f]&rt_d[5'h0b];
wire inst_CACHE15   = 1'b0;//op_d[6'h2f]&rt_d[5'h0f];
wire inst_CACHE19   = 1'b0;//op_d[6'h2f]&rt_d[5'h13];
wire inst_CACHE23   = 1'b0;//op_d[6'h2f]&rt_d[5'h17];
wire inst_CACHE27   = 1'b0;//op_d[6'h2f]&rt_d[5'h1b];
wire inst_CACHE31   = 1'b0;//op_d[6'h2f]&rt_d[5'h1f];

wire inst_DI        = 1'b0; //op_d[6'h10]&rs_d[5'h0b]&rd_d[5'h0c]&sa_d[5'h00]&func_d[6'h00];

wire inst_EI        = 1'b0; //op_d[6'h10]&rs_d[5'h0b]&rd_d[5'h0c]&sa_d[5'h00]&func_d[6'h20];

wire inst_ERET      = 1'b0; //op_d[6'h10]&rs_d[5'h10]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h18];

wire inst_MFC0      = 1'b0; //op_d[6'h10]&rs_d[5'h00]&sa_d[5'h00]&(func[5:3]==3'b0);

wire inst_MTC0      = 1'b0; //op_d[6'h10]&rs_d[5'h04]&sa_d[5'h0]&&(func[5:3]==3'b0);

wire inst_RDPGPR    = 1'b0; //op_d[6'h10]&rs_d[5'h0a]&sa_d[5'h00]&func_d[6'h00];

wire inst_TLBP      = 1'b0; //op_d[6'h10]&rs_d[5'h10]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h08];
    
wire inst_TLBR      = 1'b0; //op_d[6'h10]&rs_d[5'h10]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h01];

wire inst_TLBWI     = 1'b0; //op_d[6'h10]&rs_d[5'h10]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h02];

wire inst_TLBWR     = 1'b0; //op_d[6'h10]&rs_d[5'h10]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h06];

wire inst_WAIT      = 1'b0; //op_d[6'h10]&ir_inst[25]&func_d[6'h20];

wire inst_WRPGPR    = 1'b0; //op_d[6'h10]&rs_d[5'h0e]&sa_d[5'h00]&func_d[6'h00];


/****** EJTAG ******/ 
wire inst_DERET     = 1'b0; //op_d[6'h10]&rs_d[5'h10]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00]&func_d[6'h1f];

wire inst_SDBBP     = 1'b0; //op_d[6'h1c]&func_d[6'h3f];


wire inst_br        = inst_BEQ | inst_BGEZ | inst_BGEZAL | inst_BGTZ   
                     |inst_BLEZ | inst_BLTZ | inst_BLTZAL | inst_BNE  
                     |inst_J | inst_JAL | inst_JALR | inst_JR 
                     |inst_BEQL | inst_BGEZALL | inst_BGEZL | inst_BGTZL
                     |inst_BLEZL | inst_BLTZALL | inst_BLTZL | inst_BNEL
                     ;

wire inst_float_mult = inst_MUL_F;



/****** Internal opcode generation  ******/
assign dec_op[7] = inst_SYNC|inst_ERET
                  |inst_MFC0|inst_MTC0
                  |inst_LB|inst_LH|inst_LW|inst_LBU|inst_LHU|inst_LL
                  |inst_SB|inst_SH|inst_SW|inst_SC
                  |inst_LWL|inst_LWR|inst_SWL|inst_SWR
                  |inst_DERET
                  ;
            
assign dec_op[6] = 1'b0;    
                
assign dec_op[5] = inst_TEQ|inst_TEQI|inst_TNE|inst_TNEI|inst_TLT|inst_TLTI
                  |inst_TLTU|inst_TLTIU|inst_TGE|inst_TGEI|inst_TGEU|inst_TGEIU
                  |inst_SLT|inst_SLTI|inst_SLTU|inst_SLTIU
                  |inst_LWL|inst_LWR|inst_SWL|inst_SWR
                  |inst_MADD|inst_MADDU|inst_MSUB|inst_MSUBU
                  |inst_J|inst_JR|inst_JAL|inst_JALR
                  |inst_BEQ|inst_BNE|inst_BLEZ|inst_BGTZ|inst_BLTZ|inst_BGEZ
                  |inst_BLTZAL|inst_BGEZAL|inst_BEQL|inst_BNEL|inst_BLEZL
                  |inst_BGTZL|inst_BLTZL|inst_BGEZL|inst_BLTZALL|inst_BGEZALL
                  ;    

assign dec_op[4] = inst_SLL|inst_SLLV|inst_SRL|inst_SRLV|inst_SRA|inst_SRAV
                  |inst_MULT|inst_MULTU|inst_MUL|inst_DIV|inst_DIVU
                  |inst_ADD|inst_ADDI|inst_ADDU|inst_ADDIU
                  |inst_SUB|inst_SUBU|inst_AND|inst_ANDI|inst_OR|inst_ORI
                  |inst_XOR|inst_XORI|inst_NOR
                  |inst_BEQ|inst_BNE|inst_BLEZ|inst_BGTZ|inst_BLTZ|inst_BGEZ
                  |inst_BLTZAL|inst_BGEZAL|inst_BEQL|inst_BNEL|inst_BLEZL
                  |inst_BGTZL|inst_BLTZL|inst_BGEZL|inst_BLTZALL|inst_BGEZALL
                  |inst_LB|inst_LH|inst_LW|inst_LBU|inst_LHU|inst_LL
                  |inst_SB|inst_SH|inst_SW|inst_SC
                  |inst_LWL|inst_LWR|inst_SWL|inst_SWR
                  ;


assign dec_op[3] = inst_ADD|inst_ADDI|inst_ADDU|inst_ADDIU
                  |inst_MFHI|inst_MFLO|inst_MTHI|inst_MTLO
                  |inst_SUB|inst_SUBU|inst_AND|inst_ANDI|inst_OR|inst_ORI
                  |inst_XOR|inst_XORI|inst_NOR
                  |inst_MFC0|inst_MTC0|inst_MOVN|inst_MOVZ
                  |inst_SB|inst_SH|inst_SW|inst_SC
                  |inst_J|inst_JR|inst_JAL|inst_JALR
                  |inst_BEQL|inst_BNEL|inst_BLEZL|inst_BGTZL|inst_BLTZL
                  |inst_BGEZL|inst_BLTZALL|inst_BGEZALL
                  |inst_LWL|inst_LWR|inst_SWL|inst_SWR
                  |inst_MADD|inst_MADDU|inst_MSUB|inst_MSUBU
                  |inst_DERET 
                  ;
   
assign dec_op[2] = inst_MULT|inst_AND|inst_ANDI|inst_TGE|inst_TGEI
                  |inst_MULTU|inst_OR|inst_ORI|inst_TGEU|inst_TGEIU
                  |inst_DIV|inst_XOR|inst_XORI|inst_SLT|inst_SLTI
                  |inst_DIVU|inst_NOR|inst_SLTU|inst_SLTIU
                  |inst_J|inst_BLTZ|inst_BLTZL
                  |inst_JR|inst_JR_HB|inst_BGEZ|inst_BGEZL
                  |inst_JAL|inst_BLTZAL|inst_BLTZALL
                  |inst_JALR|inst_JALR_HB|inst_BGEZAL|inst_BGEZALL
                  |inst_MFC0|inst_RDHWR|inst_LBU
                  |inst_MTC0|inst_LHU
                  |inst_SYNC|inst_LL|inst_SC
                  |inst_MFHI|inst_MFLO|inst_MTHI|inst_MTLO
                  |inst_ERET|inst_LUI
                  |inst_DERET
                  ;


assign dec_op[1] = inst_SRL|inst_SRLV|inst_SUB|inst_TLT|inst_TLTI
                  |inst_SRA|inst_SRAV|inst_SUBU|inst_TLTU|inst_TLTIU
                  |inst_DIV|inst_XOR|inst_XORI|inst_SLT|inst_SLTI
                  |inst_DIVU|inst_NOR|inst_SLTU|inst_SLTIU
                  |inst_BLEZ|inst_BLEZL|inst_BGTZ|inst_BGTZL
                  |inst_JAL|inst_BLTZAL|inst_BLTZALL
                  |inst_JALR|inst_JALR_HB|inst_BGEZAL|inst_BGEZALL
                  |inst_LW|inst_SW|inst_SYNC|inst_LL|inst_SC
                  |inst_SWL |inst_SWR 
                  |inst_ERET
                  |inst_MOVN|inst_MOVZ
                  |inst_MSUB|inst_MSUBU 
                  |inst_MTLO|inst_MTHI
                  |inst_DERET
                  ; 


assign dec_op[0] = inst_ADDU|inst_ADDIU|inst_MFLO|inst_MTLO
                  |inst_DIVU|inst_NOR|inst_SLTU|inst_SLTIU
                  |inst_BNE|inst_BNEL|inst_SRA|inst_SRAV|inst_SUBU
                  |inst_OR|inst_ORI|inst_TLTU|inst_TLTIU
                  |inst_TGEU|inst_TGEIU|inst_TNE|inst_TNEI
                  |inst_JR|inst_BGEZ|inst_BGEZL|inst_BGTZ|inst_BGTZL
                  |inst_JALR|inst_JALR_HB|inst_BGEZAL|inst_BGEZALL
                  |inst_LH|inst_SH|inst_MTC0|inst_LHU|inst_LWR|inst_SWR
                  |inst_CLZ|inst_MOVZ|inst_MADDU|inst_MSUBU
                  |inst_SLL|inst_SLLV|inst_MULTU
                  |inst_ERET|inst_LUI
                  |inst_DERET
                  ;

/****** Internal FMT generation ******/
assign dec_fmt  = {2'b10, fmt[2], 2'b00};


assign dec_v1_rs = 
/** CPU Arithmetic **/
    inst_ADD     |inst_ADDI    |inst_ADDIU   |inst_ADDU    |inst_CLO     |inst_CLZ     
   |inst_DIV     |inst_DIVU    |inst_MADD    |inst_MADDU   |inst_MSUB    |inst_MSUBU   
   |inst_MUL     |inst_MULT    |inst_MULTU   |inst_SLT     |inst_SLTI    |inst_SLTIU   
   |inst_SLTU    |inst_SUB     |inst_SUBU
/** CPU Branch and Jump **/
   |inst_BEQ     |inst_BGEZ    |inst_BGEZAL  |inst_BGTZ    |inst_BLEZ    |inst_BLTZ
   |inst_BLTZAL  |inst_BNE     
/** CPU Load, Store and Memory Control **/
   |inst_LB      |inst_LBU     |inst_LH      |inst_LHU     |inst_LL      |inst_LW
   |inst_LWL     |inst_LWR     |inst_PREF    |inst_SB      |inst_SC      |inst_SH
   |inst_SW      |inst_SWL     |inst_SWR     
/** CPU Logical **/
   |inst_AND     |inst_ANDI    |inst_NOR     |inst_OR      |inst_ORI     |inst_XOR     
   |inst_XORI 
/** CPU Insert/Extract **/
/** CPU Move **/
   |inst_MOVN    |inst_MOVZ    |inst_MTHI    |inst_MTLO    
/** CPU Trap **/
   |inst_TEQ     |inst_TEQI    |inst_TGE     |inst_TGEI    |inst_TGEIU   |inst_TGEU    
   |inst_TLT     |inst_TLTI    |inst_TLTIU   |inst_TLTU    |inst_TNE     |inst_TNEI    
/** Obsolete CPU Branch **/
   |inst_BEQL    |inst_BGEZALL |inst_BGEZL   |inst_BGTZL   |inst_BLEZL   |inst_BLTZALL
   |inst_BLTZL   |inst_BNEL    
/** Privileged Instructions **/
   ;

assign dec_v1_rt = 1'b0 
/** CPU Shift **/
   |inst_SLL     |inst_SLLV    |inst_SRA     |inst_SRAV    |inst_SRL     |inst_SRLV
/** Privileged Instructions **/
   |inst_MTC0
   ;

assign dec_v1_fs     = 1'b0;

assign dec_v1_fcr    = 1'b0;

assign dec_v1_imm_upper = inst_LUI;

assign dec_v2_rs    =   
/** CPU Shift **/
    inst_SLLV    |inst_SRLV    |inst_SRAV
   ;

assign dec_v2_rt    = 
/** CPU Arithmetic **/
    inst_ADD     |inst_ADDU    |inst_DIV     |inst_DIVU    |inst_MADD    |inst_MADDU   
   |inst_MSUB    |inst_MSUBU   |inst_MUL     |inst_MULT    |inst_MULTU   |inst_SLT     
   |inst_SLTU    |inst_SUB     |inst_SUBU
/** CPU Branch and Jump **/
   |inst_BEQ     |inst_BNE     
/****** CPU Logical ******/
   |inst_AND     |inst_NOR     |inst_OR      |inst_XOR
/** CPU Insert/Extract **/
/** CPU Move **/
   |inst_MOVN    |inst_MOVZ    
/** CPU Trap **/
   |inst_TEQ     |inst_TGE     |inst_TGEU   |inst_TLT     |inst_TLTU    |inst_TNE     
/** Obsolete CPU Branch **/
   |inst_BEQL    |inst_BNEL    
   ;

assign dec_v2_rd_sel = 
    inst_MFC0    |inst_MTC0    
   ;

assign dec_v2_imm_sign_extend = 
/** CPU Arithmetic **/
    inst_ADDI    |inst_ADDIU   |inst_SLTI    |inst_SLTIU   
/** CPU Load, Store and Memory Control **/
   |inst_LB      |inst_LBU     |inst_LH      |inst_LHU     |inst_LL      |inst_LW
   |inst_LWL     |inst_LWR     |inst_PREF    |inst_SB      |inst_SC      |inst_SH
   |inst_SW      |inst_SWL     |inst_SWR     
/** CPU Trap **/
   |inst_TEQI    |inst_TGEI    |inst_TGEIU   |inst_TLTI    |inst_TLTIU   |inst_TNEI    
/** Privileged Instructions **/
   ;

assign dec_v2_imm_zero_extend  =
    inst_ANDI    |inst_ORI     |inst_XORI
   ;

assign dec_v2_imm_sa    = 
/** CPU Shift **/
    inst_SLL     |inst_SRA     |inst_SRL
   ;

assign dec_v2_cc = 1'b0;

assign dec_v2_ft   = 1'b0;

assign dec_v3_rs =  
/** CPU Branch and Jump **/
    inst_JALR    |inst_JR
    ;

assign dec_v3_rt    =  
/** CPU Load, Store and Memory Control **/
   |inst_LWL     |inst_LWR     |inst_SB      |inst_SC      |inst_SH      |inst_SW      
   |inst_SWL     |inst_SWR     
   ;

assign dec_v3_imm_offset =  
/** CPU Branch and Jump **/
   |inst_BEQ     |inst_BGEZ    |inst_BGEZAL  |inst_BGTZ    |inst_BLEZ    |inst_BLTZ
   |inst_BLTZAL  |inst_BNE     
/** Obsolete CPU Branch **/
   |inst_BEQL    |inst_BGEZALL |inst_BGEZL   |inst_BGTZL   |inst_BLEZL   |inst_BLTZALL
   |inst_BLTZL   |inst_BNEL    
/** FPU Branch **/
   |inst_BC1F    |inst_BC1T
/** Obsolete FPU Branch **/ 
   |inst_BC1FL   |inst_BC1TL
;

assign dec_v3_imm_instr_index =
/** CPU Branch and Jump **/
    inst_J       |inst_JAL        
   ;

assign dec_v3_imm_pos_size = 1'b0
/** CPU Insert/Extract **/
   ;

assign dec_v3_fs = 1'b0;

assign dec_v3_ft = 1'b0;

assign dec_v3_fr = 1'b0;

/****** GR read ******/
wire        gr_rvalid0;
wire [ 4:0] gr_raddr0;
wire [31:0] gr_rvalue0;
wire        gr_rvalid1;
wire [ 4:0] gr_raddr1;
wire [31:0] gr_rvalue1;
wire        gr_wvalid0;
wire [ 4:0] gr_waddr0;
wire [31:0] gr_wvalue0;
wire        gr_fwd0;
wire        gr_fwd1;

assign gr_rvalid0 = dec_v1_rs | dec_v1_rt;
assign gr_raddr0  = dec_v1_rt ? rt : rs;

assign gr_rvalid1 = dec_v2_rs | dec_v2_rt | dec_v3_rs | dec_v3_rt;
assign gr_raddr1  = (dec_v2_rs | dec_v3_rs) ? rs : rt;

assign gr_wvalid0 = wb_gr_wen;
assign gr_waddr0  = wb_gr_num;
assign gr_wvalue0 = wb_gr_value;

wire wb_gr_nonzero = gr_waddr0!=5'h0; 

assign gr_fwd0    = gr_wvalid0 && (gr_waddr0==gr_raddr0) && wb_gr_nonzero;
assign gr_fwd1    = gr_wvalid0 && (gr_waddr0==gr_raddr1) && wb_gr_nonzero;

gr_heap_2r1w_32x32 
        u0_gr_heap(.clock(clock),
                   .ren0(gr_rvalid0), .raddr0(gr_raddr0), .rvalue0(gr_rvalue0),
                   .ren1(gr_rvalid1), .raddr1(gr_raddr1), .rvalue1(gr_rvalue1),
                   .wen0(gr_wvalid0), .waddr0(gr_waddr0), .wvalue0(gr_wvalue0)
                  );

/****** FPR read ******/
assign v1_en = (dec_v1_rs | dec_v1_rt | dec_v1_fs | dec_v1_fcr | dec_v1_imm_upper);

assign v1 =              (dec_v1_fs & fr_fwd0) ? fr_wvalue0 :
           ((dec_v1_rs | dec_v1_rt) & gr_fwd0) ? gr_wvalue0 : 
                                   (dec_v1_fs) ? fr_rvalue0 :
                       (dec_v1_rs | dec_v1_rt) ? gr_rvalue0 : 
                            (dec_v1_imm_upper) ? {imm[15:0], 16'h0} : 
                                                 {27'h0, fs[4:0]}; //dec_v1_fcr

assign v2_en = (dec_v2_rs | dec_v2_rt | dec_v2_rd_sel | dec_v2_imm_sign_extend |
                dec_v2_imm_zero_extend | dec_v2_imm_sa | dec_v2_cc | dec_v2_ft);

assign v2 =              (dec_v2_ft & fr_fwd1) ? fr_wvalue0 :
           ((dec_v2_rs | dec_v2_rt) & gr_fwd1) ? gr_wvalue0 :
                                   (dec_v2_ft) ? fr_rvalue1 :
                       (dec_v2_rs | dec_v2_rt) ? gr_rvalue1 :
                      (dec_v2_imm_sign_extend) ? {{16{imm[15]}}, imm[15:0]} : 
                      (dec_v2_imm_zero_extend) ? {16'h0, imm[15:0]} :
                               (dec_v2_imm_sa) ? {27'h0, sa[4:0]} :
                               (dec_v2_rd_sel) ? {24'h0, rd[4:0], cp0_sel[2:0]} : 
                                                 {29'h0, cc_src[2:0]}; //dec_v2_cc

assign v3_en = (dec_v3_rs | dec_v3_rt | dec_v3_imm_offset | dec_v3_imm_instr_index |
                dec_v3_imm_pos_size | dec_v3_fs | dec_v3_ft | dec_v3_fr);

assign v3 = ((dec_v3_fs | dec_v3_ft | dec_v3_fr) & fr_fwd1) ? fr_wvalue0 :
                        ((dec_v3_rs | dec_v3_rt) & gr_fwd1) ? gr_wvalue0 :
                        (dec_v3_fs | dec_v3_ft | dec_v3_fr) ? fr_rvalue1 :
                                    (dec_v3_rs | dec_v3_rt) ? gr_rvalue1 :
                                        (dec_v3_imm_offset) ? {{14{offset[15]}}, offset[15:0], 2'b00} :
                                      (dec_v3_imm_pos_size) ? {22'h0, rd[4:0], sa[4:0]} : 
                                                              {6'h0, instr_index[25:0]};


assign decdest_rd    = inst_ADD|inst_ADDU|inst_AND
                      |inst_JALR|inst_MFHI|inst_MFLO|inst_NOR|inst_OR
                      |inst_SLL|inst_SLLV|inst_SLT|inst_SLTU|inst_SRA|inst_SRAV
                      |inst_SRL|inst_SRLV|inst_SUB|inst_SUBU|inst_XOR
                      |inst_MUL|inst_CLO|inst_CLZ|inst_MOVF|inst_MOVT|inst_MOVN|inst_MOVZ
                      ;
 
assign decdest_rt    = inst_ADDI|inst_ADDIU|inst_ANDI
                      |inst_LUI|inst_ORI|inst_SLTI|inst_SLTIU|inst_XORI
                      |inst_LB|inst_LBU|inst_LH
                      |inst_LHU|inst_LL|inst_LW
                      |inst_MFC0|inst_SC|inst_CFC1|inst_MFC1
                      |inst_LWL|inst_LWR
                      ;

assign decdest_gr31  = inst_JAL|inst_BGEZAL|inst_BGEZALL|inst_BLTZAL|inst_BLTZALL;


assign decdest_fcr   = 1'b0;
assign decdest_cc    = 1'b0;
assign decdest_fd    = 1'b0;
assign decdest_fs    = 1'b0;
assign decdest_ft    = 1'b0;

assign decdest_ce    = dec_ex_cpu;

assign dec_dest      = decdest_fcr   ? {2'b11, rd[4:0]}
                     : decdest_cc    ? {2'b11, 2'b00, cc_fcmp[2:0]}
                     : decdest_gr31  ? 7'h1f
                     : decdest_rd    ? {2'b00, rd[4:0]}
                     : decdest_rt    ? {2'b00, rt[4:0]}
                     : decdest_fd    ? {2'b01, sa[4:0]}
                     : decdest_ft    ? {2'b01, rt[4:0]}
                     : decdest_fs    ? {2'b01, rd[4:0]}
                     :                 {2'b11, 3'b000, dec_ex_ce[1:0]};      


/****** exception detected in decode stage ******/
wire legal_fmt      = fmt_s | fmt_w;

wire legal_mac_fmt  = ir_inst[2:0]==3'b000;

wire rdhwr_valid    = (HWREna[0]&rd_d[5'h00] |
                       HWREna[1]&rd_d[5'h01] |
                       HWREna[2]&rd_d[5'h02] |
                       HWREna[3]&rd_d[5'h03] |
                       kernel_mode           |
                       debug_mode            |
                       status_cu[0]          ) & rd[4:2]==3'b000;
                      
assign dec_ex_ri = ~(
/** CPU Arithmetic **/
    inst_ADD     |inst_ADDI    |inst_ADDIU   |inst_ADDU    |inst_CLO     |inst_CLZ    
   |inst_DIV     |inst_DIVU    |inst_MADD    |inst_MADDU   |inst_MSUB    |inst_MSUBU
   |inst_MUL     |inst_MULT    |inst_MULTU   |inst_SLT     |inst_SLTI    |inst_SLTIU
   |inst_SLTU    |inst_SUB     |inst_SUBU    
/** CPU Branch and Jump **/
   |inst_BEQ     |inst_BGEZ    |inst_BGEZAL  |inst_BGTZ    |inst_BLEZ    |inst_BLTZ
   |inst_BLTZAL  |inst_BNE     |inst_J       |inst_JAL     |inst_JALR    |inst_JR
/** CPU Instruction Control **/
//   |inst_NOP     |inst_SSNOP  
/** CPU Load, Store and Memory Control **/
   |inst_LB      |inst_LBU     |inst_LH      |inst_LHU     |inst_LL      |inst_LW
   |inst_LWL     |inst_LWR     |inst_PREF    |inst_SB      |inst_SC      |inst_SH
   |inst_SW      |inst_SWL     |inst_SWR     |inst_SYNC    
/** CPU Logical **/
   |inst_AND     |inst_ANDI    |inst_LUI     |inst_NOR     |inst_OR      |inst_ORI
   |inst_XOR     |inst_XORI 
/** CPU Insert/Extract **/
/** CPU Move **/
   |inst_MFHI    |inst_MFLO    |inst_MOVF    |inst_MOVN    |inst_MOVT    |inst_MOVZ
   |inst_MTHI    |inst_MTLO    
/** CPU Shift **/
   |inst_SLL     |inst_SLLV    |inst_SRA     |inst_SRAV    |inst_SRL     |inst_SRLV
/** CPU Trap **/
   |inst_BREAK   |inst_SYSCALL |inst_TEQ     |inst_TEQI    |inst_TGE     |inst_TGEI
   |inst_TGEIU   |inst_TGEU    |inst_TLT     |inst_TLTI    |inst_TLTIU   |inst_TLTU
   |inst_TNE     |inst_TNEI    
/** Obsolete CPU Branch **/
   |inst_BEQL    |inst_BGEZALL |inst_BGEZL   |inst_BGTZL   |inst_BLEZL   |inst_BLTZALL
   |inst_BLTZL   |inst_BNEL    
/** Privileged Instructions **/
   |inst_ERET    |inst_MFC0    |inst_MTC0    |inst_WAIT
/** EJTAG **/
   |inst_DERET   |inst_SDBBP    
);

wire cp0_inst   = 
        inst_CACHE   |inst_DERET   |inst_DI      |inst_EI      |inst_ERET
       |inst_MFC0    |inst_MTC0    |inst_RDPGPR  |inst_TLBP    |inst_TLBR
       |inst_TLBWI   |inst_TLBWR   |inst_WAIT    |inst_WRPGPR  ;

wire cp1_inst   = 
        inst_ABS_F   |inst_ADD_F   |inst_ALNV_PS |inst_BC1TL   |inst_BC1FL
       |inst_BC1T    |inst_BC1TL   |inst_C       |inst_CEIL_L  |inst_CEIL_W
       |inst_CFC1    |inst_CTC1    |inst_CVT_D   |inst_CVT_L   |inst_CVT_PS_S
       |inst_CVT_S   |inst_CVT_S_PL|inst_CVT_S_PU|inst_CVT_W   |inst_DIV_F
       |inst_FLOOR_L |inst_FLOOR_W |inst_LDC1    |inst_LDXC1   |inst_LUXC1
       |inst_LWC1    |inst_LWXC1   |inst_MADD_F  |inst_MFC1    |inst_MFHC1
       |inst_FMOV    |inst_MOVF    |inst_FMOVF   |inst_FMOVN   |inst_MOVT
       |inst_FMOVT   |inst_FMOVZ   |inst_MSUB_F  |inst_MTC1    |inst_MTHC1
       |inst_MUL_F   |inst_NEG_F   |inst_NMADD_F |inst_NMSUB_F |inst_PLL_PS
       |inst_PLU_PS  |inst_PREFX   |inst_PUL_PS  |inst_PUU_PS  |inst_RECIP
       |inst_ROUND_L |inst_ROUND_W |inst_RSQRT   |inst_SDC1    |inst_SDXC1
       |inst_SQRT_F  |inst_SUB_F   |inst_SUXC1   |inst_SWC1    |inst_SWXC1
       |inst_TRUNC_L |inst_TRUNC_W ;

wire cp2_inst   = 
        inst_BC2F    |inst_BC2FL   |inst_BC2T    |inst_BC2TL   |inst_CFC2
       |inst_COP2    |inst_CTC2    |inst_LDC2    |inst_LWC2    |inst_MFC2
       |inst_MFHC2   |inst_MTC2    |inst_MTHC2   |inst_SDC2    |inst_SWC2
       ;

assign dec_ex_cpu = ~status_cu[2] & cp2_inst |
                    ~status_cu[1] & cp1_inst |
                    ~status_cu[0] & cp0_inst & ~(kernel_mode | debug_mode);

assign dec_ex_ce  = (~status_cu[2] & cp2_inst) ? 2'b10 :
                    (~status_cu[1] & cp1_inst) ? 2'b01 : 2'b00;

assign dec_ex_sys = inst_SYSCALL;
assign dec_ex_bp  = inst_BREAK || inst_SDBBP&&debug_mode;
assign dec_ex_wait= inst_WAIT && !ir_bd;
assign dec_ex_dbp = inst_SDBBP && !debug_mode;

assign dec_ex_int  = ex_int && ejtag_inte_i && !debug_mode;
assign dec_ex_nmi  = nmi_i && !debug_mode;

assign dec_ex = dec_ex_nmi | dec_ex_int | dec_ex_ri | dec_ex_cpu | dec_ex_sys | dec_ex_bp | dec_ex_wait |
                dec_ex_dbp | ir_ex_dib | ir_ex_adel;

assign dec_excode = dec_ex_nmi      ? `LS132R_EX_NMI  :
                    dec_ex_int      ? `LS132R_EX_INT  :
                    ir_ex_dib       ? `LS132R_EX_DIB  :
                    ir_ex_adel      ? `LS132R_EX_ADEL :
                    dec_ex_dbp      ? `LS132R_EX_DBP  :
                    dec_ex_cpu      ? `LS132R_EX_CPU  :
                    dec_ex_ri       ? `LS132R_EX_RI   : 
                    dec_ex_bp       ? `LS132R_EX_BP   :
                    dec_ex_sys      ? `LS132R_EX_SYS  :
                                      `LS132R_EX_WAIT ;

/** OUTPUT **/
// issuebus_o
assign issue_valid       = ir_valid;
assign issue_bd          = ir_bd;
assign issue_ex          = dec_ex;
assign issue_excode      = dec_excode;
assign issue_pc          = ir_pc;
assign issue_op          = dec_op;
assign issue_fmt         = dec_fmt;
assign issue_float_mult  = inst_float_mult;
assign issue_dest        = dec_dest;
assign issue_v1_en       = v1_en;
assign issue_v1          = v1;
assign issue_v2_en       = v2_en;
assign issue_v2          = v2;
assign issue_v3_en       = v3_en;
assign issue_v3          = v3;
assign issue_v1_h_en     = 1'b0;
assign issue_v1_h        = 32'h0;
assign issue_v2_h_en     = 1'b0;
assign issue_v2_h        = 32'h0;
assign issue_v3_h_en     = 1'b0;
assign issue_v3_h        = 32'h0;



// dec_status_o
assign br_in_ir         = ir_valid && inst_br;
assign bd_in_ir         = ir_valid && ir_bd;
assign wait_wakeup      = dec_ex_nmi || dec_ex_int;
assign bd_pc            = ir_pc;
assign idle_in_ir       = !ir_valid;
assign ctrl_stall_in_ir = ir_valid && 
          (inst_ERET  || inst_DERET || 
           inst_MTC0 && ({rd, cp0_sel}==8'b01100_000 || {rd, cp0_sel}==8'b10000_000) 
          );                            /*cr_status*/                  /*cr_config*/
        



endmodule //ls132r_decode_stage



module gr_heap_2r1w_32x32(
  clock,

  ren0, raddr0, rvalue0,

  ren1, raddr1, rvalue1,

  wen0, waddr0, wvalue0

);
/* reg 0 is zero forever */
input           clock;

input           ren0;
input   [ 4:0]  raddr0;
output  [31:0]  rvalue0;

input           ren1;
input   [ 4:0]  raddr1;
output  [31:0]  rvalue1;

input           wen0;
input   [ 4:0]  waddr0;
input   [31:0]  wvalue0;

reg  [31:0]          heap_01, heap_02, heap_03, heap_04, heap_05, heap_06, heap_07;
reg  [31:0] heap_08, heap_09, heap_10, heap_11, heap_12, heap_13, heap_14, heap_15;
reg  [31:0] heap_16, heap_17, heap_18, heap_19, heap_20, heap_21, heap_22, heap_23;
reg  [31:0] heap_24, heap_25, heap_26, heap_27, heap_28, heap_29, heap_30, heap_31;

wire [31:0] raddr0_vec, raddr1_vec;
wire [31:0] heap_rvalue0, heap_rvalue1;
wire [31:0] waddr0_vec;
wire [31:0] wen0_vec;

/* Read */
ls132r_decoder_5_32 u0_raddr_dec_5_32(.in({5{ren0}}&raddr0), .out(raddr0_vec));

ls132r_decoder_5_32 u1_raddr_dec_5_32(.in({5{ren1}}&raddr1), .out(raddr1_vec));

assign heap_rvalue0 = {32{raddr0_vec[31]}}&heap_31 |
                      {32{raddr0_vec[30]}}&heap_30 |
                      {32{raddr0_vec[29]}}&heap_29 |
                      {32{raddr0_vec[28]}}&heap_28 |
                      {32{raddr0_vec[27]}}&heap_27 |
                      {32{raddr0_vec[26]}}&heap_26 |
                      {32{raddr0_vec[25]}}&heap_25 |
                      {32{raddr0_vec[24]}}&heap_24 |
                      {32{raddr0_vec[23]}}&heap_23 |
                      {32{raddr0_vec[22]}}&heap_22 |
                      {32{raddr0_vec[21]}}&heap_21 |
                      {32{raddr0_vec[20]}}&heap_20 |
                      {32{raddr0_vec[19]}}&heap_19 |
                      {32{raddr0_vec[18]}}&heap_18 |
                      {32{raddr0_vec[17]}}&heap_17 |
                      {32{raddr0_vec[16]}}&heap_16 |
                      {32{raddr0_vec[15]}}&heap_15 |
                      {32{raddr0_vec[14]}}&heap_14 |
                      {32{raddr0_vec[13]}}&heap_13 |
                      {32{raddr0_vec[12]}}&heap_12 |
                      {32{raddr0_vec[11]}}&heap_11 |
                      {32{raddr0_vec[10]}}&heap_10 |
                      {32{raddr0_vec[ 9]}}&heap_09 |
                      {32{raddr0_vec[ 8]}}&heap_08 |
                      {32{raddr0_vec[ 7]}}&heap_07 |
                      {32{raddr0_vec[ 6]}}&heap_06 |
                      {32{raddr0_vec[ 5]}}&heap_05 |
                      {32{raddr0_vec[ 4]}}&heap_04 |
                      {32{raddr0_vec[ 3]}}&heap_03 |
                      {32{raddr0_vec[ 2]}}&heap_02 |
                      {32{raddr0_vec[ 1]}}&heap_01 ;

assign heap_rvalue1 = {32{raddr1_vec[31]}}&heap_31 |
                      {32{raddr1_vec[30]}}&heap_30 |
                      {32{raddr1_vec[29]}}&heap_29 |
                      {32{raddr1_vec[28]}}&heap_28 |
                      {32{raddr1_vec[27]}}&heap_27 |
                      {32{raddr1_vec[26]}}&heap_26 |
                      {32{raddr1_vec[25]}}&heap_25 |
                      {32{raddr1_vec[24]}}&heap_24 |
                      {32{raddr1_vec[23]}}&heap_23 |
                      {32{raddr1_vec[22]}}&heap_22 |
                      {32{raddr1_vec[21]}}&heap_21 |
                      {32{raddr1_vec[20]}}&heap_20 |
                      {32{raddr1_vec[19]}}&heap_19 |
                      {32{raddr1_vec[18]}}&heap_18 |
                      {32{raddr1_vec[17]}}&heap_17 |
                      {32{raddr1_vec[16]}}&heap_16 |
                      {32{raddr1_vec[15]}}&heap_15 |
                      {32{raddr1_vec[14]}}&heap_14 |
                      {32{raddr1_vec[13]}}&heap_13 |
                      {32{raddr1_vec[12]}}&heap_12 |
                      {32{raddr1_vec[11]}}&heap_11 |
                      {32{raddr1_vec[10]}}&heap_10 |
                      {32{raddr1_vec[ 9]}}&heap_09 |
                      {32{raddr1_vec[ 8]}}&heap_08 |
                      {32{raddr1_vec[ 7]}}&heap_07 |
                      {32{raddr1_vec[ 6]}}&heap_06 |
                      {32{raddr1_vec[ 5]}}&heap_05 |
                      {32{raddr1_vec[ 4]}}&heap_04 |
                      {32{raddr1_vec[ 3]}}&heap_03 |
                      {32{raddr1_vec[ 2]}}&heap_02 |
                      {32{raddr1_vec[ 1]}}&heap_01 ;


assign rvalue0 = heap_rvalue0;

assign rvalue1 = heap_rvalue1;

/* Write */
ls132r_decoder_5_32 u0_waddr_dec_5_32(.in(waddr0), .out(waddr0_vec));

assign wen0_vec = {32{wen0}}&waddr0_vec;

always @(posedge clock)
begin
  if (wen0_vec[31]) heap_31 <= wvalue0;
  if (wen0_vec[30]) heap_30 <= wvalue0;
  if (wen0_vec[29]) heap_29 <= wvalue0;
  if (wen0_vec[28]) heap_28 <= wvalue0;
  if (wen0_vec[27]) heap_27 <= wvalue0;
  if (wen0_vec[26]) heap_26 <= wvalue0;
  if (wen0_vec[25]) heap_25 <= wvalue0;
  if (wen0_vec[24]) heap_24 <= wvalue0;
  if (wen0_vec[23]) heap_23 <= wvalue0;
  if (wen0_vec[22]) heap_22 <= wvalue0;
  if (wen0_vec[21]) heap_21 <= wvalue0;
  if (wen0_vec[20]) heap_20 <= wvalue0;
  if (wen0_vec[19]) heap_19 <= wvalue0;
  if (wen0_vec[18]) heap_18 <= wvalue0;
  if (wen0_vec[17]) heap_17 <= wvalue0;
  if (wen0_vec[16]) heap_16 <= wvalue0;
  if (wen0_vec[15]) heap_15 <= wvalue0;
  if (wen0_vec[14]) heap_14 <= wvalue0;
  if (wen0_vec[13]) heap_13 <= wvalue0;
  if (wen0_vec[12]) heap_12 <= wvalue0;
  if (wen0_vec[11]) heap_11 <= wvalue0;
  if (wen0_vec[10]) heap_10 <= wvalue0;
  if (wen0_vec[ 9]) heap_09 <= wvalue0;
  if (wen0_vec[ 8]) heap_08 <= wvalue0;
  if (wen0_vec[ 7]) heap_07 <= wvalue0;
  if (wen0_vec[ 6]) heap_06 <= wvalue0;
  if (wen0_vec[ 5]) heap_05 <= wvalue0;
  if (wen0_vec[ 4]) heap_04 <= wvalue0;
  if (wen0_vec[ 3]) heap_03 <= wvalue0;
  if (wen0_vec[ 2]) heap_02 <= wvalue0;
  if (wen0_vec[ 1]) heap_01 <= wvalue0;
end

endmodule //gr_heap_2r1w_32x32
