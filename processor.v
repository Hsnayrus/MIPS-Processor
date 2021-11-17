/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB                   // I: Data from port B of regfile
);
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input  [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
	 input [31:0] data_readRegA, data_readRegB;
	 
	 /* YOUR CODE STARTS HERE */
	 wire [4:0] rd, rs, rt, Opcode, ALU_op, shamt;
	 wire [31:0] dataOperandA, dataOperandB, signExtended;
	 wire [31:0] addressImem;
	 wire[31:0] aluOutput;
	 wire[15:0] immediate;
	 wire is_rType, is_addi, is_sw, is_lw, is_ovf, isNotEqual, isLessThan, overflow, is_add, is_sub, is_jiType, rstatus1;
	 
	 assign is_rType  = ~Opcode[4] && ~Opcode[3] && ~Opcode[2] && ~Opcode[1] && ~Opcode[0]; //00000
	 assign is_addi   = ~Opcode[4] && ~Opcode[3] && Opcode[2]  && ~Opcode[1] && Opcode[0];  //00101
	 assign is_sw     = ~Opcode[4] && ~Opcode[3] && Opcode[2]  && Opcode[1]  && Opcode[0];  //00111
	 assign is_lw     = ~Opcode[4] && Opcode[3]  && ~Opcode[2] && ~Opcode[1] && ~Opcode[0]; //01000
	 assign is_add    = is_rType && ~ALU_op[4] && ~ALU_op[3] && ~ALU_op[2] && ~ALU_op[1] && ~ALU_op[0]; // 00000
	 assign is_sub    = is_rType && ~ALU_op[4] && ~ALU_op[3] && ~ALU_op[2] && ~ALU_op[1] && ALU_op[0];  // 00001 
	 assign ALU_op    = is_rType? q_imem[6:2]  : 5'd0;   
	 assign shamt     = is_rType? q_imem[11:7] : 5'd0; //might be wrong? test this
	 
	 
	 //00001
	 assign is_j = ~Opcode[4] && ~Opcode[3] && ~Opcode[2]&& ~Opcode[1] && Opcode[0];
	 //00010
	 assign is_bne = ~Opcode[4] && ~Opcode[3] && ~Opcode[2]&& Opcode[1] && ~Opcode[0];
	 assign is_jal = ~Opcode[4] && ~Opcode[3] && ~Opcode[2]&& Opcode[1] && Opcode[0]; // 00011
	 assign is_jr = ~Opcode[4] && ~Opcode[3] && Opcode[2]&& ~Opcode[1] && ~Opcode[0]; // 00100
	 assign is_blt = ~Opcode[4] && ~Opcode[3] && Opcode[2]&& Opcode[1] && ~Opcode[0]; // 00110
	 assign is_bex = Opcode[4] && ~Opcode[3] && Opcode[2]&& Opcode[1] && ~Opcode[0]; // 10110
	 assign is_setx = Opcode[4] && ~Opcode[3] && Opcode[2]&& ~Opcode[1] && Opcode[0]; // 10101
	 assign is_jiType = is_j || is_jal || is_bex;
	 //rstatus != 0;
	 assign rstatus1 = ~(data_readRegA == 1'd0);
	 
	 assign Opcode    = q_imem[31:27];
	 assign rd        = is_jal ? 5'b11111 : q_imem[26:22];
	 assign rs        = is_bex ? 5'b11110 : q_imem[21:17];
	 assign rt        = q_imem[16:12];
	 assign immediate = q_imem[15:0];
	 
	 wire imemClock, dmem_clock, register_clock;
	 
	 
	 freqBy2 f1(clock, 1'b1, imemClock);
	 freqBy2 f2(imemClock, 1'b1, dmem_clock);
	 
	 pc pc1(q_imem, reset, imemClock, addressImem);
	 
	 //Old: assign address_imem = addressImem[11:0];
	 //New
	 assign address_imem = is_jiType ? ((is_bex ? (rstatus1 ? address_imem[11:0] : q_imem[11:0])) : q_imem[11:0]) : addressImem[11:0];
	 
	 
	
	 //My name is chun chun chun baba chun chun chun
	 signExtender E1(immediate, clock, signExtended);
		
	 //I type instructions and reset condition set registers to 0 remaining,as far as I can remember
	 assign ctrl_writeReg     = (is_rType) ? ((overflow &&(is_add || is_sub || is_addi)) ? 5'b11110 : rd) : rd ;
	 	 
	 //If its rtype then read from q_imem[26:22] else if its lw then dont read at all
//	 assign ctrl_readRegA     = (is_rType) ?             rs             : (is_addi ? rs : 5'b00000);

	assign ctrl_readRegA = is_sw ? rd : rs;

	 //it shoudl just be rs 
	 //Set to zero because the ALU will take dataOPerandB as input which will be set to sign Extended bit for calculation
	 
	 assign ctrl_readRegB     = (is_rType) ?             rt             : 5'b00000;
	 
	 
//assign ctrl_readRegB = (is_sw)  ? rd : rt;
	
	 assign ctrl_writeEnable  = is_sw  ? 1'b0 : 1'b1;
	 //Should be q_dmem instead of q_imem
	 assign data_writeReg     = (is_rType || is_addi) ? (overflow ? (is_add ? 1'd1 : (is_sub ? 1'd3 : (is_addi ? 1'd2 : aluOutput))) : aluOutput) : (is_sw ? (aluOutput): q_imem);
	 
	 assign dataOperandA      = data_readRegA;
	 
	 assign dataOperandB      = is_rType ? data_readRegB : signExtended;
	 
	 assign address_dmem      = aluOutput[11:0];
	 
	 assign data              = data_readRegB;
	 
	 assign wren              = is_sw;
	 
	 alu alu1(dataOperandA, dataOperandB, ALU_op, shamt, aluOutput, isNotEqual, isLessThan, overflow);
 
endmodule	




/* 03:51

always @*
	 case(Opcode)
		//In case its an r-type instruction
		0:begin
			case(ALU_op)
				final_readRegA   =	rs;
				assign dataOperandA = data_readRegA;
				assign dataOperandB = data_readRegB;
				assign ctrl_readRegB    = rt;					
				assign ctrl_writeReg    = rd;
				assign ctrl_writeEnable = 1'b1;
				assign data_writeReg    = aluOutput;
				5'b00000:begin
					assign ctrl_readRegA    = rs;
					assign ctrl_readRegB    = rt;		
					assign dataOperandA = data_readRegA;
					assign dataOperandB = data_readRegB;
					assign ctrl_writeEnable = overflow ? 1'b0         : 1'b1;
					assign ctrl_writeReg    = overflow ? 5'b11110     : rd;
					assign data_writeReg    = overflow ? 32'h00000001 : aluOutput;
				end
				5'b00001:begin
					assign ctrl_readRegA    = rs;
					assign ctrl_readRegB    = rt;
					assign dataOperandA = data_readRegA;
					assign dataOperandB = data_readRegB;
					assign ctrl_writeEnable = overflow ? 1'b0         : 1'b1;
					assign ctrlWriteReg     = overflow ? 5'b11110     : rd;
					assign data_writeReg    = overflow ? 32'h00000003 : aluOutput;
					end
			endcase
		end
		5'b00101:begin
			//Perform addition
			assign dataOperandA = data_readRegA;
			assign dataOperandB = signExtended;
//			alu alu1(data_readRegA, signExtended, 5'b00000, shamt, aluOutput, isNotEqual, isLessThan, overflow);
			assign ctrl_readRegA = rs;
			assign ctrl_readRegB = 32'h00000000;
			assign ctrl_writeReg = overflow    ? 5'b11110     : rd;
			assign ctrl_writeEnable = overflow ? 1'b0         : 1'b1;
			assign data_writeReg = overflow    ? 32'h00000002 : aluOutput;		
		end
		endcase*/





///**
// * READ THIS DESCRIPTION!
// *
// * The processor takes in several inputs from a skeleton file.
// *
// * Inputs
// * clock: this is the clock for your processor at 50 MHz
// * reset: we should be able to assert a reset to start your pc from 0 (sync or
// * async is fine)
// *
// * : input data from imem
// * Dmem: input data from dmem
// * Regfile: input data from regfile
// *
// * Outputs
// * Imem: output control signals to interface with imem
// * Dmem: output control signals and data to interface with dmem
// * Regfile: output control signals and data to interface with regfile
// *
// * Notes
// *
// * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
// * testbench can see which controls signal you active when. Therefore, there needs to be a way to
// * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
// * file acts as a small wrapper around your processor for this purpose.
// *
// * You will need to figure out how to instantiate two memory elements, called
// * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
// * 12-bit address and allow for storing a 32-bit value at each address. Each
// * should have a single clock.
// *
// * Each memory element should have a corresponding .mif file that initializes
// * the memory element to certain value on start up. These should be named
// * imem.mif and dmem.mif respectively.
// *
// * Importantly, these .mif files should be placed at the top level, i.e. there
// * should be an imem.mif and a dmem.mif at the same level as process.v. You
// * should figure out how to point your generated imem.v and dmem.v files at
// * these MIF files.
// *
// * imem
// * Inputs:  12-bit address, 1-bit clock enable, and a clock
// * Outputs: 32-bit instruction
// *
// * dmem
// * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
// * Outputs: 32-bit data at the given address
// *
// */
//module processor(
//    // Control signals
//    clock,                          // I: The master clock
//    reset,                          // I: A reset signal
//
//    // Imem
//    address_imem,                   // O: The address of the data to get from imem
//    q_imem,                         // I: The data from imem
//
//    // Dmem
//    address_dmem,                   // O: The address of the data to get or put from/to dmem
//    data,                           // O: The data to write to dmem
//    wren,                           // O: Write enable for dmem
//    q_dmem,                         // I: The data from dmem
//
//    // Regfile
//    ctrl_writeEnable,               // O: Write enable for regfile
//    ctrl_writeReg,                  // O: Register to write to in regfile
//    ctrl_readRegA,                  // O: Register to read from port A of regfile
//    ctrl_readRegB,                  // O: Register to read from port B of regfile
//    data_writeReg,                  // O: Data to write to for regfile
//    data_readRegA,                  // I: Data from port A of regfile
//    data_readRegB                   // I: Data from port B of regfile
//);
//    // Control signals
//    input clock, reset;
//
//    // Imem
//    output [11:0] address_imem;
//    input [31:0] q_imem;
//
//    // Dmem
//    output [11:0] address_dmem;
//    output [31:0] data;
//    output wren;
//    input [31:0] q_dmem;
//
//    // Regfile
//    output ctrl_writeEnable;
//    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
//    output [31:0] data_writeReg;
//    input [31:0] data_readRegA, data_readRegB;
//
//    /* YOUR CODE STARTS HERE */
//	wire[31:0] regDataA, regDataB, aluOutput, regWriteData, dmemData, signExtended, dataOperandA, dataOperandB;
////	wire[11:0] addressImem;
//	wire[4: 0] regA, regB, regDest, aluOpcode, shiftAmt, opCode;
//	wire Rwe, Rwd, iType;
//	wire isNotEqual, isLessThan, overflow;
//
//	imem imem1(address_imem, 1'b1, clock, qImem);
//	
//	assign qImem = q_imem;
//	
//	//Reset Logic
//	assign opcode = q_imem[31:27];
//	
//	case(opcode)begin
//	assign address_imem = reset ? 12'h000 : (address_imem + 3'b100);
//	
//	0:
//		begin
//		assign aluOpcode = q_imem[6:2];
//		assign Rwe = 1'b1;
//		assign regDest      = overflow ? 5'b1110      : q_imem[26:22];
//		assign regWriteData = Rwe ? (overflow ? 32'h0z0000001 : aluOutput) : 32'h00000000;
//		assign regA = q_imem[21:17];
//		assign regB = q_imem[16:12];
//		assign shiftAmt = q_imem[11:7];
//		end
//	7: 
//		begin
//		assign Rwd = 1'b1;
//		assign wren = 1'b0;
//		assign regDes = q_imem[26:22];
//		assign iType = 1'b1;
//		assign regA   = 32'h00000000;
//		assign regB   = 32'h00000000;
//		
//		signExtender s1(q_imem[15:0], clock, signExtended);
//			
//		assign dmemData = 32'h00000000;
//			
//		assign regWriteData = Rwd ? q_dmem : (overflow ? 32'h00000001 : aluOutput);
//		assign address_dmem = 
//		end
//endcase
//	
//	
//	dmem dmem1(address_dmem, clock, dmemData, q_dmem);
//	regfile reg1(clock, Rwe, reset, regDest, regA, regB, regWriteData, regDataA, regDataB);
//	
//	dataOperandA = iType ? regDataB : q_dmem;
//	
//	alu alu1(regDataA, regDataB, aluOpcode, shiftAmt, aluOutput, isNotEqual, isLessThan, overflow);
//	 
//	assign data_writeReg = 1'b1 ? regWriteData : 1'b0;
//	 
//endmodule
//
///*
//module regfile(
//clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB
//);
//
//   input clock, ctrl_writeEnable, ctrl_reset;
//   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
//   input [31:0] data_writeReg;
//
//   output [31:0] data_readRegA, data_readRegB;
//endmodule
//*/
//
///*
//module alu(data_operandA, data_operandB, ctrl_ALUopcode,
//			ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
//
//	input [31:0] data_operandA, data_operandB;
//	input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
//	output [31:0] data_result;
//	output isNotEqual, isLessThan, overflow;
//	
//*/



/* 00:22

signExtender s1(immediate, clock, signExtended);
	 
	 
//	 freqBy2 freqImem(clock, 1'b1, freqHalf);
//	 freqBy2 freqDmem(freqHalf, 1'b1, freqFourth);
//	 
//	 pc pcMain(address_imem, clock, addressImem);
//	 imem imemMain(addressImem, 1'b1, freqHalf, q_imem);
//	 
	 assign address_dmem = aluOutput[11:0];
	 
//	 dmem dmemMain(address_dmem, freqFourth, regDataB, wren, q_dmem);
	 
	 //Because rs is always q_imem[21:17] in r and I type instructions;
	 assign ctrl_readRegA = rs;
	 //Check if its an addi instruction and select 2nd register accordingly
	 assign ctrl_readRegB = is_addi ? 5'b00000 : rt;
	 assign ctrl_writeReg = rd;		
	 assign dataOperandA  = regDataA;
	 assign dataOperandB  = is_addi ? signExtended : regDataB;
	 assign wren = is_sw ? 1'b1 : 1'b0;
	 assign data_writeReg    = is_sw ? q_dmem : aluOutput;
	 //we do not have to write to register file in case of sw instruction. WE have to write to register files in all other cases;
	 assign ctrl_writeEnable = is_sw ? 1'b0 : 1'b1; 
	 
	 regfile reg1(clock, ctrl_writeEnable, reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg, regDataA, regDataB);
	 alu alu1(dataOperandA, dataOperandB, ALU_op, shamt, aluOutput, isNotEqual, isLessThan, overflow);
*/


