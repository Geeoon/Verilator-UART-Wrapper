/**
 * @file top_level.sv
 * @author Geeoon Chung
 * @brief testbench for the uart module
 */

module top_level #(
    parameter int CLOCK_PERIOD=100,
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int RX_FIFO_SIZE=8,
    parameter int TX_FIFO_SIZE=8,
    parameter int STOP_BITS=1,

    localparam int OVERSAMPLING=6
) ();
    // inputs
    logic clk;
    logic rst;
    logic read;
    logic write;
    logic [DATA_BITS-1:0] tx_data;
    logic uart_rx;

    // outputs
    logic uart_tx;
    logic [DATA_BITS-1:0] rx_data;
    logic empty;
    logic full;

    uart #(
        .CLOCK_SPEED(BAUD_RATE*OVERSAMPLING),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS),
        .RX_FIFO_SIZE(RX_FIFO_SIZE),
        .TX_FIFO_SIZE(TX_FIFO_SIZE)
    ) dut (
        .clk,
        .rst,
        .read,
        .write,
        .tx_data,
        .uart_rx,
    
        .uart_tx,
        .rx_data,
        .empty,
        .full
    );
    
    int cycle = 0;
    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    assign uart_rx = uart_tx;  // loopback

    bit [DATA_BITS-1:0] random_bits [0:RX_FIFO_SIZE-1];
    initial begin
        rst = 1;
        read = 0;
        write = 0;
        tx_data = '0;
        @(posedge clk); #5;
        rst = 0;

        $display(" -- Testing Idle State -- ");
        repeat(100) begin
            assert(empty);
            assert(~full);
            assert(uart_tx);
            @(posedge clk); #5;
        end

        $display(" -- Testing UART Loopback -- ");
        repeat(100) begin
            // generate random frames
            for (int i = 0; i < RX_FIFO_SIZE; i++) begin
                random_bits[i] = (DATA_BITS)'($urandom());
            end
            // send random data
            write = 1;
            for (int i = 0; i < RX_FIFO_SIZE; i++) begin
                tx_data = random_bits[i];
                @(posedge clk); #5;
            end
            write = 0;

            // wait to receieve all frames
            repeat((1+DATA_BITS+STOP_BITS)*OVERSAMPLING*(RX_FIFO_SIZE)) begin
                @(posedge clk); #5;
            end

            // receive data
            read = 1;
            for (int i = 0; i < RX_FIFO_SIZE; i++) begin
                assert(random_bits[i] == rx_data);
                @(posedge clk); #5;
            end
            read = 0;
            assert(empty);
            assert(~full);
            assert(uart_tx);
        end

        $finish;
    end  // initial

endmodule  // top_level
