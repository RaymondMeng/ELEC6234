// opcodes.sv
//-----------------------------------------------------
// File Name   : opcodes.sv
// Function    : picoMIPS opcode definitions 
//               for example 28 Feb 14
// only 5 opcodes:   NOP, ADD, ADDI, SUBI, BNE
// Note that Opcodes are 6 bits long and
// the opcodes of ALU instructions have the
// required 3-bit ALU code in the lowest 3 bits
// Author:   tjk
// Last rev. 19 Apr 24
//-----------------------------------------------------

// NOP
`define NOP  6'b000000
// ADD %d, %s;  %d = %d+%s
`define ADD  6'b000010
// ADDI %d, %s, imm ;  %d = %s + imm
`define ADDI  6'b001010

`define SUB  6'b000011
// SUBI %d, %s, imm ;  %d = %s - imm
`define SUBI 6'b001011
// `define BNE %d, %s, imm; PC = (%d!=%s? PC+ imm : PC+1) 通过看zero flag
`define BNE  6'b011011
// `define BEQ %d, %s, imm; PC = (%d=%s? PC+ imm : PC+1) 通过看zero flag
`define BEQ  6'b010011
// `define BGE %d, %s, imm; PC = (%d>=%s? PC+ imm : PC+1)通过看negative flag 符号位
`define BGE  6'b100011
// `define BLO %d, %s, imm; PC = (%d<%s? PC+ imm : PC+1) 通过看overflow
`define BLO  6'b101011
//添加IN/OUT指令
// `define IN 6'b111000 //从sw0-sw7读取到寄存器
// `define OUT 6'b111001 //将寄存器输出到LED上
`define JUMP 6'b110000 //绝对值跳转

//添加LOAD指令 装载wave到寄存器中
`define LOAD 6'b101000
//添加MUL指令 alucode:111
`define MULTI 6'b000111

//read switch data  `define LOAD %d %s, imm; 
// `define LOAD 6'b  