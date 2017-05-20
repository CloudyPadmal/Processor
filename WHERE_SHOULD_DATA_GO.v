module WHERE_SHOULD_DATA_GO
(
    // Inputs
    input START_PROCESSING_FLAG, PROCESS_FINISHED_FLAG,
    input MAIN_CLOCK, CPU_CLOCK,
    input UART_WRITE_EN, CPU_WRITE_EN,
    input [15:0] UART_ADDRESS, CPU_ADDRESS,
    input [7:0] DATA_FROM_UART, CPU_DATA,
    // Outputs
    output reg START_TRANSMISSION = 1'b0,
    output reg RAM_CLOCK,
    output reg WRITE_TO_RAM,
    output reg [15:0] RAM_ADDRESS,
    output reg [7:0] RAM_DATA_BUS
);    
    localparam STORE_DATA_TO_MEMORY = 2'b00;
    localparam SEND_DATA_FROM_MEMORY = 2'b10;
    localparam PROCESS_DATA_IN_MEMORY = 2'b01;
    
    localparam YES = 1'b1;
    localparam NO = 1'b0;
    
    reg [1:0] COMMAND = 2'b11;
    
    always @ (*) begin
        if (~START_PROCESSING_FLAG && ~PROCESS_FINISHED_FLAG)
            COMMAND <= STORE_DATA_TO_MEMORY;
        if (START_PROCESSING_FLAG && ~PROCESS_FINISHED_FLAG)
            COMMAND <= PROCESS_DATA_IN_MEMORY;
        /*if (START_TRANSMISSION)*/
        if (START_PROCESSING_FLAG & PROCESS_FINISHED_FLAG)
            COMMAND <= SEND_DATA_FROM_MEMORY;
    end
    
    always @ (*)
        case(COMMAND)
            /******************************************************************
             * At every clock pulse, make RAM Address select position to save
             * incoming data bits from UART RX 8 line bus. RAM will have a WE
             * and RAM Data will be whatever coming from UART. RAM Clock will
             * be the main clock. @ each clock pulse a pixel will be saved in
             * the processor!
            ******************************************************************/
            STORE_DATA_TO_MEMORY:
                begin
                    START_TRANSMISSION <= NO;
                    RAM_CLOCK <= MAIN_CLOCK;
                    WRITE_TO_RAM <= UART_WRITE_EN;
                    RAM_ADDRESS <= UART_ADDRESS;
                    RAM_DATA_BUS <= DATA_FROM_UART;
                end

            /******************************************************************
             * Enable CPU to access and write data from and to RAM. RAM Clock
             * will be set by CPU internal clock to support accessing data in
             * relevant clock cycles (ie Downsampled clock pulses). Address to
             * RAM will be set by CPU and Data to RAM will be data coming from
             * CPU after being processed!
            ******************************************************************/
            PROCESS_DATA_IN_MEMORY:
                begin
                    START_TRANSMISSION <= NO;
                    RAM_CLOCK <= CPU_CLOCK;
                    WRITE_TO_RAM <= CPU_WRITE_EN;
                    RAM_ADDRESS <= CPU_ADDRESS;
                    RAM_DATA_BUS <= CPU_DATA;
                end

            /******************************************************************
             * At every clock pulse which is derived from the main clock, data
             * will be sent out via UART TX pin serially. RAM will have enable
             * to read only Data and whatever the data coming from RAM will be
             * sent out.
            ******************************************************************/
            SEND_DATA_FROM_MEMORY:
                begin
                    START_TRANSMISSION <= YES;
                    RAM_CLOCK <= MAIN_CLOCK;
                    WRITE_TO_RAM <= UART_WRITE_EN;
                    RAM_ADDRESS <= UART_ADDRESS;
                    RAM_DATA_BUS <= DATA_FROM_UART;
                end

        endcase
endmodule
