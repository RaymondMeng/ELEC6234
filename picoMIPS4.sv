// synthesise to run on Altera DE0 for testing and demo
module picoMIPS4(
  input logic clk,  // 50MHz Altera DE1 clock
  input logic [8:0] sw, // Switches SW0..SW9
  output logic [7:0] led,
  input rst_n); // key0
  
  logic slow_clk; // slow clock, about 10Hz
  
  counter c (.fastclk(clk),.clk(slow_clk), .rst_n(rst_n)); // slow clk from counter
  

  // to obtain the cost figure, synthesise your design without the counter 
  // and the picoMIPS4test module using Cyclone IV E as target
  // and make a note of the synthesis statistics
  cpu cpu_inst (.clk(slow_clk), .reset(~rst_n), .inport(sw[8:0]), .outport(led));
  
endmodule  