`timescale 100 ps / 100 ps
module PROCESSOR (
    input MAIN_CLOCK, RESET, RX_PIN,
    output TX_PIN, ENABLE_PROCESS_START, ENABLE_DATA_TRANSMISSION,
    // Debug
    output [15:0] CURRENTADDRESS, REG_AC,
    output [7:0] BUS_TO_RAM, INSTRUCTIONADDRESS, CURRENTINSTRUCTION,
    output [7:0] OUTPUT_FROM_RAM,
    output WEN, TICKK, Z_Flag
);

    wire [7:0] DATA_FROM_RAM;
    wire RECEIVED_8_BITS, TRANSMITTED_8_BITS, PROCESS_FINISHED_FLAG, CPU_CLOCK;
    wire CPU_WRITE_EN, RAM_CLOCK, WRITE_TO_RAM, UART_WRITE_EN, START_PROCESSING, START_TRANSMISSION;
    wire [7:0] DATA_FROM_UART, CPU_DATA, RAM_DATA, INSTRUCTION_ADDRESS, INSTRUCTION_DATA, DATA_TO_TRANSMIT;
    wire [15:0] CPU_ADDRESS, RAM_ADDRESS, UART_ADDRESS;
    wire T;
    
    assign CURRENTADDRESS = RAM_ADDRESS; // Debug
    assign BUS_TO_RAM = RAM_DATA; // Debug
    assign INSTRUCTIONADDRESS = INSTRUCTION_ADDRESS; // Debug
    assign CURRENTINSTRUCTION = INSTRUCTION_DATA; // Debug
    assign WEN = WRITE_TO_RAM; // Debug
    assign OUTPUT_FROM_RAM = DATA_FROM_RAM; // Debug
    
    assign ENABLE_DATA_TRANSMISSION = START_TRANSMISSION;
    assign TICKK = PROCESS_FINISHED_FLAG;
    
    CPU Processor (
        .MAIN_CLOCK(MAIN_CLOCK),
        .START_PROCESSING_FLAG(START_PROCESSING),
        .PROCESS_FINISHED(PROCESS_FINISHED_FLAG),
        .DATA_FROM_RAM(DATA_FROM_RAM),
        .INSTRUCTION(INSTRUCTION_DATA),
        .CPU_CLOCK(CPU_CLOCK),
        .CPU_WRITE_EN(CPU_WRITE_EN),
        .CPU_ADDRESS(CPU_ADDRESS),
        .CPU_DATA(CPU_DATA),
        .REG_AC(REG_AC),
        .Z_Flag(Z_Flag),
        .INSTRUCTION_ADDRESS(INSTRUCTION_ADDRESS)
    );
    
    INSTRUCTION_ROM IROM (
        .clock(CPU_CLOCK),
        .address(INSTRUCTION_ADDRESS),
        .q(INSTRUCTION_DATA)
    );
    
    RAM MainMemory (
        .clock(RAM_CLOCK),
        .wren(WRITE_TO_RAM),
        .address(RAM_ADDRESS),
        .data(RAM_DATA),
        .q(DATA_FROM_RAM)
    );

    UART_MODULE Communicator (
        .MAIN_CLOCK(MAIN_CLOCK),
        .RESET(RESET),
        .RX_PIN(RX_PIN),
        .RECEIVED_BITS(DATA_FROM_UART),
        .RECEIVED_8_BITS_FLAG(RECEIVED_8_BITS),
        .START_TRANSMISSION(START_TRANSMISSION),
        .DATA_TO_TRANSMIT(DATA_TO_TRANSMIT),
        .TICKK(T),
        .TRANSMITTED_8_BITS_FLAG(TRANSMITTED_8_BITS),
        .TX_PIN(TX_PIN)
    );
    
    BRIDGE Bridge (
        .MAIN_CLOCK(MAIN_CLOCK),
        .RECEIVED_8_BITS_FLAG(RECEIVED_8_BITS),
        .TRANSMITTED_8_BITS_FLAG(TRANSMITTED_8_BITS),
        .DATA_RECEIPTION_COMPLETE_FLAG(ENABLE_PROCESS_START),
        .DATA_FROM_RAM(DATA_FROM_RAM),
        .DATA_TO_TRANSMIT(DATA_TO_TRANSMIT),
        .RAM_ADDRESS(UART_ADDRESS),
        .START_PROCESSING(START_PROCESSING),
        .WRITE_TO_RAM(UART_WRITE_EN)
    );
    
    WHERE_SHOULD_DATA_GO PathSelector (
        .START_PROCESSING_FLAG(START_PROCESSING),
        .PROCESS_FINISHED_FLAG(PROCESS_FINISHED_FLAG),
        .MAIN_CLOCK(MAIN_CLOCK),
        .CPU_CLOCK(CPU_CLOCK),
        .UART_WRITE_EN(UART_WRITE_EN),
        .CPU_WRITE_EN(CPU_WRITE_EN),
        .UART_ADDRESS(UART_ADDRESS),
        .CPU_ADDRESS(CPU_ADDRESS),
        .DATA_FROM_UART(DATA_FROM_UART),
        .CPU_DATA(CPU_DATA),
        .START_TRANSMISSION(START_TRANSMISSION),
        .RAM_CLOCK(RAM_CLOCK),
        .WRITE_TO_RAM(WRITE_TO_RAM),
        .RAM_ADDRESS(RAM_ADDRESS),
        .RAM_DATA_BUS(RAM_DATA)
    );
    
endmodule

module tPRO;
    
    reg MAIN_CLOCK, RESET, RX;
    wire TX, WEN, ENABLE_PROCESS_START, ENABLE_DATA_TRANSMISSION, TICKK, Z_Flag;
    wire [15:0] CURRENTADDRESS, REG_AC;
    wire [7:0] BUS_TO_RAM, INSTRUCTIONADDRESS, CURRENTINSTRUCTION, OUTPUT_FROM_RAM;
    
    localparam TIME = 1728;
    
    PROCESSOR UUT (
        .MAIN_CLOCK(MAIN_CLOCK),
        .RESET(RESET),
        .RX_PIN(RX),
        .TX_PIN(TX),
        .ENABLE_PROCESS_START(ENABLE_PROCESS_START), 
        .ENABLE_DATA_TRANSMISSION(ENABLE_DATA_TRANSMISSION),
        .CURRENTADDRESS(CURRENTADDRESS),
        .BUS_TO_RAM(BUS_TO_RAM),
        .REG_AC(REG_AC),
        .OUTPUT_FROM_RAM(OUTPUT_FROM_RAM),
        .INSTRUCTIONADDRESS(INSTRUCTIONADDRESS),
        .CURRENTINSTRUCTION(CURRENTINSTRUCTION),
        .TICKK(TICKK),
        .Z_Flag(Z_Flag),
        .WEN(WEN)
    );
    
    // Clock
    initial begin
        MAIN_CLOCK = 1'b0;
        forever begin
            #1 MAIN_CLOCK = ~MAIN_CLOCK;
        end
    end
    
    // Sending -> OK
    initial begin
        #1
        RESET = 1'b1;
        #1
        RESET = 1'b0;
        RX = 1'b0;
        forever begin
            
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b0;
            #(TIME)
            RX = 1'b0;
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b0;
            #(TIME)
            RX = 1'b1;
            
            #(TIME)
            RX = 1'b0;
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b0;
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b0;
            #(TIME)
            RX = 1'b0;
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b0;
            #(TIME)
            RX = 1'b1;
            #(TIME)
            RX = 1'b0;
        end
    end
    
    
    // Test
    initial begin
        #1
        RESET = 1'b1;
        #1
        RESET = 1'b0;
        #650000       
        $finish;
    end
    
endmodule
