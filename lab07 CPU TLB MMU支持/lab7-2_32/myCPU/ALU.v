module alu(
  input  wire [5:0]  aluop,
  input  wire [31:0] vsrc1,
  input  wire [31:0] vsrc2,
  output wire [31:0] result,
  output wire        overflow
);

wire alu_add;
wire alu_sub;
wire alu_sub_true;
wire alu_slt;
wire alu_sltu;



wire alu_and;
wire alu_lui;
wire alu_nor;
wire alu_or;
wire alu_xor;
wire alu_sll;
wire alu_sra;
wire alu_srl;

wire [31:0] add_sub_result;
wire [31:0] slt_result;
wire [31:0] sltu_result;
wire [31:0] and_result;
wire [31:0] lui_result;
wire [31:0] nor_result;
wire [31:0] or_result;
wire [31:0] xor_result;
wire [31:0] sll_result;
wire [31:0] sra_result;
wire [31:0] srl_result;
wire [63:0] sra64_result;
wire [63:0] srl64_result;

assign overflow = ((aluop == 6'b100000 || aluop == 6'b001000) && vsrc1[31] == vsrc2[31] && vsrc1[31] != add_sub_result[31] ||
                   aluop == 6'b100010 && vsrc1[31] != vsrc2[31] && vsrc1[31] != add_sub_result[31]) ? 1'b1 : 1'b0;
assign alu_add  = (aluop == 6'b100000 || aluop == 6'b001000 ||
                   aluop == 6'b100001 || aluop == 6'b001001);
assign alu_sub_true  = (aluop == 6'b100010 || aluop == 6'b100011);
assign alu_sub  = (aluop == 6'b100010 || aluop == 6'b100011 || aluop == 6'b101010 || aluop == 6'b001010 || aluop == 6'b101011 || aluop == 6'b001011);
assign alu_slt  = (aluop == 6'b101010 || aluop == 6'b001010);
assign alu_sltu = (aluop == 6'b101011 || aluop == 6'b001011);



assign alu_and  =(aluop == 6'b100100 || aluop == 6'b001100);
assign alu_lui  = aluop == 6'b001111;
assign alu_nor  = aluop == 6'b100111;
assign alu_or   =(aluop == 6'b100101 || aluop == 6'b001101);
assign alu_xor  =(aluop == 6'b100110 || aluop == 6'b001110);
assign alu_sll  =(aluop == 6'b000100 || aluop == 6'b000000);
assign alu_sra  =(aluop == 6'b000111 || aluop == 6'b000011);
assign alu_srl  =(aluop == 6'b000110 || aluop == 6'b000010);




assign and_result = vsrc1 & vsrc2;
assign or_result  = vsrc1 | vsrc2;
assign nor_result = ~or_result;
assign xor_result = vsrc1 ^ vsrc2;
assign lui_result = {vsrc2[15:0],16'd0};


wire [31:0] adder_a;
wire [31:0] adder_b;
wire        adder_cin;
wire [31:0] adder_result;
wire        adder_cout;

assign adder_a = vsrc1;
assign adder_b = vsrc2 ^ {32{alu_sub}};
assign adder_cin = alu_sub;
assign {adder_cout,adder_result} = adder_a + adder_b + adder_cin;
assign add_sub_result = adder_result;

assign slt_result[31:1] = 31'd0;
assign slt_result[0] = (vsrc1[31] & ~vsrc2[31]) |
                       (~(vsrc1[31]^vsrc2[31]) & adder_result[31]);
//assign slt_result[0] = vsrc1 < vsrc2 ;

assign sltu_result[31:1] = 31'd0;
assign sltu_result[0] = ~adder_cout;
//assign sltu_result = {1'b0,vsrc1} < {1'b0,vsrc2};

assign sll_result  = vsrc2 << vsrc1[4:0];
assign sra64_result = {{32{alu_sra & vsrc2[31]}},vsrc2[31:0]} >> vsrc1[4:0];
assign sra_result   = sra64_result[31:0];
assign srl64_result = {{32{1'b0}},vsrc2[31:0]} >> vsrc1[4:0];
assign srl_result   = srl64_result[31:0];




assign result = ({32{alu_add|alu_sub_true}} & add_sub_result) |
                ({32{alu_slt        }} & slt_result) |
				({32{alu_sltu       }} & sltu_result) |
				({32{alu_and        }} & and_result) |
				({32{alu_nor        }} & nor_result) |
				({32{alu_or         }} & or_result) |
				({32{alu_xor        }} & xor_result) |
				({32{alu_sll        }} & sll_result) |
				({32{alu_srl        }} & srl_result) |
				({32{alu_sra        }} & sra_result) |
				({32{alu_lui        }} & lui_result);

endmodule 