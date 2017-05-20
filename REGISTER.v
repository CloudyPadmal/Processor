module REGISTER #(parameter BITS = 16)
(
    input CLOCK, LOAD, INCREMENT,
    input [BITS - 1:0] DATA,
    output reg [BITS - 1:0] OUT = 0
);
    
    always @ (posedge CLOCK)
        begin
            if (LOAD)
                OUT <= DATA;
            if (INCREMENT) 
                OUT <= OUT + 1;
        end
    
endmodule

module treg;
    
    reg clk;
    reg load;
    reg increment;
    reg [9:0] data_in;
    wire [9:0] data_out;

    // Clock
    initial begin
        clk = 1'b0;
        forever begin
            #1 clk = ~clk;
        end
    end
    
    REGISTER #(10) uut (
        clk, load, increment, data_in, data_out
    );
    
    // Test
    initial begin
        #1 // Set load = 1 and data to data_in
        load = 1'b1;
        data_in = 9'd15;
        #2 // Set load = 0 and data to data_in
        load = 1'b0;
        increment = 1'b1;
        data_in = 9'd23;
        #2 // Finish
        increment = 1'b0;
        #2
        $finish;
    end

endmodule