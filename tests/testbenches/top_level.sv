/**
 * @file top_level.sv
 * @author Geeoon Chung
 * @brief testbench for the uart module
 */

module top_level #(
    parameter int CLOCK_PERIOD=100,
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int RX_FIFO_SIZE=4,
    parameter int TX_FIFO_SIZE=4,
    parameter int STOP_BITS=1,

    localparam int OVERSAMPLING=8,
    localparam int CLOCK_SPEED=BAUD_RATE*OVERSAMPLING
) (
    input logic clk,
    input logic rst,
    input logic write,
    input logic [DATA_BITS-1:0] tx_frame,

    output logic [DATA_BITS-1:0] rx_frame,
    output logic valid
);
    // UART module that we interact with through the C++ wrapper
    logic uart_rx, uart_tx, empty, full;
    assign valid = ~empty;
    uart #(
        .CLOCK_SPEED(CLOCK_SPEED),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS),
        .RX_FIFO_SIZE(4096),
        .TX_FIFO_SIZE(4096)
    ) uart_wrapper_m (
        .clk,
        .rst,
        .read(0),
        .write,
        .tx_data(tx_frame),
        .uart_rx(1),

        .uart_tx,
        .rx_data(rx_frame),
        .empty,
        .full
    );

    loopback #(
        .CLOCK_SPEED(CLOCK_SPEED),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS),
        .RX_FIFO_SIZE(RX_FIFO_SIZE),
        .TX_FIFO_SIZE(TX_FIFO_SIZE)
    ) dut (
        .clk,
        .rst,
        .rx(uart_tx),
        .tx(uart_rx)
    );
    
    initial begin
        // forever begin
            $display("rst: ", rst);
            $display("empty: ", empty);
            $display("full: ", full);
            $display("write: ", write);
            $display("uart_tx: ", uart_tx);
            $display("uart_rx: ", uart_rx);
            @(posedge clk);
        // end
        $finish;
    end  // initial

endmodule  // top_level
