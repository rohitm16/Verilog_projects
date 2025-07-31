`timescale 1ns/1ps

module fifo_sync #(
     parameter Depth = 64,
     parameter  Width = 8)
    (input clk,
     input  resetn,  
     input [Width-1:0] data_in,
     input wr_en, rd_en,
     output [Width-1:0] data_out,    
     output empty, full);
     
     reg [Width-1:0] memory [0: Depth-1];
     
     wire do_write = wr_en && !full;
     wire do_read = rd_en && !empty;
     
     localparam addr_width = $clog2(Depth);
     // reason for addr_width+1 bit is that we will be able to count and store 2^addrwidth as a no 
     // i.e. to store 64 as a no we need 7 bits
     reg [addr_width:0] count; 
     reg [addr_width-1:0] rd_ptr,wr_ptr;
     
     
     always@(posedge clk)
        begin
            if(do_write) 
                    memory[wr_ptr] <= data_in;
        end            
      assign data_out = memory[rd_ptr];
                
      // pointer logic
      always@(posedge clk or negedge resetn)
        begin
            if(!resetn)
                begin
                    count <= 0;
                    rd_ptr <= 0;
                    wr_ptr <= 0;
                end  
            // if written below then this will never be execruted 
            else if(do_read && do_write)
                begin
                    rd_ptr <= rd_ptr +1;
                    wr_ptr <= wr_ptr +1;
                end
             else if (do_write)
                begin
                    wr_ptr <= wr_ptr +1;
                    count <= count +1;
                end        
             else if(do_read)
                begin
                    rd_ptr <= rd_ptr +1;
                    count <= count -1;
                end
          end
       
       assign empty = (count == 0);
       assign full = (count == Depth);
     endmodule