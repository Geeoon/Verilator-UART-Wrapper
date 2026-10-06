/**
 * @file frame_transmitter.sv
 * @author Geeoon Chung
 * @brief continously reads for a UART frame
 * @param CLOCK_SPEED       the speed of the clk signal in Hz
 * @param BAUD_RATE         the UART baud rate
 * @param DATA_BITS         the number of data bits in the frame
 * @param STOP_BITS         the number of stop bits in the frame
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           reset signal
 * @param[in] send          an active HIGH send signal
 * @param[in] data          the data to transmit over UART
 * @param[out] ready        whether the transmitter is ready
 * @param[out] uart_tx      the UART transmit line
 */
module frame_transmitter #(
    parameter int CLOCK_SPEED,  // in Hz
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int STOP_BITS=1,
    
    localparam int CLOCKS_PER_SAMPLE=CLOCK_SPEED/BAUD_RATE,
    localparam int TOTAL_BITS=1+DATA_BITS+STOP_BITS  // including start bit
)(
    input logic clk,
    input logic rst,
    input logic send,
    input logic [DATA_BITS-1:0] data,

    output logic ready,
    output logic uart_tx
);
    logic [$clog2(TOTAL_BITS+1)-1:0] counter = '0;  // start in done state
    logic [TOTAL_BITS-1:0] buff = '1;
    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= '0;
            buff <= '1;
        end else if (send) begin
            counter <= ($clog2(TOTAL_BITS+1))'(TOTAL_BITS);
            buff <= { {(STOP_BITS){1'b1}}, data, 1'b0};  // stop bits, data, start bit
        end else if (counter != 0) begin
            if (timer_done) begin
                counter <= counter - 1;
                buff <= { 1'b1, buff[TOTAL_BITS-1:1] };
            end
        end
    end  // always_ff

    assign uart_tx = buff[0];
    assign ready = counter == 0;

    // intermediate signals
    logic timer_done;
    // SUBMODULES
    lfsr_timer #(
        .COUNT(CLOCKS_PER_SAMPLE-1)
    ) timer_m (
        .clk,
        .rst(timer_done | ready),
        .done(timer_done)
    );
endmodule  // frame_transmitter
