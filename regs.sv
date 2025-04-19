module regs #(parameter n = 8) // n - data bus width
(input logic clk, w, // clk and write control
 input logic [n-1:0] Wdata,
 input logic [n:0] data_in,
 input logic [4:0] Raddr1, Raddr2,
 output logic [n-1:0] data_out,
 output logic [n-1:0] Rdata1, Rdata2);

 	// Declare 32 n-bit registers 
	logic [n-1:0] gpr [31:0];

	
	// write process, dest reg is Raddr2
	always_ff @ (posedge clk)
	begin
		if (w)
            gpr[Raddr2] <= Wdata;
	end

	// read process, output 0 if %0 is selected  0地址是0
	always_comb
	begin
	   	if (Raddr1==5'd0)
	        Rdata1 =  {n{1'b0}};
        else if(Raddr1=='d30)
			Rdata1 =  {7'd0, data_in[8]};  //读取输入端口的sw8
		else if(Raddr1=='d31)
			Rdata1 =  data_in[7:0];  //读取输入端口的sw7~0	
		else
			Rdata1 = gpr[Raddr1];
	 
        if (Raddr2==5'd0)
	        Rdata2 =  {n{1'b0}};
		else if(Raddr2=='d30)
			Rdata2 =  {7'd0, data_in[8]};  //读取输入端口的sw8
		else if(Raddr2=='d31)
			Rdata2 =  data_in[7:0];  //读取输入端口的sw7~0	
	  	else  Rdata2 = gpr[Raddr2];
	end	

assign data_out = gpr[29];

endmodule // module regs