`timescale 1ns/1ps
`include "alucodes.sv"
module cpu #( parameter n = 8) // data bus width
( 
    input logic clk,  
    input logic [n:0] inport, //9个 sw input sw8判断是否输入
    input reset, // master reset
    output logic[n-1:0] outport // led output
);       
//TODO:先调流水线时序,再调IO输入输出时序
// declarations of local signals that connect CPU modules
// ALU
logic [2:0] ALUfunc; // ALU function
logic [3:0] flags; // ALU flags, routed to decoder
logic imm; // immediate operand signal
logic [n-1:0] Alub; // output from imm MUX
//
// registers
logic [n-1:0] Rdata1, Rdata2, Wdata; // Register data
logic w; // register write control
logic ld;
//
// Program Counter 
parameter Psize = 6; // up to 64 instructions
logic PCincr,PCabsbranch,PCrelbranch; // program counter control 程序计数器的控制，分别表示正常递增，绝对跳转和相对跳转
logic [Psize-1 : 0]ProgAddress; //程序计数器的值，用于从程序存储器中读取指令
// Program Memory
parameter Isize = n+16; // Isize - instruction width
logic [Isize-1:0] I; // I - instruction code


logic [8:0] sampled_i;
logic [7:0] led_o;
logic [7:0] rom_addr;
logic [7:0] rom_addr_base;
logic [7:0] wave_data;

//------------- code starts here ---------
//input/output buffer
always_ff @( posedge clk ) begin : input_output_buffer
        sampled_i <= inport;
end

// module instantiations
pc  #(.Psize(Psize)) progCounter (.clk(clk),.reset(reset),
        //通过以下三个信号来更新程序计数器的值
        .PCincr(PCincr),
        .PCabsbranch(PCabsbranch),
        .PCrelbranch(PCrelbranch),
        //跳转地址，可能是相对跳转，也可能是绝对跳转
        .Branchaddr(I[Psize-1:0]), //低6可以是地址也可能是立即数
        .PCout(ProgAddress) );


//程序存储器
prog #(.Psize(Psize),.Isize(Isize)) 
      progMemory (.address(ProgAddress),.I(I)); //从程序存储器中取出完整指令

//对指令进行解析，同时参考ALU的标志位，进而产生控制信号
decoder  D (.opcode(I[Isize-1:Isize-6]),
            .PCincr(PCincr),
            .PCabsbranch(PCabsbranch), 
            .PCrelbranch(PCrelbranch),
            .flags(flags), // ALU flags
	    .ALUfunc(ALUfunc),.imm(imm),.w(w), .ld(ld));

logic [n-1 : 0] reg_data;

regs   #(.n(n))  gpr(.clk(clk),.w(w),
                .Wdata(reg_data), //写入数据的地址是目的寄存器的地址，也就是addr2
                .data_in(sampled_i), //端口数据寄存器映射
                .data_out(led_o),
		.Raddr2(I[Isize-7:Isize-11]),  // reg %d number 目的寄存器
		.Raddr1(I[Isize-12:Isize-16]), // reg %s number 源寄存器
        .Rdata1(Rdata1),.Rdata2(Rdata2));

alu    #(.n(n))  iu(.a(Rdata1),.b(Alub), //两个操作数，一个是源寄存器的值，一个是Alub，具体是什么值由imm决定
       .func(ALUfunc),.flags(flags),
       .result(Wdata)); // ALU result -> destination reg  写回寄存器


assign reg_data = ld ? wave_data : Wdata;

// assign rom_addr_base = inport[7:0]; //输入的8位sw信号直接作为rom地址使用

// //TODO: 依次用传进去的地址取数据
wave_rom wave_rom_inst (
  .address(Rdata1),      // input wire [7 : 0] addr
  .I(wave_data)  // output wire [7 : 0] wave_data
);

// dist_mem_gen_0 your_instance_name (
//   .a(Rdata1),      // input wire [7 : 0] a
//   .spo(wave_data)  // output wire [7 : 0] spo
// );

// create MUX for immediate operand
assign Alub = (imm ? I[n-1:0] : Rdata2); //imm决定ALU的第二个操作数，imm==1，Alu第二个操作数是立即数，否则是目的寄存器的值

// // connect ALU result to outport
assign outport = led_o;

endmodule
