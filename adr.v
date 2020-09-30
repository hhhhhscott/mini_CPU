module adr(addr,fetch,ir_addr,pc_addr); 
output [12:0] addr; 
input [12:0] ir_addr, pc_addr; 
input fetch; 
assign addr = fetch? pc_addr : ir_addr; 
endmodule
//地址多路器用于选择输出的地址是PC（程序计数）地址还是数据/端口地址。每个指令周期的前4个时
//钟周期用于从ROM中读取指令，输出的应是PC地址。后4个时钟周期用于对RAM或端口的读写，该地址
//由指令中给出。地址的选择输出信号由时钟信号的8分频信号fetch提供。