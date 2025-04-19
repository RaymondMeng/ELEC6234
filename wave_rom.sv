module wave_rom #(parameter Psize = 8, Isize = 8) // psize - address width, Isize - instruction width
(input logic [Psize-1:0] address,
output logic [Isize-1:0] I); // I - instruction code

// program memory declaration, note: 1<<n is same as 2^n
logic [Isize-1:0] progMem[ (1<<Psize)-1:0];

// get memory contents from file
initial
  $readmemh("C:/Users/Administrator/Desktop/order_taking/Sample_SystemVerilog_files_for_picoRISC_modules/Sample_SystemVerilog_files_for_picoRISC_modules/wave.hex", progMem); //读取程序指令到二维数组中，也就是个ram中
  
// program memory read 
always_comb
  I = progMem[address]; //根据地址取指令 总共能存储64条指令,每个指令24位宽数据
  
endmodule // end of module prog