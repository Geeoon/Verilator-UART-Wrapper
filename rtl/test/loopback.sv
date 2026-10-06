/**
 * @brief UART loopback.  direclty connects RX to TX
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
module loopback #(
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
    assign tx = rx;
endmodule  // loopback
