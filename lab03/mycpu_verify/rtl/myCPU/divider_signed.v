module divider_signed(
	input  wire clk,
	input  wire resetn,
	input  wire signed [31:0] dividend,
	input  wire signed [31:0] divisor,
	input  wire        div_A_valid,
	input  wire        div_B_valid,
	
	output reg  signed [63:0] div_out,
	output reg         div_validout
	);
	
	
	reg [63:0] A;
	reg [63:0] B;
	reg [31:0] Q;
	
	
	// 0: ä¸åœ¨ï¿??  1ï¿??
	reg   [5:0] state;
	reg   [5:0] nextstate;
	reg         sign_A;
	reg         sign_B;
	reg         valid_A;
	reg         valid_B;
	always @(posedge clk)
	begin
		if (!resetn) begin
			state = 0;
			div_validout = 0;
		end
		else
		case (state)
			6'd0:begin
					 div_validout = 0;
				     if (div_A_valid && div_B_valid)
				     begin
				         A = {32'd0,dividend};
						 B = {divisor,32'd0};
						 state = 1;
						 Q = 0;
						 sign_A = A[31];
						 sign_B = B[63];
						 if (sign_A) A[31:0] = ~A[31:0] + 1;
						 if (sign_B) B[63:32] = ~B[63:32] + 1;
						 A = A - B;
						 if (A[63] == 1'b1) begin
							 Q[0] = 0;
							 A = A + B; 
                         end
						 else ;							
					 end
					 else state = 0;
				 end
			6'd32:begin
			          state = 0;
				      div_validout = 1;
				      {A,Q} = {A,Q} << 1;
				      A = A - B;
					  if (A[63] == 1'b1) begin
                          Q[0] = 0;
                          A = A + B;
                      end
					  else 
					      Q[0] = 1;
					  if (sign_A ^sign_B) Q = ~Q + 1;
					  if (sign_A) A[63:32] = ~A[63:32] + 1;
                      div_out = {A[63:32],Q};
					  end
            default:begin
				       div_validout = 0;
				       {A,Q} = {A,Q} << 1;
				       A = A - B;
                       if (A[63] == 1'b1) begin
					       Q[0] = 0;
						   A = A + B;
					   end
					   else begin
					       Q[0] = 1;
					   end 							
					   state = state + 1;
				   end				
				
		endcase
	end
endmodule

	
