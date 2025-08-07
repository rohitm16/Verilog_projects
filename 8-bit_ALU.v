    `timescale 1ns / 1ps
    
    module ALU(
        input [7:0] a,b,
        input [2:0] opcode, // for select the operation to be performed
        output reg [7:0] result,
        output wire Zero, // zero flag
        output reg carry_out,
        output reg overflow
        );
        
        //parameterizing the operations for simiplicity
        localparam  add=3'b000,
                    subtract = 3'b001,
                    bitwise_and = 3'b010,
                    bitwise_or = 3'b011,
                    bitwise_xor = 3'b100,
                    not_a = 3'b101,
                    increment_a = 3'b110,
                    pass_a = 3'b111;
                    
        always@(*)
            begin
            // need to assign some intial value to prevent the formation of latches
                result = 8'h00;
                carry_out = 1'b0;
                overflow = 1'b0;
                // different opeations
                case(opcode)
                    add: begin
                        {carry_out,result} = a+b;
                        overflow =(a[7] == b[7]) && (result[7] !== a[7]);
                        end
                    subtract: begin
                        {carry_out,result} = a-b;
                        overflow =(a[7] !== b[7]) && (result[7] !== a[7]);
                     end
                    bitwise_and: begin
                         result = a&b;
                     // there will be no change in carry_out and overlfow in this case
                     end
                    bitwise_or: begin
                         result = a|b;
                     end
                    bitwise_xor: begin
                         result = a^b;
                    end
                    not_a: begin
                         result= ~a;
                     end
                    increment_a:begin
                         {overflow,result}=a+1;
                         overflow = (a[7] == 0) && (result[7] == 1);
                     end
                    pass_a : result = a;
                    default: result = 8'h00;
                endcase
            end
    
        assign Zero = (result == 8'h00);
        
        
    endmodule
