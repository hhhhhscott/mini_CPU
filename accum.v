module accumulator( accum, data, ena, clk1, rst); 
output[7:0]accum; 
input[7:0]data; 
input ena,clk1,rst; 
reg[7:0]accum;
always@(posedge clk1) 
	begin 
		if(rst) 
			accum<=8'b0000_0000; //Reset
		else 
			if(ena) //当CPU状态控制器发出load_acc信号 
				accum<=data; //Accumulate 
	end

endmodule