`timescale 1ns/1ps

module cache(
  input[7:0] addr,
  input clk, rst,
  output[7:0] out
);
  
  reg[7:0] RAM_data[0:255];          // RAM
  reg[2:0] ml_seq[0:7];				// Most used, Least used sequence
  reg[7:0] data_mem[0:7]; 		// Cache memory
  reg[7:0] tag[0:7];			// Cache Tag (address)
  //reg[7:0] valid_data;			// Valid data in cache memory
  reg[0:7] valid_seq;			// Valid element in ml_seq and cache memory
  reg[3:0] seq_cnt;				// Number of elements used in cache memory
  reg[7:0] op;					// Output register
  reg[7:0] tmp, tmp2, tmp3;
  
  integer i, j, k, cnt=0, break_loop = 0;
  
  assign out = op;
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(1,cache);
    end
  
  initial
    begin
      for(i=0;i<256;i=i+1)
        begin
          RAM_data[i] = i;
        end
    end
  
  initial
    begin
      for(j=0;j<8;j=j+1)
        begin
          ml_seq[j] = 0;
          data_mem[j] = 0;
          tag[j] = 0;
          valid_seq[j] = 0;
        end
    end
  
  always @(*)
    begin
      if (rst == 1'b0)
        begin
          for(j=0;j<8;j=j+1)
            begin
              ml_seq[j] = 0;
              data_mem[j] = 0;
              tag[j] = 0;
              valid_seq[j] = 0;
              cnt=0;
            end
        end
    end
  
  always @(negedge clk)
    begin
      if(rst == 1'b1)
        begin
          // HIT
          cnt=0;
          break_loop = 0;
          for(i=0;i<8 && break_loop == 0;i=i+1)
            begin
              if (addr == tag[i])
                begin
                  $display($realtime);
                  $display("HIT");
                  op = data_mem[i];
                  cnt = cnt-1; 
                  break_loop = 1;
                  for(j=i;j<seq_cnt && j<7;j=j+1)
                    begin
                      tmp = ml_seq[j];
                      ml_seq[j] = ml_seq[j+1];
                      ml_seq[j+1] = tmp;
                      tmp2 = data_mem[j];
                      data_mem[j] = data_mem[j+1];
                      data_mem[j+1] = tmp2;
                      tmp3 = tag[j];
                      tag[j] = tag[j+1];
                      tag[j+1] = tmp3;
                    end
                end
              cnt = cnt + 1;
            end 
          
          // MISS
          if(cnt == 8)
            begin
              $display($realtime);
              $display("MISS");
              if (seq_cnt == 4'b1111 && (addr[0] == 1'b1 || addr[0] == 1'b0))
                begin
                  tag[0] = addr;
                  data_mem[0] = RAM_data[addr];
                  ml_seq[0] = 0;
                  valid_seq[0] = 1;
                  op = RAM_data[addr];
                end

              else if (seq_cnt != 4'b0111 && (addr[0] == 1'b1 || addr[0] == 1'b0))
                begin
                  tag[seq_cnt[2:0]+1] = addr;
                  data_mem[seq_cnt[2:0]+1] = RAM_data[addr];
                  ml_seq[seq_cnt[2:0]+1] = seq_cnt[2:0]+1;
                  valid_seq[seq_cnt[2:0]+1] = 1;
                  op = RAM_data[addr];
                end
              else if(addr[0] == 1'b0 || addr[0] == 1'b1)
                begin
                  tag[0] = addr;
                  data_mem[0] = RAM_data[addr];
                  op = RAM_data[addr];
                  for(j=0;j<7;j=j+1)
                    begin
                      tmp = ml_seq[j];
                      ml_seq[j] = ml_seq[j+1];
                      ml_seq[j+1] = tmp;
                      tmp2 = data_mem[j];
                      data_mem[j] = data_mem[j+1];
                      data_mem[j+1] = tmp2;
                      tmp3 = tag[j];
                      tag[j] = tag[j+1];
                      tag[j+1] = tmp3;
                    end
                end
            end
        end    
    end
   
  always @(valid_seq)
    begin
      if (valid_seq[7] == 1'b1)
        seq_cnt = 4'b0111;
      else if(valid_seq[6] == 1'b1)
        seq_cnt = 4'b0110;
      else if(valid_seq[5] == 1'b1)
        seq_cnt = 4'b0101;
      else if(valid_seq[4] == 1'b1)
        seq_cnt = 4'b0100;
      else if(valid_seq[3] == 1'b1)
        seq_cnt = 4'b0011;
      else if(valid_seq[2] == 1'b1)
        seq_cnt = 4'b0010;
      else if(valid_seq[1] == 1'b1)
        seq_cnt = 4'b0001;
      else if(valid_seq[0] == 1'b1)
        seq_cnt = 4'b0000;
      else if(valid_seq[0] == 1'b0)
        seq_cnt = 4'b1111;
      else
        seq_cnt = 4'b1000;
    end    
endmodule