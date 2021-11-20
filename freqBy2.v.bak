module freqBy2(clock, reset, clock_out);
	input clock, reset;
	output reg clock_out;
	
	always @(posedge clock)begin
		if(~reset)
			clock_out <= 1'b0;
		else
			clock_out <= ~clock_out;	
	end
		
endmodule
