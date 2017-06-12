`timescale 1 ns / 1 ns
module PROCESSOR (
    input MAIN_CLOCK,
    // Debug
    //output [15:0] CURRENTADDRESS, REG_AC, REG_1, REG_2,
    //output [7:0] INSTRUCTIONADDRESS, CURRENTINSTRUCTION, OUTPUT_FROM_RAM,
    //output [5:0] CMD,
    output PROCESS_DONE
);

    wire [7:0] DATA_FROM_RAM;
    wire RECEIVED_8_BITS, TRANSMITTED_8_BITS, PROCESS_FINISHED_FLAG, CPU_CLOCK;
    wire CPU_WRITE_EN, RAM_CLOCK, WRITE_TO_RAM, UART_WRITE_EN, START_PROCESSING, START_TRANSMISSION;
    wire [7:0] DATA_FROM_UART, CPU_DATA, RAM_DATA, INSTRUCTION_ADDRESS, INSTRUCTION_DATA, DATA_TO_TRANSMIT;
    wire [15:0] CPU_ADDRESS, RAM_ADDRESS, UART_ADDRESS;
    wire T;
    
    assign CURRENTADDRESS = CPU_ADDRESS; // Debug
    assign BUS_TO_RAM = RAM_DATA; // Debug
    assign INSTRUCTIONADDRESS = INSTRUCTION_ADDRESS; // Debug
    assign CURRENTINSTRUCTION = INSTRUCTION_DATA; // Debug
    assign WEN = CPU_WRITE_EN; // Debug
    assign OUTPUT_FROM_RAM = DATA_FROM_RAM; // Debug
    
    assign ENABLE_DATA_TRANSMISSION = START_TRANSMISSION;
    assign PROCESS_DONE = ~PROCESS_FINISHED_FLAG;
    
    CPU Processor (
        .MAIN_CLOCK(MAIN_CLOCK),
        .PROCESS_FINISHED(PROCESS_FINISHED_FLAG),
        .DATA_FROM_RAM(DATA_FROM_RAM),
        .INSTRUCTION(INSTRUCTION_DATA),
        .CPU_CLOCK(CPU_CLOCK),
        .CPU_WRITE_EN(CPU_WRITE_EN),
        .CPU_ADDRESS(CPU_ADDRESS),
        .CPU_DATA(CPU_DATA),
        .REG_AC(REG_AC),
        .REG_1(REG_1),
        .REG_2(REG_2),
        .CMD(CMD),
        .Z_Flag(Z_Flag),
        .INSTRUCTION_ADDRESS(INSTRUCTION_ADDRESS)
    );
    
    INSTRUCTION_ROM IROM (
        .clock(CPU_CLOCK),
        .address(INSTRUCTION_ADDRESS),
        .q(INSTRUCTION_DATA)
    );
    
    IMAGE_RAM ImageRam (
        .address(CPU_ADDRESS),
        .clock(CPU_CLOCK),
        .data(CPU_DATA),
        .wren(CPU_WRITE_EN),
        .q(DATA_FROM_RAM)
    );

endmodule

module tPRO;
    
    reg MAIN_CLOCK;
    wire PROCESS_DONE;
    wire [15:0] CURRENTADDRESS, REG_AC, REG_1, REG_2;
    wire [5:0] CMD;
    wire [7:0] INSTRUCTIONADDRESS, CURRENTINSTRUCTION, OUTPUT_FROM_RAM;
    
    PROCESSOR UUT (
        .MAIN_CLOCK(MAIN_CLOCK),
        //.CURRENTADDRESS(CURRENTADDRESS),
        //.REG_AC(REG_AC),
        //.REG_1(REG_1),
        //.REG_2(REG_2),
        //.OUTPUT_FROM_RAM(OUTPUT_FROM_RAM),
        //.INSTRUCTIONADDRESS(INSTRUCTIONADDRESS),
        //.CURRENTINSTRUCTION(CURRENTINSTRUCTION),
        //.CMD(CMD),
        .PROCESS_DONE(PROCESS_DONE)
    );
    
    // Clock
    initial begin
        MAIN_CLOCK = 1'b0;
        forever begin
            #1 MAIN_CLOCK = ~MAIN_CLOCK;
        end
    end
    
    // Test
    initial begin
        #800000000
        $finish;
    end
    
endmodule
