`timescale 1ns / 1ps
// 

module four_way_traffic_light(
    input clk,
    // async reset
    input resetn, 
    // outputs from the fsm
    output reg [2:0] light_highway, // Red, Yellow, Green
    output reg [2:0] light_farm
    );
    
    reg [2:0] state_reg, state_next;
    
    //states paramterization
    localparam  Default = 3'b000,
                highway_Green = 3'b001,
                highway_Yellow = 3'b010,
                All_Red_HW_to_Farm = 3'b11,
                Farm_Road_Green = 3'b100,
                Farm_Road_Yellow = 3'b101,
                All_Red_Farm_to_HW = 3'b110;
                   
    // state_transition logic
     always@(posedge clk, negedge resetn)
        begin
        if(!resetn)
            state_reg <= Default;
        else
            state_reg <= state_next;
        end
            
   
          
       // counter
    reg [4:0] count; // to count till 25(at max)    
    wire change ;
    reg state_reg_dly; // just to detect change in state
    // counter reseting logic
    always@(posedge clk)
        begin
        if(change)
            count <= 5'd0;
        else
            count <= count + 1;
        end
        
    assign change = state_reg[0]^state_reg_dly;
    
         
    // next state logic
    always@(*)
        begin
            state_next = state_reg;
            
            case(state_reg)
             Default: state_next <= highway_Green; // unconditionaly moves to next state
             highway_Green: 
                begin
                    if(count == 25)
                        state_next <= highway_Yellow;
                end
             highway_Yellow:
                begin
                    if(count == 5)
                        state_next <= All_Red_HW_to_Farm;
                end
             All_Red_HW_to_Farm:
                begin
                    if(count == 2)
                        state_next <= Farm_Road_Green;
                end
             Farm_Road_Green:
                begin
                    if(count ==15)
                        state_next <= Farm_Road_Yellow;                      
                end
             Farm_Road_Yellow:
                begin
                    if(count == 5)
                        state_next <=All_Red_Farm_to_HW;
                end
             All_Red_Farm_to_HW:
                begin
                    if(count == 2)
                        state_next <= highway_Green;
                end
             default: state_next <= Default;
        endcase
       end

    //output  logic
    always@(posedge clk) 
        begin
            case(state_reg)
                Default: begin
                    light_highway <=3'b100;
                    light_farm <= 3'b100;
                    end
                highway_Green: begin
                     light_highway <=3'b001;
                    light_farm <= 3'b100;                   
                    end
                highway_Yellow: begin
                    light_highway <=3'b010;
                    light_farm <= 3'b100;
                    end
                All_Red_HW_to_Farm: begin 
                    light_highway <=3'b100;
                    light_farm <= 3'b100;                   
                    end 
                Farm_Road_Green: begin
                    light_highway <=3'b100;
                    light_farm <= 3'b001;
                    end
                Farm_Road_Yellow: begin
                    light_highway <=3'b100;
                    light_farm <= 3'b010;                   
                    end     
                All_Red_Farm_to_HW: begin 
                    light_highway <=3'b100;
                    light_farm <= 3'b100;                   
                    end         
        endcase
        end
    
endmodule
