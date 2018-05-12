`ifdef PRJ1_FPGA_IMPL
	// the board does not have enough GPIO, so we implement a 4-bit ALU
    `define DATA_WIDTH 4
`else
    `define DATA_WIDTH 32
`endif

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output reg Overflow,
	output reg CarryOut,
	output reg Zero,
	output reg [`DATA_WIDTH - 1:0] Result
);

	// TODO: insert your code
	reg [`DATA_WIDTH - 1:0] add_A;
    reg [`DATA_WIDTH - 1:0] add_B;
    reg add_in;
    wire overflow,carryout;
    wire [`DATA_WIDTH - 1:0] result;
	
	add add_u( 
		.a(add_A),
		.b(add_B),
		.cin(add_in),
		.overflow(overflow),
		.carryout(carryout),
		.result(result)
	);
	
    always @(*)
    begin
        case (ALUop)
        //AND
        3'b000:begin
                 Result = A & B;
                 Overflow = 0;
                 CarryOut = 0;
                 Zero=~(|Result[`DATA_WIDTH - 1:0]);
               end
        //OR
        3'b001:begin
                 Result = A | B;
                 Overflow = 0;
                 CarryOut = 0;
                 Zero=~(|Result[`DATA_WIDTH - 1:0]);
               end
        //ADD
        3'b010:begin
                 add_A=A;
                 add_B=B;
                 add_in=0;
                 Result=result;
                 Zero=~(|Result[`DATA_WIDTH - 1:0]);
                 Overflow = overflow;
                 CarryOut = carryout;
               end
        //LUI  (join 16 zeros)
        3'b011:begin
                 Result = {B[15:0],16'b0};
                 Overflow = 0;
                 CarryOut = 0;
                 Zero=~(|Result[`DATA_WIDTH - 1:0]);
               end
        //SLL (let B move left A)
        3'b100:begin
                 Result = B << (A[4:0]);
                 Overflow = 0;
                 CarryOut = 0;
                 Zero=~(|Result[`DATA_WIDTH - 1:0]);
               end
        //SLTIU
        3'b101:begin
                 add_A=A;
                 add_B=B;
                 //add_in=1;
                 Result=result;
                 Overflow = overflow;
                 CarryOut = carryout;
                // if (CarryOut ==0) Result = 1; else Result = 0;
                 Zero=~(|Result[`DATA_WIDTH - 1:0]); 
                 if ({0,add_A}<{0,add_B}) Result = 1; else Result = 0;
               end
        //SUB
        3'b110:begin
                 add_A=A;
                 add_B=~B;
                 add_in=1;
                 Result=result;
                 Zero=~(|Result[`DATA_WIDTH - 1:0]);
                 Overflow = overflow;
                 CarryOut = carryout;
               end
        //SLT
        3'b111:begin
                 add_A=A;
                 add_B=~B;
                 add_in=1;
                 Result=result;
                 Overflow = overflow;
                 CarryOut = carryout;
                 if (Result[`DATA_WIDTH - 1]^Overflow==1) Result = 1; else Result = 0;
                 Zero=~(|Result[`DATA_WIDTH - 1:0]);
               end
        default:begin
                  Result = 0;
                  Overflow = 0;
                  CarryOut = 0;
                  Zero = 0;
                end
        endcase
    end
    
endmodule



module add(
            input [`DATA_WIDTH - 1:0] a,
            input [`DATA_WIDTH - 1:0] b,  
            input cin,
            output overflow,
            output carryout,
            output [`DATA_WIDTH - 1:0] result);
            
            wire [`DATA_WIDTH :0] in;
            wire [`DATA_WIDTH-1:0]t;
            wire [`DATA_WIDTH-1:0]d;
            wire [`DATA_WIDTH-1:0]D;
            wire [`DATA_WIDTH-1:0]T;
            genvar i; 
            assign in[0]=cin;
            generate
              for(i=0; i<`DATA_WIDTH; i=i+1) 
              begin: bit1
                assign d[i]=a[i]&b[i];
                assign t[i]=a[i]|b[i];
              end   
            endgenerate
            generate
              for (i=1; i<=8; i=i+1)
              begin: bit2
                assign D[i]=d[35-4*i]|t[35-4*i]&d[34-4*i]|t[35-4*i]&t[34-4*i]&d[33-4*i]|t[35-4*i]&t[34-4*i]&t[33-4*i]&d[32-4*i];
                assign T[i]=t[35-4*i]&t[34-4*i]&t[33-4*i]&t[32-4*i];
              end
            endgenerate
            assign in[4]=D[8]|T[8]&in[0];
            assign in[8]=D[7]|T[7]&D[8]|T[7]&T[8]&in[0];
            assign in[12]=D[6]|T[6]&D[7]|T[6]&T[7]&D[8]|T[6]&T[7]&T[8]&in[0];
            assign in[16]=D[5]|T[5]&D[6]|T[5]&T[6]&D[7]|T[5]&T[6]&T[7]&D[8]|T[5]&T[6]&T[7]&T[8]&in[0];
            assign in[20]=D[4]|T[4]&in[16];
            assign in[24]=D[3]|T[3]&D[4]|T[3]&T[4]&in[16];
            assign in[28]=D[2]|T[2]&D[3]|T[2]&T[3]&D[4]|T[2]&T[3]&T[4]&in[16];
            assign in[32]=D[1]|T[1]&D[2]|T[1]&T[2]&D[3]|T[1]&T[2]&T[3]&D[4]|T[1]&T[2]&T[3]&T[4]&in[16];
            generate
              for (i=1; i<=8; i=i+1)
              begin: bit3
                assign in[4*i-3]=d[4*i-4]|t[4*i-4]&in[4*i-4];
                assign in[4*i-2]=d[4*i-3]|t[4*i-3]&d[4*i-4]|t[4*i-3]&t[4*i-4]&in[4*i-4];
                assign in[4*i-1]=d[4*i-2]|t[4*i-2]&d[4*i-3]|t[4*i-2]&t[4*i-3]&d[4*i-4]|t[4*i-2]&t[4*i-3]&t[4*i-4]&in[4*i-4];
              end
            endgenerate
            generate
              for (i=0; i<`DATA_WIDTH; i=i+1)
              begin: bit4
                assign result[i]=a[i]^b[i]^in[i];
              end
            endgenerate
            assign carryout = in[`DATA_WIDTH] ^ cin;
            assign overflow = in[`DATA_WIDTH] ^ in[`DATA_WIDTH - 1];  
endmodule
