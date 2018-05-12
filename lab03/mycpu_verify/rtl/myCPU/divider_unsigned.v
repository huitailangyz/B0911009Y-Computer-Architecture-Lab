module divider_unsigned(
	input  wire clk,
	input  wire resetn,
	input  wire unsigned [31:0] dividend,
	input  wire unsigned [31:0] divisor,
	input  wire        div_A_valid,
	input  wire        div_B_valid,
	
	output reg  unsigned [63:0] div_out,
	output reg         div_validout
	);
	
	
	reg [63:0] A;
	reg [63:0] B;
	reg [31:0] Q;
	
	

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
						 if (A < B) begin
							 Q[0] = 0;
							 
                         end
						 else begin
							 A = A - B; 
							 Q[0] = 1;
						 end
				     end
					 else state = 0;
				 end
			6'd32:begin
			          state = 0;
				      div_validout = 1;
				      {A,Q} = {A,Q} << 1;
				      
					  if (A < B) begin
							 Q[0] = 0;
							 
                         end
						 else begin
							 A = A - B; 
							 Q[0] = 1;
						 end
					  
					  div_out = {A[63:32],Q};
			      end
            default:begin
				       div_validout = 0;
				       {A,Q} = {A,Q} << 1;
				       if (A < B) begin
							 Q[0] = 0;
							 
                         end
						 else begin
							 A = A - B; 
							 Q[0] = 1;
						 end						
					   state = state + 1;
				   end				
				
		endcase
	end
endmodule

	
