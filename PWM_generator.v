`timescale 1ns / 1ps

module pwm_generator #(parameter clk_frequency = 450_000_000)(
    // 450 Mhz clk of Nexys A7-100T
    input clk,
    input resetn,
    input [1:0]freq_select, // for selecting 1 frequency out of 4 frequencies
    input [7:0] duty_cycle, // for better resolution we took 8 bits. 0 - 255
    output reg pwm_out
    );
    
    //using localparam, so that they are calculated before the compile time
    localparam freq_1KHz = clk_frequency/1_000;
    localparam freq_10KHz = clk_frequency/10_000;
    localparam freq_50KHz = clk_frequency/50_000;
    localparam freq_100KHz = clk_frequency/100_000;
    
    localparam counter_width = $clog2(freq_1KHz); 
    reg [counter_width-1:0] period_reg;     //  to hold the selected period value
    reg [counter_width-1:0] duty_compare_reg; // to hold the calculated duty cycle compare value
    reg [counter_width-1:0] counter_reg;      // our main counter
    
    // Period Selection Logic 
    always@(*)
        begin
            case(freq_select)
            2'b00: period_reg = freq_1KHz;
            2'b01: period_reg = freq_10KHz;
            2'b10: period_reg = freq_50KHz;
            2'b11: period_reg = freq_100KHz;
            default: period_reg = freq_1KHz;
            endcase
        end
        
      // duty cycle logic
      always@(*)
        begin
            //  to calculate the desire duty period by multiplying it with ( ditycycle/2^8)
            duty_compare_reg = (period_reg * duty_cycle) >> 8;
        end

        // counter and PWM  logic
        always@(posedge clk or negedge resetn)
            begin
                if(!resetn)
                    begin
                        counter_reg <= 0;
                        pwm_out <= 0;
                    end
                 else begin
                            // counter increment logic
                         if (counter_reg >= period_reg - 1)
                                counter_reg <= 0;
                         else 
                                counter_reg <= counter_reg + 1;
                             //   pwm output logic 
                        if(counter_reg < duty_compare_reg)
                            pwm_out <=1;
                        else
                            pwm_out <=0;
                    end
           end                     
endmodule
