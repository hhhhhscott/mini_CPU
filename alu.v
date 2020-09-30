module alu (alu_out, zero, data, accum, alu_clk, opcode); 
output [7:0]alu_out; 
output zero; 
input [7:0] data, accum; 
input [2:0] opcode; 
input alu_clk; 
reg [7:0] alu_out; 
parameter 				HLT =0;
parameter				SKZ =1; 
parameter				ADD =2; 
parameter				ANDD =3; 
parameter				XORR =4; 
parameter				LDA =5;
parameter				STO =6; 
parameter				JMP =7; 
assign zero = !accum; 
always @(posedge alu_clk) 
	begin //操作码来自指令寄存器的输出opc_iaddr<15..0>的低3位 
		casex (opcode) 
			HLT: alu_out<=accum; 
			SKZ: alu_out<=accum; //skip if zero
			ADD: alu_out<=data+accum; 
			ANDD: alu_out<=data&accum;
			XORR: alu_out<=data^accum; 
			LDA: alu_out<=data; //load data to accum
			STO: alu_out<=accum; //save accum to address
			JMP: alu_out<=accum; //jump address
			default: alu_out<=8'bxxxx_xxxx; 
		endcase 
	end 
endmodule