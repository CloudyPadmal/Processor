module BRIDGE
(
    // Inputs
    input MAIN_CLOCK,
    input RECEIVED_8_BITS_FLAG, TRANSMITTED_8_BITS_FLAG,
    input [7:0] DATA_FROM_RAM,
    // Outputs
    output reg DATA_RECEIPTION_COMPLETE_FLAG = 1'b0,
    output reg [7:0] DATA_TO_TRANSMIT,
    output reg START_PROCESSING = 1'b0,
    output reg [15:0] RAM_ADDRESS = 16'b0000_0000_0000_0000,
    output reg WRITE_TO_RAM = 1'b1
);
    
    localparam RAM_BITS = 16'd10; // d65535
    
    /**************************************************************************
     * > RECEIVED_8_BITS_FLAG will be asserted when 8 bits have been cached
     * > TRANSMITTED_8_BITS_FLAG will be asserted when 8 bits have been sent
    **************************************************************************/
    always @ (posedge MAIN_CLOCK)
        begin
            /******************************************************************
             * When all the bits have arrived and the last bit is also there as
             * indicated by the received 8 bits flag, begin processing the data
             * switching the bus line to RAM bus, disconnecting it from UART RX
            ******************************************************************/
            if (RAM_ADDRESS == RAM_BITS && RECEIVED_8_BITS_FLAG) begin
                WRITE_TO_RAM <= 1'b0;
                RAM_ADDRESS <= 16'd0;
                START_PROCESSING <= 1'b1;
                DATA_TO_TRANSMIT <= DATA_FROM_RAM;
                DATA_RECEIPTION_COMPLETE_FLAG <= 1'b1;
            end
            /******************************************************************
             * When the bits are coming, increase RAM address by one to store
            ******************************************************************/
            else if (RECEIVED_8_BITS_FLAG && WRITE_TO_RAM) begin
                RAM_ADDRESS <= RAM_ADDRESS + 16'd1;
                START_PROCESSING <= 1'b0;
                DATA_RECEIPTION_COMPLETE_FLAG <= 1'b0;
            end
            /******************************************************************
             * When data bits are being transmitted, increase RAM address by 1
            ******************************************************************/
            else if (TRANSMITTED_8_BITS_FLAG && RAM_ADDRESS < RAM_BITS) begin
                RAM_ADDRESS <= RAM_ADDRESS + 16'd1;
                DATA_TO_TRANSMIT <= DATA_FROM_RAM;
                START_PROCESSING <= 1'b0;
                DATA_RECEIPTION_COMPLETE_FLAG <= 1'b0;
            end
        end

endmodule
/*
  Test Bench UART_BRIDGE
*/
module tBRIDGE;

    reg MAIN_CLOCK,RECEIVED_8_BITS_FLAG,TRANSMITTED_8_BITS_FLAG;
    reg [7:0] DATA_FROM_RAM;
    wire [7:0]DATA_TO_TRANSMIT;
    wire [15:0] RAM_ADDRESS;
    wire WRITE_TO_RAM, START_PROCESSING, DATA_RECEIPTION_COMPLETE_FLAG;

    // Clock
    initial begin
        MAIN_CLOCK = 1'b0;
        forever begin
            #1 MAIN_CLOCK = ~MAIN_CLOCK;
        end
    end
    
    UART_BRIDGE UUT (
        .MAIN_CLOCK(MAIN_CLOCK),
        .RECEIVED_8_BITS_FLAG(RECEIVED_8_BITS_FLAG),
        .TRANSMITTED_8_BITS_FLAG(TRANSMITTED_8_BITS_FLAG),
        .DATA_FROM_RAM(DATA_FROM_RAM),
        .DATA_RECEIPTION_COMPLETE_FLAG(DATA_RECEIPTION_COMPLETE_FLAG),
        .DATA_TO_TRANSMIT(DATA_TO_TRANSMIT),
        .START_PROCESSING(START_PROCESSING),
        .RAM_ADDRESS(RAM_ADDRESS),
        .WRITE_TO_RAM(WRITE_TO_RAM)
    );
    
    // Test
    initial begin
        #1 // Set data to input pins and set to first state
        RECEIVED_8_BITS_FLAG = 1'b1;
        TRANSMITTED_8_BITS_FLAG = 1'b0;
        DATA_FROM_RAM = 8'b1100_1010;
        #200 // Set data to input pins and set to first state
        RECEIVED_8_BITS_FLAG = 1'b1;
        TRANSMITTED_8_BITS_FLAG = 1'b0;
        DATA_FROM_RAM = 8'b0100_1100;
        #200 // Set data to input pins and set to first state
        RECEIVED_8_BITS_FLAG = 1'b0;
        TRANSMITTED_8_BITS_FLAG = 1'b1;
        DATA_FROM_RAM = 8'b0110_1100;
        #200 // Set data to input pins and set to first state
        RECEIVED_8_BITS_FLAG = 1'b1;
        TRANSMITTED_8_BITS_FLAG = 1'b1;
        DATA_FROM_RAM = 8'b0101_1100;
        #200 // Set data to input pins and set to first state
        RECEIVED_8_BITS_FLAG = 1'b0;
        TRANSMITTED_8_BITS_FLAG = 1'b1;
        DATA_FROM_RAM = 8'b0111_1100;
        #2 // Finish
        $finish;
    end

endmodule
