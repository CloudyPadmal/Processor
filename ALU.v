module ALU
(
    input [15:0] A_bus, B_bus,
    input [2:0] ALU_OP,
    output reg [15:0] C_bus,
    output reg FLAG_Z
);
    
    parameter ADD = 3'd0, SUB = 3'd1, PASS = 3'd2, ZER = 3'd3, MUL4 = 3'd5, DIV2 = 3'd6;
    
    always @ (ALU_OP or A_bus or B_bus)
        begin
            case (ALU_OP)
                ADD: 
                    begin 
                        C_bus = A_bus + B_bus;
                        FLAG_Z = 0;
                    end
                SUB: 
                    begin 
                        C_bus = A_bus - B_bus;
                        FLAG_Z = (A_bus == 16'd0) ? 1'b1 : 1'b0;
                    end
                PASS: 
                    begin 
                        C_bus = B_bus;
                        if (A_bus == 16'd0) FLAG_Z = 1;
                    end
                ZER: 
                    begin
                        C_bus = 0;
                        FLAG_Z = 0;
                    end
                MUL4:
                    begin 
                        C_bus = A_bus << 2;
                        FLAG_Z = 0;
                    end
                DIV2:
                    begin 
                        C_bus = A_bus >> 1;
                        FLAG_Z = 0;
                    end
            endcase
        end

endmodule
/*
    ALU which can perform 7 Operations
*/
module talu;

    reg [15:0] A_bus;
    reg [15:0] B_bus;
    reg [2:0] ALU_OP;
    wire [15:0] C_bus;
    wire FLAG_Z=0;
    
    reg clk;

    // Clock
    initial begin
        clk = 1'b0;
        forever begin
            #1 clk = ~clk;
        end
    end
    
    alu uut(
        A_bus,B_bus,ALU_OP,C_bus,FLAG_Z
    );

    // Test
    initial begin
        #1 // Set lines with initial values
        A_bus = 16'b0000_1000_1111_0101;
        B_bus = 16'b0000_0100_1000_0101;
        ALU_OP = 3'd0;
        #2 // Set Operation
        ALU_OP = 3'd1;
        #2 // Set Operation
        ALU_OP = 3'd2;
        #2 // Set Operation
        ALU_OP = 3'd3;
        #2 // Set Operation
        ALU_OP = 3'd5;
        #2 // Set Operation
        ALU_OP = 3'd6;
        #4 // Finish
        $finish;
    end

endmodule
