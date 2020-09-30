module machine( inc_pc, load_acc, load_pc, rd,wr, load_ir, 
datactl_ena, halt, clk1, zero, ena, opcode );

output inc_pc, load_acc, load_pc, rd, wr, load_ir; 
output datactl_ena, halt; 
input clk1, zero, ena; 
input [2:0] opcode; 
reg inc_pc, load_acc, load_pc, rd, wr, load_ir; 
reg datactl_ena, halt; 
reg [2:0] state;

parameter 	HLT = 3 'b000, 
				SKZ = 3 'b001, 
				ADD = 3 'b010, 
				ANDD = 3 'b011, 
				XORR = 3 'b100, 
				LDA = 3 'b101, 
				STO = 3 'b110, 
				JMP = 3 'b111;
always @( negedge clk1 ) 
	begin 
		if ( !ena ) //接收到复位信号RST，进行复位操作 
			begin
				state<=3'b000; 
				{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
				{wr,load_ir,datactl_ena,halt}<=4'b0000; 
			end 
		else 
			ctl_cycle; 
	end
//-----------------begin of task ctl_cycle--------- 
task ctl_cycle; 
begin 
	casex(state) 
		0: //load high 8bits in struction 
			begin 
				{inc_pc,load_acc,load_pc,rd}<=4'b0001; 
				{wr,load_ir,datactl_ena,halt}<=4'b0100; 
				state<=1; 
			end 
		1: //pc increased by one then load low 8bits instruction 
			begin 
				{inc_pc,load_acc,load_pc,rd}<=4'b1001; 
				{wr,load_ir,datactl_ena,halt}<=4'b0100; 
				state<=2; 
			end 
		2: //idle 
			begin 
				{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
				{wr,load_ir,datactl_ena,halt}<=4'b0000; 
				state<=3; 
			end
		3: //next instruction address setup 分析指令从这里开始 
			begin 
				if(opcode==HLT) //指令为暂停HLT 
					begin
					{inc_pc,load_acc,load_pc,rd}<=4'b1000; 
					{wr,load_ir,datactl_ena,halt}<=4'b0001; 
					end 
				else 
					begin 
						{inc_pc,load_acc,load_pc,rd}<=4'b1000; 
						{wr,load_ir,datactl_ena,halt}<=4'b0000; 
					end 
				state<=4; 
			end
		4: //fetch oprand 
			begin 
				if(opcode==JMP) 
					begin 
						{inc_pc,load_acc,load_pc,rd}<=4'b0010; 
						{wr,load_ir,datactl_ena,halt}<=4'b0000; 
					end
				else	
					if( opcode==ADD || opcode==ANDD || opcode==XORR || opcode==LDA) 
						begin 
							{inc_pc,load_acc,load_pc,rd}<=4'b0001; 
							{wr,load_ir,datactl_ena,halt}<=4'b0000; 
						end 
					else 
						if(opcode==STO) 
							begin 
								{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
								{wr,load_ir,datactl_ena,halt}<=4'b0010; 
							end 
						else 
							begin 
								{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
								{wr,load_ir,datactl_ena,halt}<=4'b0000; 
							end 
				state<=5; 
			end
		5: //operation 
			begin 
				if ( opcode==ADD||opcode==ANDD|| opcode==XORR||opcode==LDA ) 
					begin //过一个时钟后与累加器的内容进行运算 
						{inc_pc,load_acc,load_pc,rd}<=4'b0101; 
						{wr,load_ir,datactl_ena,halt}<=4'b0000; 
					end 
				else 
					if( opcode==SKZ && zero==1) 
						begin 
							{inc_pc,load_acc,load_pc,rd}<=4'b1000; 
							{wr,load_ir,datactl_ena,halt}<=4'b0000; 
						end 
					else 
						if(opcode==JMP) 
							begin 
								{inc_pc,load_acc,load_pc,rd}<=4'b1010; 
								{wr,load_ir,datactl_ena,halt}<=4'b0000; 
							end 
						else 
							if(opcode==STO) 
								begin 
								//过一个时钟后把wr变1就可写到RAM中 
									{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
									{wr,load_ir,datactl_ena,halt}<=4'b1010; 
								end 
							else 
								begin 
									{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
									{wr,load_ir,datactl_ena,halt}<=4'b0000; 
								end 
				state<=6;
			end
		6: //idle 
			begin 
				if ( opcode==STO ) 
					begin 
						{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
						{wr,load_ir,datactl_ena,halt}<=4'b0010; 
					end 
				else 
					if ( opcode==ADD||opcode==ANDD|| opcode==XORR||opcode==LDA) 
						begin 
							{inc_pc,load_acc,load_pc,rd}<=4'b0001; 
							{wr,load_ir,datactl_ena,halt}<=4'b0000; 
						end 
					else 
						begin 
							{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
							{wr,load_ir,datactl_ena,halt}<=4'b0000; 
						end 
				state<=7; 
			end 
		7: // 
			begin 
				if( opcode==SKZ && zero==1 ) 
					begin 
						{inc_pc,load_acc,load_pc,rd}<=4'b1000; 
						{wr,load_ir,datactl_ena,halt}<=4'b0000; 
					end 
				else 
					begin 
						{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
						{wr,load_ir,datactl_ena,halt}<=4'b0000; 
					end 
				state<=0; 
			end 
		default: 
			begin 
				{inc_pc,load_acc,load_pc,rd}<=4'b0000; 
				{wr,load_ir,datactl_ena,halt}<=4'b0000; 
				state<=0; 
			end 
	endcase 
end 
endtask 
//-----------------end of task ctl_cycle---------
endmodule