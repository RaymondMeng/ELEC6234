`include "alucodes.sv"  
module alu #(parameter n =8) (
   input logic [n-1:0] a, b, // ALU operands
   input logic [2:0] func, // ALU function code
   output logic [3:0] flags, // ALU flags V,N,Z,C  有没有溢出之类的
   output logic [n-1:0] result // ALU result
);       
//------------- code starts here ---------

// create an n-bit adder 
// and then build the ALU around the adder
logic[n-1:0] ar,b1;
logic [2*n-1:0]temp; // temp signals
always_comb
begin
   if(func==`RSUB)
      b1 = ~b + 1'b1; // 2's complement subtrahend
   else b1 = b;

   ar = a+b1; // n-bit adder
end // always_comb
   
// create the ALU, use signal ar in arithmetic operations
always_comb
begin
  //default output values; prevent latches 
  flags = 3'b0;
  result = a; // default
  temp = 'd0;
  case(func)
  	`RA   : result = a;
	`RB   : result = b;
   `RADD  : begin
	   result = ar; // arithmetic addition
      // V
      flags[3] = a[7] & b[7] & ~result[7] |  ~a[7] & ~b[7] 
                 &  result[7];
      // C
      flags[0] = a[7] & b[7]  |  a[7] & ~result[7] | b[7] 
                 & ~result[7];
   end
   `RSUB  : begin
	   result = ar; // arithmetic subtraction
      // V
      flags[3] = ~a[7] & b[7] & ~result[7] |  a[7] & ~b[7] 
                & result[7];
      // C - note: picoMIPS inverts carry when subtracting
      flags[0] = a[7] & ~b[7] |  a[7] & result[7] | ~b[7] 
                & result[7];
   end
   `RAND  : result = a & b;
   `ROR   : result= a | b;
   `RXOR  : result = a ^ b;
   // `RNOR  : result = ~ (a | b);
   `MUL   : begin
      temp = a*b; //16bit结果
      result = temp[2*n-2 : n-1]; //取bit14-bit7
   end
	
	default: $error("unimplemented opcode: %h",func);
	
endcase

 
    // calculate flags Z and N
  flags[1] = result == {n{1'b0}}; // Z
  flags[2] = result[n-1]; // N
 
 end //always_comb

endmodule //end of module ALU


