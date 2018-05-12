module multiplier_signed(
	input  wire clk,
	input  wire resetn,
	input  wire signed [31:0] mul_A,
	input  wire signed [31:0] mul_B,
	input  wire        mul_A_valid,
	input  wire        mul_B_valid,
	
	output reg  signed [63:0] mul_out,
	output reg         mul_validout
	);
	
	
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			mul_out      <= 64'd0;
			mul_validout <= 1'b0;
		end 
		else if (mul_A_valid && mul_B_valid) begin
			mul_out      <= mul_A * mul_B;
			mul_validout <= 1'b1;
		end
		else begin
			mul_validout <= 1'b0;
		end
	end
endmodule