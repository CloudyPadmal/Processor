module UART_MODULE
(
    input MAIN_CLOCK, RESET,
    input START_TRANSMISSION, RX_PIN, 
    input [7:0] DATA_TO_TRANSMIT,
    
    output TRANSMITTED_8_BITS_FLAG, RECEIVED_8_BITS_FLAG,
    output TX_PIN, TICKK,
    output [7:0] RECEIVED_BITS   
);

    wire TICK;
    assign TICKK = TICK;

    TRANSMITTER TX_UNIT (
        MAIN_CLOCK, RESET, START_TRANSMISSION, TICK, DATA_TO_TRANSMIT, TRANSMITTED_8_BITS_FLAG, TX_PIN
    );
    
    RECEIVER RX_UNIT (
        MAIN_CLOCK, RESET, RX_PIN, TICK, RECEIVED_8_BITS_FLAG, RECEIVED_BITS
    );
    
    BAUD_GENERATOR BAUD_UNIT (
        MAIN_CLOCK, RESET, TICK
    );
    
endmodule

module tUART;
    
    reg MAIN_CLOCK, RESET, START_TRANSMISSION;
    reg RX_PIN;
    reg [7:0] DATA_TO_TRANSMIT;
    wire RECEIVED_8_BITS_FLAG, TRANSMITTED_8_BITS_FLAG;
    wire TX_PIN, TICKK;
    wire [7:0] RECEIVED_BITS;
    
    // Initialize UART
    UART_MODULE UUT (
        .MAIN_CLOCK(MAIN_CLOCK),
        .RESET(RESET),
        .START_TRANSMISSION(START_TRANSMISSION),
        .RX_PIN(RX_PIN),
        .DATA_TO_TRANSMIT(DATA_TO_TRANSMIT),
        .TRANSMITTED_8_BITS_FLAG(TRANSMITTED_8_BITS_FLAG),
        .RECEIVED_8_BITS_FLAG(RECEIVED_8_BITS_FLAG),
        .TX_PIN(TX_PIN),
        .TICKK(TICKK),
        .RECEIVED_BITS(RECEIVED_BITS)
    );
    
    // Clock
    initial begin
        MAIN_CLOCK = 1'b0;
        forever begin
            #1 MAIN_CLOCK = ~MAIN_CLOCK;
        end
    end
    
    // Test
    // Sending -> 0_11110010_1 -> 'O''K'
    initial begin
        #1
        RESET = 1'b1;
        #1
        RESET = 1'b0;
        #1
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #256
        $finish;    
    end
    

endmodule

module TRANSMITTER #(parameter DBIT = 8, SB_TICK = 16)
(
    input wire MAIN_CLOCK,RESET,
    input wire START_TRANSMISSION, TICK,
    input wire [7:0] DATA_TO_TRANSMIT,
    output reg TRANSMITTED_8_BITS_FLAG,
    output wire TX_PIN
);
    localparam [1:0] IDLE_STATE = 2'b00;
    localparam [1:0] INITIAL_STATE = 2'b01;
    localparam [1:0] FETCHING_STATE = 2'b10;
    localparam [1:0] END_STATE = 2'b11;
    
    reg [1:0] CURRENT_STATE, NEXT_STATE;
    reg [3:0] SAMPLE_COUNTER, SAMPLE_ACCUMULATOR;
    reg [2:0] BITS_CACHED, NUMBER_OF_BITS_CACHING;
    reg [7:0] SENT_BIT, SENDING_BIT;
    reg BIT_AT_TX, BIT_TO_TX;
    
    always @ (posedge MAIN_CLOCK, posedge RESET)
        if (RESET)
            begin
                CURRENT_STATE <= IDLE_STATE;
                SAMPLE_COUNTER <= 4'd0;
                BITS_CACHED <= 3'd0;
                SENT_BIT <= 8'd0;
                BIT_AT_TX <= 1'b1;
            end
        else
            begin
                CURRENT_STATE <= NEXT_STATE;
                SAMPLE_COUNTER <= SAMPLE_ACCUMULATOR;
                BITS_CACHED <= NUMBER_OF_BITS_CACHING;
                SENT_BIT <= SENDING_BIT;
                BIT_AT_TX <= BIT_TO_TX;
            end
    
    always @ (*)
        begin
            NEXT_STATE = CURRENT_STATE;
            TRANSMITTED_8_BITS_FLAG = 1'b0;
            SAMPLE_ACCUMULATOR = SAMPLE_COUNTER;
            NUMBER_OF_BITS_CACHING = BITS_CACHED;
            SENDING_BIT = SENT_BIT;
            BIT_TO_TX = BIT_AT_TX;
                case(CURRENT_STATE)
                    IDLE_STATE:
                        begin
                            BIT_TO_TX = 1'b1;
                            if (START_TRANSMISSION)
                                begin
                                    NEXT_STATE = INITIAL_STATE;
                                    SAMPLE_ACCUMULATOR = 0;
                                    SENDING_BIT = DATA_TO_TRANSMIT;
                                end
                        end

                    INITIAL_STATE:
                        begin
                            BIT_TO_TX = 1'b0;
                            if (TICK)
                                if(SAMPLE_COUNTER == 15)
                                    begin
                                        NEXT_STATE = FETCHING_STATE;
                                        SAMPLE_ACCUMULATOR = 0;
                                        NUMBER_OF_BITS_CACHING = 0;
                                    end
                                else
                                    SAMPLE_ACCUMULATOR = SAMPLE_COUNTER + 4'd1;
                        end

                    FETCHING_STATE:
                        begin
                            BIT_TO_TX = SENT_BIT[0];
                            if(TICK)
                                if(SAMPLE_COUNTER == 15)
                                    begin
                                        SAMPLE_ACCUMULATOR = 0;
                                        SENDING_BIT = SENT_BIT >> 1;
                                        if (BITS_CACHED == (DBIT-1))
                                            NEXT_STATE = END_STATE;
                                        else
                                            NUMBER_OF_BITS_CACHING = BITS_CACHED + 3'd1;
                                    end
                                else
                                    SAMPLE_ACCUMULATOR = SAMPLE_COUNTER + 4'd1;
                        end

                    END_STATE:
                        begin
                            BIT_TO_TX = 1'b1;
                            if (TICK)
                                if (SAMPLE_COUNTER == (SB_TICK-1))
                                    begin
                                        NEXT_STATE = IDLE_STATE;
                                        TRANSMITTED_8_BITS_FLAG = 1'b1;
                                    end
                                else
                                    SAMPLE_ACCUMULATOR = SAMPLE_COUNTER + 4'd1;
                        end
                endcase
        end
    
    assign TX_PIN = BIT_AT_TX;
    
endmodule

module RECEIVER #(parameter DBIT = 8, SB_TICK = 16)
(
    input wire MAIN_CLOCK, RESET,
    input wire RX_PIN, TICK,
    output reg RECEIVED_8_BITS_FLAG,
    output wire [7:0] RECEIVED_BITS
);
    // 9600 8N1 - 9600 baud, 8 data bits, no parity, and 1 stop bit
    // O -> 01001111
    // Sending -> 0_11110010_1

    localparam [1:0] IDLE_STATE = 2'b00;
    localparam [1:0] INITIAL_STATE = 2'b01;
    localparam [1:0] FETCHING_STATE = 2'b10;
    localparam [1:0] END_STATE = 2'b11;
    
    reg [1:0] CURRENT_STATE, NEXT_STATE;
    reg [3:0] SAMPLE_COUNTER, SAMPLE_ACCUMULATOR;
    reg [2:0] NUMBER_OF_BITS_CACHED, NUMBER_OF_BITS_CACHING;
    reg [7:0] CACHE, BIT_COLLECTOR;
    
    always @(posedge MAIN_CLOCK, posedge RESET)
        if(RESET)
            begin
                CURRENT_STATE <= IDLE_STATE;
                SAMPLE_COUNTER <= 0;
                NUMBER_OF_BITS_CACHED<= 0;
                CACHE <= 0;
            end
        else
            begin
                CURRENT_STATE <= NEXT_STATE;
                SAMPLE_COUNTER <= SAMPLE_ACCUMULATOR;
                NUMBER_OF_BITS_CACHED <= NUMBER_OF_BITS_CACHING;
                CACHE <= BIT_COLLECTOR;
            end

    always @ (*)
        begin
            NEXT_STATE = CURRENT_STATE;
            RECEIVED_8_BITS_FLAG = 1'b0; // This'll RESET the done_tick in one cycle
            SAMPLE_ACCUMULATOR = SAMPLE_COUNTER;
            NUMBER_OF_BITS_CACHING = NUMBER_OF_BITS_CACHED;
            BIT_COLLECTOR = CACHE;
            
            case (CURRENT_STATE)
                /* When the line is idle, there will be 1 on the line
                When a bit stream starts, it will start with a 0.
                When a 0 is detected, (~0) => 1; make the next state
                the 'start' and sample bits to 0 */
                IDLE_STATE:
                    if (~RX_PIN)
                        begin
                            NEXT_STATE = INITIAL_STATE;
                            SAMPLE_ACCUMULATOR = 0;
                        end

                /* When start bit has arrived, sample the data stream
                with 8 samples (SAMPLE_COUNTER); and if the sample count is 8? 16
                then move on to the FETCHING_STATE fetching state.
                Note : This will happen when a TICK is asserted!! */
                INITIAL_STATE:
                    if (TICK)
                        if(SAMPLE_COUNTER == (SB_TICK-1)) // Was 7? Investigate
                            begin
                                NEXT_STATE = FETCHING_STATE;
                                SAMPLE_ACCUMULATOR = 0;
                                NUMBER_OF_BITS_CACHING = 0;
                            end
                        else
                            SAMPLE_ACCUMULATOR = SAMPLE_COUNTER + 1'b1;

                /* When data is being fetched, sample the stream with 
                16 bits per TICK. If the sample count is 16, append
                the received bit to the RXbit accumulator and check how 
                many bits have been appended so far. If that amount 
                (NUMBER_OF_BITS_CACHED) is 8, then change the next state to 'END_STATE';
                Otherwise increment data bit count by one and keep on
                sampling */ 
                FETCHING_STATE:
                    if (TICK)
                        if (SAMPLE_COUNTER == (SB_TICK - 1))
                            begin
                                SAMPLE_ACCUMULATOR = 0;
                                BIT_COLLECTOR = {RX_PIN, CACHE[7:1]};
                                if (NUMBER_OF_BITS_CACHED == (DBIT - 1))
                                    NEXT_STATE = END_STATE;
                                else
                                    NUMBER_OF_BITS_CACHING = NUMBER_OF_BITS_CACHED + 1'b1;
                            end
                        else
                            SAMPLE_ACCUMULATOR = SAMPLE_COUNTER + 1'b1;
                /* When the END_STATE state is asserted, sample the stream
                for 16 bits and when the count is full, put up the rx
                done flag and move the next state to 'IDLE_STATE'. Otherwise
                keep on sampling the stream */
                END_STATE:
                    if (TICK)
                        if (SAMPLE_COUNTER == (SB_TICK - 1))
                            begin
                                NEXT_STATE = IDLE_STATE;
                                RECEIVED_8_BITS_FLAG = 1'b1;
                            end
                        else
                            SAMPLE_ACCUMULATOR = SAMPLE_COUNTER + 1'b1;
            endcase
        end
    
    assign RECEIVED_BITS = CACHE;
    
endmodule

module BAUD_GENERATOR 
#(parameter N = 6, M = 54) // Test
//#(parameter N = 5, M = 27) // 50 MHz
//#(parameter N = 5, M = 27) //N = 9, M = 434 // N = 5, M = 27

// 50 MHz -> N = 5, M = 27
// 100 MHz -> N = 6, M = 54 ->> Current test benches are synced to this
// parameter N -> Number of bits in register
// parameter M -> Clock pulse count
// 115200 bps @ 50 MHz -> 434.027 pulses per second / 16

/*******************************************/
/* 1 BIT -> 16 TICKS */
/* 1 TICK -> 54 CLOCKS */
/* 1 BIT -> 864 x 2 CLOCKS */
/* 1 CLOCK -> 0.2 ns */

/* 
 There fore for 115200 bps,
1 BIT -> 8680 ns,
1 TICK -> 542.5 ns,
50 MHz -> 20 ns
M = 542.5 / 20 = 27

 There fore for 256000 bps,
1 BIT -> 3906.25 ns,
1 TICK -> 244.14 ns,
50 MHz -> 20 ns
M = 542.5 / 20 = 27
*/
/*******************************************/
(
    input MAIN_CLOCK, RESET,
    output TICK
);

    reg [N-1:0] ACCUMULATOR;
    wire [N-1:0] COUNTER;
    
    always @ (posedge MAIN_CLOCK, posedge RESET)
        if (RESET)
            ACCUMULATOR <= 0;
        else
            ACCUMULATOR <= COUNTER;
    
    assign COUNTER = (ACCUMULATOR == (M-1)) ? 1'b0 : ACCUMULATOR + 1'b1;
    assign TICK = (ACCUMULATOR == (M-1)) ? 1'b1 : 1'b0;
    
endmodule

module tBaudGen;

    reg MAIN_CLOCK, RESET;
    wire TICK;
    
    BAUD_GENERATOR UUT (
        MAIN_CLOCK, RESET, TICK
    );
    
    initial begin
        MAIN_CLOCK = 1'b0;
        RESET = 1'b0;
    end
    
    initial begin
        forever begin
            #1 MAIN_CLOCK = ~MAIN_CLOCK;
        end
    end
    
    initial begin
        #1
        RESET = 1'b1;
        #5
        RESET = 1'b0;
        #10000
        $finish;
    end

endmodule

module tReceiver;
    
    reg MAIN_CLOCK, RESET;
    reg RX_PIN;
    wire RECEIVED_8_BITS_FLAG, TICK;
    wire [7:0] RECEIVED_BITS;
    
    // Initialize RX
    RECEIVER uut(
        MAIN_CLOCK, RESET, RX_PIN, TICK, RECEIVED_8_BITS_FLAG, RECEIVED_BITS
    );
    
    // Initialize Baud Generator
    BAUD_GENERATOR vvt(
        MAIN_CLOCK, RESET, TICK
    );
    
    // Clock
    initial begin
        MAIN_CLOCK = 1'b0;
        forever begin
            #1 MAIN_CLOCK = ~MAIN_CLOCK;
        end
    end
    
    // Test
    // Sending -> 0_11110010_1 -> 'O''K'
    initial begin
        #1
        RESET = 1'b1;
        #1
        RESET = 1'b0;
        #1
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #128
        RX_PIN = 1'b0;
        #128
        RX_PIN = 1'b1;
        #256
        $finish;    
    end

endmodule