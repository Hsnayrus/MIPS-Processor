module signExtender(data, clock, outputData);
	
	input [15:0] data;
	input clock;
	output [31:0] outputData;
	wire [15:0] zeros;
	reg [31:0] outputDataUnsigned;
	
	always @(posedge clock)begin
		
		if(data[15] == 1'b0)
			outputDataUnsigned = {16'h0000, data};
//		else
//		if(data < 1'd0)
//			outputDataUnsigned = {16'hFFFF, data};
		else
			outputDataUnsigned = {16'hFFFF, data};
	
	end
	assign outputData = outputDataUnsigned;
endmodule
