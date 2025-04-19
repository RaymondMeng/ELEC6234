// counter for slow clock
module counter #(parameter n = 23) //clock divides by 2^n, adjust n if necessary
  (input logic fastclk, output logic clk, input logic rst_n);

logic [n-1:0] count;

always_ff @(posedge fastclk or negedge rst_n)begin
    if (rst_n == 1'b0) begin
        count <= 'd0;
    end
    else begin
        count <= count + 1;
    end
end
    

assign clk = count[n-1]; // slow clock

endmodule