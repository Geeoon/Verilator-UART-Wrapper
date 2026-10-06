/**
 * @brief UART echo module
 * @author Geeoon Chung
 * @param CLOCK_SPEED   the clock frequency in Hz
 * @param BAUD_RATE     the UART baud rate
 * @param DATA_BITS     the number of UART data bits
 * @param RX_FIFO_SIZE  the size of the receive FIFO
 * @param TX_FIFO_SIZE  the size of the transmit FIFO
 * @param STOP_BITS     the number of UART stop bits
 * @param[in] clk       the clock driving the sequential logic
 * @param[in] rst       the active HIGH reset signal
 * @param[in] rx        the UART receive line
 * @param[out] tx       the UART transmit line
*/
module echo #(
    parameter int CLOCK_SPEED,
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int RX_FIFO_SIZE=4,
    parameter int TX_FIFO_SIZE=4,
    parameter int STOP_BITS=1
) (
    input logic clk,
    input logic rst,
    input logic rx,

    output logic tx
);
    logic rx_data;
    logic empty, full;
    uart #(
        .CLOCK_SPEED(CLOCK_SPEED),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .RX_FIFO_SIZE(RX_FIFO_SIZE),
        .TX_FIFO_SIZE(TX_FIFO_SIZE),
        .STOP_BITS(STOP_BITS)
    ) uart_m (
        .clk,
        .rst,
        .read(~empty),
        .write(~(empty | full)),
        .tx_data(rx_data),
        .uart_rx(rx),

        .uart_tx(tx),
        .rx_data,
        .empty,
        .full
    );
endmodule  // echo
