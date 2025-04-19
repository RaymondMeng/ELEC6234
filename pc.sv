module pc #(parameter Psize = 6) // up to 64 instructions
(input logic clk, reset, PCincr,PCabsbranch,PCrelbranch, //pc递增信号、pc绝对地址跳转信号、pc相对地址跳转信号
 input logic [Psize-1:0] Branchaddr, //跳转地址
 output logic [Psize-1 : 0]PCout
);

//------------- code starts here---------
logic[Psize-1:0] Rbranch; // temp variable for addition operand 加法指令的变量
always_comb
  if (PCincr) //如果递增信号触发
       Rbranch = { {(Psize-1){1'b0}}, 1'b1}; //加法数为1
  else Rbranch =  Branchaddr; //否则就是绝对跳转或者相对跳转，将传入的跳转地址赋给RBranch

//输出程序计数器，根据控制参数决定程序如何执行，是自增1执行,还是跳转指令执行,跳转又分为绝对跳转和相对跳转
always_ff @ ( posedge clk or posedge reset) // async reset
  if (reset) // sync reset
     PCout <= {Psize{1'b0}};
  else if (PCincr | PCrelbranch) // increment or relative branch 如果是递增或者相对跳转分支
     PCout <= PCout + Rbranch; // 1 adder does both
  else if (PCabsbranch) // absolute branch
     PCout <= Branchaddr;
	//所输出的程序计数器值用来当作地址索引progMemory中存储的程序指令用于给译码器译码
endmodule // module pc