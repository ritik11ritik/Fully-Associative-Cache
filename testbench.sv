`timescale 1ns/1ps
module tb;
  reg clk, rst;
  reg[7:0] addr;
  wire[7:0] out;  
  
  cache c1(.addr(addr),
           .clk(clk),
           .rst(rst),
           .out(out)
          );
  
  always #5 clk = ~clk;
  
  initial
    begin
      clk = 1'b0;
      rst = 1'b0;
      #10
      
      rst = 1'b1;      
      addr = 8'd10;
      #20
      
      addr = 8'd11;
      #20
      
      addr = 8'd12;
      #20
      
      addr = 8'd13;     
      #20
      
      addr = 8'd14;
      #20
      
      addr = 8'd12;
      #20
      
      addr = 8'd15;
      #20
      
      addr = 8'd16;
      #20
      
      addr = 8'd17;
      #20
      
      addr = 8'd18;
      #20
      
      addr = 8'd19;
      #100
      
      
      $finish;
    end
endmodule
  