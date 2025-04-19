`include "alucodes.sv"
`include "opcodes.sv"
//---------------------------------------------------------
module decoder
( input logic [5:0] opcode, // top 6 bits of instruction
input [3:0] flags, // ALU flags 分别表示carry_flag进位标志，zeroflag零标志位（如果结果为0，该标志位被置1），negativeflag符号标志位（正负数标志位，1表示负数），overflowflag溢出标志位
// output signals
//    PC control
output logic PCincr,PCabsbranch,PCrelbranch,
//    ALU control
output logic [2:0] ALUfunc, 
// imm mux control
output logic imm,
//   register file control
output logic w,

output logic ld
  );
//TODO: 绝对值跳转没有写  PCabsbranch没有有效赋值操作
//------------- code starts here ---------
// instruction decoder
logic takeBranch; // temp variable to control conditional branching
always_comb 
begin
  // set default output signal values for NOP instruction
   PCincr = 1'b1; // PC increments by default
	PCabsbranch = 1'b0; PCrelbranch = 1'b0;
   ALUfunc = opcode[2:0]; 
   imm=1'b0; w=1'b0; 
   takeBranch =  1'b0; 
   ld = 1'b0;
   case(opcode)
      `NOP: ;
      `ADD, `SUB, `MULTI : begin // register-register  寄存器-寄存器操作指令
	        w = 1'b1; // write result to dest register 表示将结果写入目标寄存器
	    end
      `ADDI, `SUBI: begin // register-immediate  寄存器-立即数操作指令
	      w = 1'b1; // write result to dest register   表示将结果写入目标寄存器
		    imm = 1'b1; // set ctrl signal for imm operand MUX 表示选择立即数作为ALU的第二个操作数
	    end
	 	  // `IN: begin
      //   w = 1'b1;
      //   ALUfunc = `RB;
      //   // PCincr = 1'b0; //暂停PC递增
      // end
      `LOAD: begin
        ld = 1;
        w = 1'b1;
      end
      `JUMP: begin //跳转地址用程序指令的低六位表示
        PCincr = 1'b0; //禁止程序计数器正常递增
	      PCrelbranch = 1'b0;  //禁止相对跳转的操作
        PCabsbranch = 1'b1;  //进行绝对跳转的操作
      end
    // branches     //条件分支指令
      `BEQ: takeBranch = flags[1]; // branch if Z==1（相等则分支），就是用来判断两个数是否相等的if(a==b)...,是通过减法以及结合零标志位来间接实现比较
      `BNE: takeBranch = ~flags[1]; // branch if Z==0 （不相等则分支） if z==0 ,a≠b，执行下面的分支
      `BGE: takeBranch = ~flags[2]; // branch if N==0 （大于等于则分支） if n==0，a≥b，执行下面的分支
      `BLO: takeBranch = flags[0]; // branch if C==1 （低于则分支）if carry==1, 说明进位或者借位，a ≤ b，执行分支
      default:
          $error("unimplemented opcode %h",opcode);
 
  endcase // opcode
  
  if(takeBranch) // branch condition is true;满足条件分支跳转的条件
  begin
    PCincr = 1'b0; //禁止程序计数器正常递增
	  PCrelbranch = 1'b1;  //进行相对跳转的操作
  end


end // always_comb


endmodule //module decoder --------------------------------