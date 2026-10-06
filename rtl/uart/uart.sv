/**
 * @file uart.sv
 * @author Geeoon Chung
 * @brief a UART module that performs receiving and transmitting
 * @note it is the responsibility of the user to check if the transmit FIFO is full before writing
 * @note it is the responsibility of the user to check if the receive FIFO is empty before writing
 * @param CLOCK_SPEED       the speed of the clk signal in Hz
 * @param BAUD_RATE         the UART baud rate
 * @param DATA_BITS         the defined number of data bits per UART frame
 * @param STOP_BITS         the number of stop bits in each UART frame
 * @param RX_FIFO_SIZE      the size of the receive FIFO in words, must be a power of 2
 * @param TX_FIFO_SIZE      the size of the transmit FIFO in words, must be a power of 2
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           reset signal
 * @param[in] read          active HIGH signal to pull and element from the RX FIFO
 * @param[in] write         active HIGH signal to add an element to the TX FIFO
 * @param[in] tx_data       the data to transmit
 * @param[in] uart_rx       the UART receive line
 * @param[out] uart_tx      the UART transmit line
 * @param[out] rx_data      the data received
 * @param[out] empty        whether the receive FIFO is empty
 * @param[out] full         whether the transmit FIFO is full
 */
module uart #(
    parameter int CLOCK_SPEED,  // in Hz
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int STOP_BITS=1,
    parameter int RX_FIFO_SIZE=8,
    parameter int TX_FIFO_SIZE=8
)(
    input logic clk,
    input logic rst,
    input logic read,
    input logic write,
    input logic [DATA_BITS-1:0] tx_data,
    input logic uart_rx,

    output logic uart_tx,
    output logic [DATA_BITS-1:0] rx_data,
    output logic empty,
    output logic full
);
    // SUBMODULES
    uart_tx_fifo #(
        .CLOCK_SPEED(CLOCK_SPEED),  // in Hz
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .FIFO_SIZE(TX_FIFO_SIZE),
        .STOP_BITS(STOP_BITS)
    ) uart_tx_m (
        .clk,
        .rst,
        .write,
        .data(tx_data),

        .uart_tx,
        .full
    );

    uart_rx_fifo #(
        .CLOCK_SPEED(CLOCK_SPEED),  // in Hz
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .FIFO_SIZE(RX_FIFO_SIZE)
    ) uart_rx_m (
        .clk,
        .rst,
        .read,
        .uart_rx,

        .empty,
        .out(rx_data)
    );
endmodule  // uart
