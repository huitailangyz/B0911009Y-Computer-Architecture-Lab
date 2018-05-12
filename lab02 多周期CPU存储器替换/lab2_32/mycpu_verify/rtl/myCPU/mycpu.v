module mycpu_top(
	//clock and reset
	input clk,
	input resetn,
	
    //instruction SRAM
	output inst_sram_en,
	output [3:0]  inst_sram_wen,
	output [31:0] inst_sram_addr,
	output [31:0] inst_sram_wdata,
	input  [31:0] inst_sram_rdata,

	//data SRAM
	output data_sram_en,
	output [3:0]  data_sram_wen,
	output [31:0] data_sram_addr,
	output [31:0] data_sram_wdata,
	input  [31:0] data_sram_rdata,

	//debug signal
	output reg [31:0] debug_wb_pc,
	output reg [3:0]  debug_wb_rf_wen,
	output reg [4:0]  debug_wb_rf_wnum,
	output reg [31:0] debug_wb_rf_wdata
);

	//TODO: Insert your design of single cycle MIPS CPU here
	reg [31:0] PC;
    reg [31:0] old_PC;
	wire data_sram_ren;
	wire [31:0] alu_A;
    wire [31:0] alu_B;
    wire alu_Overflow;
    wire alu_CarryOut;
    wire alu_Zero;
    wire [31:0] alu_Result;
    wire [4:0] reg_waddr;
    wire [4:0] reg_raddr1;
    wire [4:0] reg_raddr2;
    wire [31:0] reg_wdata;
    wire [31:0] reg_rdata1;
    wire [31:0] reg_rdata2;
    wire PCWriteCond1;   //BEQ
    wire PCWriteCond2;   //BNE
    wire PCWrite;
    wire IRWrite;
    wire [1:0] PCSource;
    wire [1:0] ALUOp;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [1:0] RegDst;
    wire [1:0] MemtoReg;
	wire RegWrite;
	reg [31:0] InstructionReg;
	reg [31:0] AReg;
	reg [31:0] BReg;
	reg [31:0] ALUOutReg;
	wire [31:0] PCnext;
    reg [3:0] State;
    wire [3:0] NewState;
    wire [2:0] ALUoperator;  //真实的运算符
    
	alu alu1(
		.A(alu_A),
		.B(alu_B),
		.ALUop(ALUoperator),
		.Overflow(alu_Overflow),
		.CarryOut(alu_CarryOut),
		.Zero(alu_Zero),
		.Result(alu_Result)
	);
	
	reg_file reg1(
		.clk(clk),
		.resetn(resetn),
		.waddr(reg_waddr),
		.raddr1(reg_raddr1),
		.raddr2(reg_raddr2),
		.wen(RegWrite),
		.wdata(reg_wdata),
		.rdata1(reg_rdata1),
		.rdata2(reg_rdata2)
	);
	
    control_logic control_logic1(
		.Operator(InstructionReg[31:26]),
		.SpecialBits({InstructionReg[5],InstructionReg[3]}),
		.State(State),
		.PCWrite(PCWrite),
		.PCWriteCond1(PCWriteCond1),
		.PCWriteCond2(PCWriteCond2),
		.InstMemRead(),
		.DataMemRead(data_sram_ren),
		.MemWrite(data_sram_wen),
		.IRWrite(IRWrite),
		.MemtoReg(MemtoReg),
		.PCSource(PCSource),
		.ALUOp(ALUOp),
		.ALUSrcB(ALUSrcB),
		.ALUSrcA(ALUSrcA),
		.RegWrite(RegWrite),
		.RegDst(RegDst),
		.NewState(NewState)
	);
	
    ALU_control ALU_control1(
		.PreOperator(InstructionReg[31:26]),
		.PostOperator(InstructionReg[5:0]),
		.ALUOp(ALUOp),
		.ALUoperator(ALUoperator)
	);
    
    always @(posedge clk)
    begin
        
        if (resetn==0) 
        begin
            PC=32'hbfc00000; 
            State=4'b1111;
        end
        else begin
               State=NewState;
                      if ((PCWriteCond1&&alu_Zero)||(PCWriteCond2&&~alu_Zero)||PCWrite) PC=PCnext;
             end
        ALUOutReg=alu_Result;
        AReg=reg_rdata1;
        BReg=reg_rdata2;
        if (IRWrite) InstructionReg=inst_sram_rdata;
        
        if (State==4'b0000) old_PC=PC;
        if (State==4'b0001) debug_wb_pc=old_PC;
        debug_wb_rf_wdata=reg_wdata;
        debug_wb_rf_wnum=reg_waddr;
        debug_wb_rf_wen={4{RegWrite}};
    end
    
    assign reg_raddr1=InstructionReg[25:21];
    assign reg_raddr2=InstructionReg[20:16];
    assign reg_waddr=(RegDst==2'b00)?InstructionReg[20:16]:((RegDst==2'b01)?InstructionReg[15:11]:5'd31);
    assign reg_wdata=(MemtoReg==2'b00)?ALUOutReg:(MemtoReg==2'b01)?data_sram_rdata:(MemtoReg==2'b10)?PC:alu_Result;
    assign alu_A=(ALUSrcA==2'b00)?PC:((ALUSrcA==2'b01)?AReg:InstructionReg[10:6]);
    assign alu_B=(ALUSrcB==2'b00)?BReg:((ALUSrcB==2'b01)?32'd4:((ALUSrcB==2'b10)?{{16{InstructionReg[15]}},InstructionReg[15:0]}:{{14{InstructionReg[15]}},InstructionReg[15:0],2'b00}));
    assign PCnext=(PCSource==2'b00)?alu_Result:((PCSource==2'b01)?ALUOutReg:((PCSource==2'b10)?{PC[31:28],InstructionReg[25:0],2'b0}:AReg));
	
	/*debugging*/

	
	
	assign inst_sram_wdata=32'b0;
	assign inst_sram_wen=4'b0;
	
	assign inst_sram_addr=((PCWriteCond1&&alu_Zero)||(PCWriteCond2&&~alu_Zero)||PCWrite)?PCnext:PC;
	assign data_sram_addr=ALUOutReg;
	assign data_sram_wdata=BReg;
	assign data_sram_en=data_sram_wen||data_sram_ren;
    assign inst_sram_en=1;
endmodule

module control_logic(
    input [5:0] Operator,
    input [1:0] SpecialBits,  //InstructionReg[5,3] for differentiate SLT(11) ADDU/OR(10) SLL(00) JR(01)
    input [3:0] State,
    output reg PCWrite,
    output reg PCWriteCond1,
    output reg PCWriteCond2,
	output reg InstMemRead,
	output reg DataMemRead,
    output reg [3:0] MemWrite,
    output reg IRWrite,
    output reg [1:0] MemtoReg,
    output reg [1:0] PCSource,
    output reg [1:0] ALUOp,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ALUSrcA,
    output reg RegWrite,
    output reg [1:0] RegDst,
    output reg [3:0] NewState);
    always @(State)
    begin
        case (State)
            4'b0000:begin//fetch instruction (all step1)
						PCWrite=1;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=1;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=1;
						MemtoReg=2'bXX;
						PCSource=2'b00;
						ALUOp=2'b00;
						ALUSrcB=2'b01;
						ALUSrcA=2'b00;
						RegWrite=0;
						RegDst=2'bXX;
						NewState=4'b0001;
                    end
            4'b0001:begin//instruction decode and register fetch (all step2)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'bXX;
						ALUOp=2'b00;
						ALUSrcB=2'b11;
						ALUSrcA=2'b00;
						RegWrite=0;
						RegDst=2'bXX;
						case (Operator)
							6'b100011:NewState=4'b0010;   //LW
							6'b101011:NewState=4'b0010;   //SW
							6'b001001:NewState=4'b0010;   //ADDIU
							6'b000101:NewState=4'b0110;   //BNE
							6'b000000:case (SpecialBits)
										  2'b00:NewState=4'b1110;    //SLL
										  2'b01:NewState=4'b1101;    //JR
										  2'b10:NewState=4'b1000;    //ADDU & OR
										  2'b11:NewState=4'b1000;    //SLT
								      endcase               
							6'b000100:NewState=4'b1010;   //BEQ
							6'b000010:NewState=4'b1011;   //J
							6'b000011:NewState=4'b1100;   //JAL
							6'b001111:NewState=4'b0010;   //LUI
							6'b001010:NewState=4'b0010;   //SLTI
							6'b001011:NewState=4'b0010;   //SLTIU
							default:NewState=4'b0000;
						endcase
                    end
            4'b0010:begin//ALU computation1 (lw/sw/addiu/lui/slti/sltiu step3)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'bXX;
						ALUOp=2'b10;
						ALUSrcB=2'b10;
						ALUSrcA=2'b01;
						RegWrite=0;
						RegDst=2'bXX;
						case (Operator)
							6'b100011:NewState=4'b0011;    //LW
							6'b101011:NewState=4'b0101;    //SW
							6'b001001:NewState=4'b0111;    //ADDIU
							6'b001111:NewState=4'b0111;    //LUI
							6'b001010:NewState=4'b0111;    //SLTI
							6'b001011:NewState=4'b0111;    //SLTIU
							default:NewState=4'b0000;
						endcase
                    end
            4'b0011:begin//memory access load (lw step4)
					    PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=1;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'bXX;
						ALUOp=2'bXX;
						ALUSrcB=2'bXX;
						ALUSrcA=2'bXX;
						RegWrite=0;
						RegDst=2'bXX;
						NewState=4'b0100;
                    end
            4'b0100:begin//load write back (lw step5)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'b01;
						PCSource=2'bXX;
						ALUOp=2'bXX;
						ALUSrcB=2'bXX;
						ALUSrcA=2'bXX;
						RegWrite=1;
						RegDst=2'b00;
						NewState=4'b0000;
                    end
            4'b0101:begin//memory access store (sw step4)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b1111;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'bXX;
						ALUOp=2'bXX;
						ALUSrcB=2'bXX;
						ALUSrcA=2'bXX;
						RegWrite=0;
						RegDst=2'bXX;
						NewState=4'b0000;
                    end
            4'b0110:begin//bne completion (bne step3)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=1;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'b01;
						ALUOp=2'b01;
						ALUSrcB=2'b00;
						ALUSrcA=2'b01;
						RegWrite=0;
						RegDst=2'bXX;
						NewState=4'b0000;
                    end
            4'b0111:begin//addiu write back (addiu step4)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'b00;
						PCSource=2'bXX;
						ALUOp=2'bXX;
						ALUSrcB=2'bXX;
						ALUSrcA=2'bXX;
						RegWrite=1;
						RegDst=2'b00;
						NewState=4'b0000;
                    end
            4'b1000:begin//ALU computation2 (addu/slt/or step3)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'bXX;
						ALUOp=2'b11;
						ALUSrcB=2'b00;
						ALUSrcA=2'b01;
						RegWrite=0;
						RegDst=2'bXX;
						NewState=4'b1001;
                    end
            4'b1001:begin//addu write back (addu/slt/or/sll step4)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'b00;
						PCSource=2'bXX;
						ALUOp=2'bXX;
						ALUSrcB=2'bXX;
						ALUSrcA=2'bXX;
						RegWrite=1;
						RegDst=2'b01;
						NewState=4'b0000;
                    end
 			4'b1010:begin//beq completion (beq step3)
						PCWrite=0;
						PCWriteCond1=1;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'b01;
						ALUOp=2'b01;
						ALUSrcB=2'b00;
						ALUSrcA=2'b01;
						RegWrite=0;
						RegDst=2'bXX;
						NewState=4'b0000;
                    end
			4'b1011:begin//jump completion (j step3/jal step4) 
						PCWrite=1;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'b10;
						ALUOp=2'bXX;
						ALUSrcB=2'bXX;
						ALUSrcA=2'bXX;
						RegWrite=0;
						RegDst=2'bXX;
						NewState=4'b0000;
                    end
			4'b1100:begin//PC write back (jal step3)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'b11;
						PCSource=2'bXX;
						ALUOp=2'b00;
						ALUSrcB=2'b01;
						ALUSrcA=2'b00;
						RegWrite=1;
						RegDst=2'b10;
						NewState=4'b1011;
                    end
			4'b1101:begin//jr completion (jr step3)
						PCWrite=1;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'b11;
						ALUOp=2'bXX;
						ALUSrcB=2'bXX;
						ALUSrcA=2'bXX;
						RegWrite=0;
						RegDst=2'bXX;
						NewState=4'b0000;
                    end
			4'b1110:begin//ALU computation3 (sll step3)
						PCWrite=0;
						PCWriteCond1=0;
						PCWriteCond2=0;
						InstMemRead=0;
						DataMemRead=0;
						MemWrite=4'b0;
						IRWrite=0;
						MemtoReg=2'bXX;
						PCSource=2'bXX;
						ALUOp=2'b11;
						ALUSrcB=2'b00;
						ALUSrcA=2'b10;
						RegWrite=0;
						RegDst=2'bXX;
						NewState=4'b1001;
                    end
            4'b1111:begin //resetn
                      PCWrite=0;
                      PCWriteCond1=0;
                      PCWriteCond2=0;
                      InstMemRead=0;
                      DataMemRead=0;
                      MemWrite=4'b0;
                      IRWrite=0;
                      MemtoReg=2'bXX;
                      PCSource=2'b00;
                      ALUOp=2'b00;
                      ALUSrcB=2'bXX;
                      ALUSrcA=2'bXX;
                      RegWrite=0;
                      RegDst=2'bXX;
                      NewState=4'b0000;
                    end  
        endcase           
    end   
endmodule

module ALU_control(
    input [5:0] PreOperator,   //InstructionReg[31:26]
	input [5:0] PostOperator,   //InstructionReg[5:0]
    input [1:0] ALUOp,
    output reg [2:0] ALUoperator
);
    always @(PreOperator or PostOperator or ALUOp)
    begin
        case (ALUOp)
        2'b00:begin
                ALUoperator=3'b010;
              end
        2'b01:begin
                ALUoperator=3'b110;
              end
        2'b10:begin
		        case (PreOperator)
				6'b100011:ALUoperator=3'b010;   //LW
				6'b101011:ALUoperator=3'b010;   //SW
				6'b001001:ALUoperator=3'b010;   //ADDIU
				6'b001010:ALUoperator=3'b111;   //SLTI
				6'b001011:ALUoperator=3'b101;   //SLTIU
				6'b001111:ALUoperator=3'b011;   //LUI
				endcase
              end
		2'b11:begin
				case (PostOperator)
				6'b100001:ALUoperator=3'b010;   //ADDU
				6'b101010:ALUoperator=3'b111;   //SLT
				6'b100101:ALUoperator=3'b001;   //OR
				6'b000000:ALUoperator=3'b100;   //SLL
				endcase
		      end
        endcase
    end
endmodule