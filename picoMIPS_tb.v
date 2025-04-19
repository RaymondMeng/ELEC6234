`timescale 1ns/1ps
module tb_picoMIPS;
reg clk;
reg rst_n;
wire [7:0] out;
reg [8:0] in; 

picoMIPS4 picoMIPS4_inst(
    .clk(clk),  
    .SW(in), //9�? sw input sw8判断是否输入
    .rst_n(rst_n), // master reset
    .LED(out) // led output
);   

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

// initial begin
//     $dumpfile("tb_.vcd");
//     $dumpvars(0, tb_);
// end

initial begin
    #1 rst_n<=1'b0;clk<=1'b0;
    in <= 'd0;
    repeat(5) @(posedge clk);
    in[7:0] <= 'd10;
    repeat(5) @(posedge clk);
    in[8] <='d1;
    #(CLK_PERIOD*3) rst_n<=1;
    repeat(5) @(posedge clk);
    in[8] <='d0;

    repeat(50) @(posedge clk);
    in[7:0] <= 'd50;
    in[8] <='d1;
    repeat(5) @(posedge clk);
    in[8] <='d0;

    repeat(50) @(posedge clk);
    in[7:0] <= 'd100;
    in[8] <='d1;
    repeat(5) @(posedge clk);
    in[8] <='d0;

    repeat(100) @(posedge clk);
    $finish(2);
end

endmodule
