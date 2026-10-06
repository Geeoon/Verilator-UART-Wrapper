/**
 * @file uart_tx_fifo.sv
 * @author Geeoon Chung
 * @brief a FIFO that fills up as new UART bytes are received
 * @note it is the responsibility of the user to check if the FIFO is full before writing
 * @param CLOCK_SPEED       the speed of the clk signal in Hz
 * @param BAUD_RATE         the UART baud rate
 * @param DATA_BITS         the defined number of data bits per UART frame
 * @param FIFO_SIZE         the size of the FIFO in words, must be a power of 2
 * @param STOP_BITS         the number of stop bits per UART frame
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           reset signal
 * @param[in] write         active HIGH signal to add a new element to the FIFO
 * @param[in] data          the data to add to the FIFO
 * @param[out] uart_tx      the UART transmit line
 * @param[out] full         whether the FIFO is full
 */
module uart_tx_fifo #(
    parameter int CLOCK_SPEED,  // in Hz
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int FIFO_SIZE=8,
    parameter int STOP_BITS=1,
    
    localparam int CLOCKS_PER_SAMPLE=CLOCK_SPEED/BAUD_RATE
)(
    input logic clk,
    input logic rst,
    input logic write,
    input logic [DATA_BITS-1:0] data,
    
    output logic uart_tx,
    output logic full
);
    // intermediate signals
    logic tx_ready;
    logic [DATA_BITS-1:0] to_send;
    
    // FIFO
    logic [DATA_BITS-1:0] fifo_memory [0:FIFO_SIZE-1];
    logic empty;
    logic read;
    logic [$clog2(FIFO_SIZE)-1:0] rd_ptr, wr_ptr;
    always_ff @(posedge clk) begin
        if (rst) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
            full <= 0;
            empty <= 1;
        end else begin
            if (read & write) begin
                rd_ptr <= rd_ptr + ($clog2(FIFO_SIZE))'(1);
                wr_ptr <= wr_ptr + ($clog2(FIFO_SIZE))'(1);
                fifo_memory[wr_ptr] <= data;
            end else if (read) begin
                rd_ptr <= rd_ptr + ($clog2(FIFO_SIZE))'(1);
                full <= 0;
                if ((rd_ptr+($clog2(FIFO_SIZE))'(1)) == wr_ptr) begin
                    empty <= 1;
                end
            end else if (write) begin
                // no bounds checking
                fifo_memory[wr_ptr] <= data;
                wr_ptr <= wr_ptr + ($clog2(FIFO_SIZE))'(1);
                empty <= 0;
                if (rd_ptr == (wr_ptr+($clog2(FIFO_SIZE))'(1))) begin
                    full <= 1;
                end
            end
        end
    end  // always_ff
    
    assign to_send = fifo_memory[rd_ptr];
    assign read = tx_ready & ~empty;
    // SUBMODULES
    frame_transmitter #(
        .CLOCK_SPEED(CLOCK_SPEED),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS)
    ) transmitter_m (
        .clk,
        .rst,
        .send(read),
        .data(to_send),

        .ready(tx_ready),
        .uart_tx
    );
endmodule  // uart_tx_fifo
