//special
`define MFC0           6'b010000
`define MFC0_2         5'b00000
`define MTC0           6'b010000
`define MTC0_2         5'b00100
`define ERET           6'b010000
`define ERET_2         6'b011000
`define BREAK          6'b000000
`define BREAK_2        6'b001101
`define SYSCALL        6'b000000
`define SYSCALL_2      6'b001100

//data move
`define MFHI           6'b000000
`define MFHI_2         6'b010000
`define MFLO           6'b000000
`define MFLO_2         6'b010010
`define MTHI           6'b000000
`define MTHI_2         6'b010001
`define MTLO           6'b000000
`define MTLO_2         6'b010011

//load 
`define LB             6'b100000
`define LBU            6'b100100
`define LH             6'b100001
`define LHU            6'b100101
`define LW             6'b100011
`define LWL            6'b100010
`define LWR            6'b100110

//store
`define SB             6'b101000
`define SH             6'b101001
`define SW             6'b101011
`define SWL            6'b101010
`define SWR            6'b101110

//branch
`define BEQ            6'b000100
`define BNE            6'b000101
`define BGEZ           6'b000001
`define BGEZ_2         5'b00001
`define BGTZ           6'b000111
`define BLEZ           6'b000110
`define BLTZ           6'b000001
`define BLTZ_2         5'b000000
`define BGEZAL         6'b000001
`define BGEZAL_2       5'b10001
`define BLTZAL         6'b000001
`define BLTZAL_2       5'b10000

//jump
`define J              6'b000010
`define JAL            6'b000011

//jump register
`define JR             6'b000000
`define JR_2           6'b001000
`define JALR           6'b000000
`define JALR_2         6'b001001

//logic 
`define AND            6'b000000
`define AND_2          6'b100100
`define ANDI           6'b001100
`define LUI            6'b001111
`define NOR            6'b000000
`define NOR_2          6'b100111
`define OR             6'b000000
`define OR_2           6'b100101
`define ORI            6'b001101
`define XOR            6'b000000
`define XOR_2          6'b100110
`define XORI           6'b001110



//arithmetic
`define ADD            6'b000000
`define ADD_2          6'b100000
`define ADDI           6'b001000
`define ADDU           6'b000000
`define ADDU_2         6'b100001
`define ADDIU          6'b001001
`define SUB            6'b000000
`define SUB_2          6'b100010
`define SUBU           6'b000000
`define SUBU_2         6'b100011
`define SLT            6'b000000
`define SLT_2          6'b101010
`define SLTI           6'b001010
`define SLTU           6'b000000
`define SLTU_2         6'b101011
`define SLTIU          6'b001011
`define DIV            6'b000000
`define DIV_2          6'b011010
`define DIVU           6'b000000
`define DIVU_2         6'b011011
`define MULT           6'b000000
`define MULT_2         6'b011000
`define MULTU          6'b000000
`define MULTU_2        6'b011001



//shift
`define SLLV           6'b000000
`define SLLV_2         6'b000100
`define SLL            6'b000000
`define SLL_2          6'b000000
`define SRAV           6'b000000
`define SRAV_2         6'b000111
`define SRA            6'b000000
`define SRA_2          6'b000011
`define SRLV           6'b000000
`define SRLV_2         6'b000110
`define SRL            6'b000000
`define SRL_2          6'b000010



`define ID_func           ID_inst[31:26]
`define EXE_func          EXE_inst[31:26]
`define MEM_func          MEM_inst[31:26]
`define WB_func           WB_inst[31:26]