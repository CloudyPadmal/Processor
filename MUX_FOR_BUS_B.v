module MUX_FOR_BUS_B
(
    // Inputs
    input [3:0] SELECT,
    input [15:0] PC, R1, R2, TR, R, AC, AR,
    input [7:0] INSTRUCTIONS, DATA_FROM_RAM,
    // Outputs
    output reg [15:0] BUS
);
    
    always @ (*)
        begin
            case(SELECT)
                4'd0: BUS = {8'b0000_0000, DATA_FROM_RAM};
                4'd1: BUS = PC;
                4'd2: BUS = R1;
                4'd3: BUS = R2;
                4'd4: BUS = TR;
                4'd5: BUS = R;
                4'd6: BUS = AC;
                4'd7: BUS = {8'b0000_0000, INSTRUCTIONS};
                4'd8: BUS = AR;
            endcase
        end

endmodule
/*
    Demux whenever an input changes, output will be drawn
    by the SELECT as the line selector. Output line will be
    16 bits.
*/
module tdmux;
    
    reg CLOCK;
    reg [3:0] SELECT;
    reg [15:0] PC, R1, R2, TR, R, AC, AR;
    reg [7:0] DATA_FROM_RAM, INSTRUCTIONS;
    wire [15:0] BUS;

    // Clock
    initial begin
        CLOCK = 1'b0;
        forever begin
            #1 CLOCK = ~CLOCK;
        end
    end
    
    MUX_FOR_BUS_B uut(
        SELECT, PC, R1, R2, TR, R, AC, AR, INSTRUCTIONS, DATA_FROM_RAM, BUS
    );
    
    // Test
    initial begin
        #1 // Set lines with initial values
        PC = 16'b0001_0000_1000_0000;
        R1 = 16'b0000_1000_1000_0000;
        R2 = 16'b0000_0100_1000_0000;
        TR = 16'b0000_0010_1000_0000;
        R = 16'b0000_0001_1000_0000;
        AC = 16'b0000_0000_1100_0000;
        AR = 16'b0000_0100_1100_0000;
        DATA_FROM_RAM = 8'b0101_0101;
        INSTRUCTIONS = 8'b0111_0111;
        #2 // Set SELECT
        SELECT = 4'b0000;
        #2 // Set SELECT
        SELECT = 4'b0001;
        #2 // Set SELECT
        SELECT = 4'b0010;
        #2 // Set SELECT
        SELECT = 4'b0011;
        #2 // Set SELECT
        SELECT = 4'b0100;
        #2 // Set SELECT
        SELECT = 4'b0101;
        #2 // Set SELECT
        SELECT = 4'b0110;
        #2 // Set SELECT
        SELECT = 4'b0111;
        #2 // Set SELECT
        SELECT = 4'b1000;
        #4 // Finish
        $finish;
    end

endmodule
