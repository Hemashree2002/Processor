module tb_processor_8bit;

	// Inputs
	reg [31:0] INSTRUCTION;
	reg CLK;
	reg RESET;

	// Outputs
	wire [7:0] ALU_OUT;
	wire [31:0] PC;
	wire ZERO;
	
	
	// Instruction memory
	
	reg [7:0] instruction_memory [31:0];
	
	always @ (PC)
	begin 
	
	#2
	INSTRUCTION = {instruction_memory[PC+3], instruction_memory[PC+2], instruction_memory[PC+1], instruction_memory[PC]};
	
	end
	
	initial begin
	
	{instruction_memory[10'd3], instruction_memory[10'd2], instruction_memory[10'd1], instruction_memory[10'd0]} = 32'b00000000000000110000000000000110;
	{instruction_memory[10'd7], instruction_memory[10'd6], instruction_memory[10'd5], instruction_memory[10'd4]} = 32'b00000001000001000000000000000011;
	{instruction_memory[10'd11], instruction_memory[10'd10], instruction_memory[10'd9], instruction_memory[10'd8]} = 32'b00000000000000110000000000000010;
	{instruction_memory[10'd15], instruction_memory[10'd14], instruction_memory[10'd13], instruction_memory[10'd12]} = 32'b00000010000000010000010000000011;
	{instruction_memory[10'd19], instruction_memory[10'd18], instruction_memory[10'd17], instruction_memory[10'd16]} = 32'b00000011000001100000010000000011;
	{instruction_memory[10'd23], instruction_memory[10'd22], instruction_memory[10'd21], instruction_memory[10'd20]} = 32'b00000011000001110000001100000100;
	{instruction_memory[10'd27], instruction_memory[10'd26], instruction_memory[10'd25], instruction_memory[10'd24]} = 32'b00000100000001010000001100000110;
	{instruction_memory[10'd31], instruction_memory[10'd30], instruction_memory[10'd29], instruction_memory[10'd28]} = 32'b00000101000000000000001100000001;
	
	end
	
	
	

	// Instantiate the Unit Under Test (UUT)
	processor_8bit uut (
		.ALU_OUT(ALU_OUT), 
		.PC(PC), 
		.INSTRUCTION(INSTRUCTION), 
		.CLK(CLK), 
		.RESET(RESET), 
		.ZERO(ZERO)
	);

	initial begin
		// Initialize Inputs
		INSTRUCTION = 0;
		CLK = 1'b0;
		RESET = 1'b0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		#2 
		RESET = 1'b1;
		
		#4
		RESET = 1'b0;
		
		
		forever
			#5 CLK = ~CLK;

	end
      
endmodule
