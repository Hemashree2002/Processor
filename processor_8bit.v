module alu(RESULT, ZERO, DATA1, DATA2, SELECT);

output [7:0] RESULT;
output ZERO;

input [7:0] DATA1;
input [7:0] DATA2;
input [2:0] SELECT;

reg [7:0] RESULT;
reg ZERO;

always @ (DATA1, DATA2, SELECT)
begin
case(SELECT)
3'b000 : RESULT = DATA2;
3'b001 : RESULT = DATA1 + DATA2;
3'b010 : RESULT = DATA1 & DATA2;
3'b011 : RESULT = DATA1 | DATA2;
default : RESULT = 8'b00000000;
endcase
end

always @ (RESULT)
begin
ZERO = ~ (RESULT[0] | RESULT[1] | RESULT[2] | RESULT[3] | RESULT[4] | RESULT[5] | RESULT[6] | RESULT[7]);
end

endmodule


module reg_file (IN_DATA, IN_ADDRESS, OUT1_ADDRESS, OUT2_ADDRESS, WRITE_ENABLE, CLK, RESET, OUT1, OUT2);

input [2:0] IN_ADDRESS;
input [2:0] OUT1_ADDRESS;
input [2:0] OUT2_ADDRESS;
input WRITE_ENABLE;
input [7:0] IN_DATA;
input CLK;
input RESET;

output [7:0] OUT1;
output [7:0] OUT2;

integer i;
reg [7:0] regFile [0:7]; 

/*always@(*)
begin
if (RESET == 1'b1) 
begin 
#2
for (i = 0; i < 8; i = i + 1) 
begin
regFile [i][7:0] = 8'b00000000 ; 
end 
end
end*/


always@(posedge CLK)
begin 
if(WRITE_ENABLE == 1'b1 && RESET == 1'b0) 
begin
#2 regFile [IN_ADDRESS] = IN_DATA; 
end 
end
 
assign #2 OUT1 = regFile[OUT1_ADDRESS];
assign #2 OUT2 = regFile[OUT2_ADDRESS];

endmodule


module Adder (PC_INPUT, RESULT);

input [31:0] PC_INPUT;
output [31:0] RESULT;

reg [31:0] RESULT;

always @ (PC_INPUT)
begin
 RESULT = PC_INPUT + 4;
end

endmodule

 
module mux2_1 (in0, in1, sel, out);
input sel;
input [7:0] in0;
input [7:0] in1;
output [7:0] out;
reg [7:0] out;

always @(in0,in1,sel)
begin
if(sel==1'b1) 
begin
out =in0;
end 
else 
begin
out =in1;
end
end    
endmodule


module my_2s_complement(in, result);
input [7:0] in;
output [7:0] result;
reg [7:0] result;

always@(*) 
begin
result = ~in;
result = result + 1'b1;
end
endmodule


module processor_8bit(ALU_OUT,PC,INSTRUCTION,CLK,RESET,ZERO);

input [31:0] INSTRUCTION;
input CLK;
input RESET;

output ZERO;
output [31:0] PC;
reg [31:0] PC;

output [7:0] ALU_OUT;
reg [7:0] ALU_OUT;

wire [31:0] PCRESULT;

reg write_Enable;
reg is_Add;
reg is_Immediate;
reg [2:0] aluop_select;
//reg read1_reg_address;
//reg read2_reg_address;
//reg write_reg_address;
reg [7:0] immediate_value;
//reg [31:0] pc_reset = -4;
wire [7:0] mux1out;
wire [7:0] mux2out;
wire [7:0] Alu_result;
wire [7:0] minus_value;

reg [7:0] IN_DATA;
wire [7:0] OUT1;
wire [7:0] OUT2;

reg [7:0] OPCODE;
reg [2:0] DESTINATION;  
reg [2:0] SOURCE1; 
reg [2:0] SOURCE2;

always@(RESET)
//reseting the pc if reset is on
begin
	if(RESET ==1)  
		PC = -4;
end

Adder myadder(PC,PCRESULT);

always@(posedge CLK)
begin
  #1
  PC = PCRESULT;
end

always @ (INSTRUCTION)
begin

OPCODE = INSTRUCTION[31:24];
#1
case(OPCODE)

8'b00000000: 
begin
write_Enable = 1'b1;
aluop_select = 3'b000;
is_Add = 1'b1;
is_Immediate = 1'b1;
end

8'b00000001:
begin
write_Enable = 1'b1;
aluop_select = 3'b000;
is_Add = 1'b1;
is_Immediate = 1'b0;
end

8'b00000010:
begin
write_Enable = 1'b1;
aluop_select = 3'b001;
is_Add = 1'b1;
is_Immediate = 1'b0;
end

8'b00000011:
begin
write_Enable = 1'b1;
aluop_select = 3'b001;
is_Add = 1'b0;
is_Immediate = 1'b0;
end

8'b00000100:
begin 
write_Enable = 1'b1;
aluop_select = 3'b010;
is_Add = 1'b1;
is_Immediate = 1'b0;
end

8'b00000101:
begin
write_Enable = 1'b1;
aluop_select = 3'b011;
is_Add = 1'b1;
is_Immediate = 1'b0;
end
endcase
end

reg_file myReg(IN_DATA, DESTINATION, SOURCE1, SOURCE2, write_Enable, CLK, RESET, OUT1, OUT2);

always @ (INSTRUCTION)
begin
DESTINATION = INSTRUCTION[18:16];
SOURCE1 = INSTRUCTION[10:8];
SOURCE2 = INSTRUCTION[2:0];
immediate_value = INSTRUCTION[7:0];
end

my_2s_complement my2(OUT2, minus_value);

mux2_1 mymux1 (OUT2, minus_value, is_Add, mux1out); 
mux2_1 mymux2 (immediate_value, mux1out, is_Immediate, mux2out); 

alu myalu (Alu_result, ZERO, OUT1, mux2out, aluop_select);
// RESULT, ZERO, DATA1, DATA2, SELECT
always @ (Alu_result)
begin 
IN_DATA = Alu_result;
end

always @ (posedge CLK)
begin 
ALU_OUT = Alu_result;
end

endmodule
