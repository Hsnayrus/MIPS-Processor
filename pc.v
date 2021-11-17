//Perfectly working pc
module pc(pc, reset, clock, pc_next);
	input[31:0] pc;
	input clock, reset;
	reg[31:0] pc_reg;
	output[31:0] pc_next;
	reg[31:0] pc_next_reg;
	always @(posedge clock)begin
		pc_reg <= pc;
		pc_next_reg <= pc_next;
		if(reset)
			pc_next_reg <= 12'h000;
		else begin
			pc_reg <= pc_next_reg;
			pc_next_reg <= pc_reg + 1'b1;
		end
	end
	assign pc_next = pc_next_reg;
endmodule

























////module pc(pc, reset, clock, pc_next);
////	input[31:0] pc;
////	input clock, reset;
////	output[31:0] pc_next;
////	assign pc_next = reset ? 32'h000 : (pc + 1'b1);
////endmodule
//module pc(pc, reset, clock, pc_next);
//	input[11:0] pc;
//	reg[11:0] pc_reg;
//	input clock, reset;
//	output[11:0] pc_next;
//	reg[11:0] pc_next_reg;
//	initial @(posedge clock)begin
//		pc_reg <= pc;
//		pc_next_reg <= pc_next;
//		if(reset)
//			pc_next_reg <= 12'h000;
//		else begin
//			pc_reg <= pc_next_reg;
//			pc_next_reg <= pc_reg + 1'b1;
//		end
//	end
//	assign pc = pc_reg;
//	assign pc_next = pc_next_reg;
//endmodule
//////assign address_dmem = aluOutput[11:0];
