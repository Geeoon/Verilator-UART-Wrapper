/**
 * @file start_detector.sv
 * @author Geeoon Chung
 * @brief detects the start of a UART frame. it's basically a wrapper for a timer
 * @param CLOCK_SPEED       the speed of the clk signal in Hz
 * @param BAUD_RATE         the UART baud rate
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] val           the current UART RX line value
 * @param[out] start        HIGH when a start bit is detected
 */
module start_detector #(
    parameter int CLOCK_SPEED,  // in Hz
    parameter int BAUD_RATE=115200,
    
    localparam int CLOCKS_PER_SAMPLE=CLOCK_SPEED/(BAUD_RATE*2)
)(
    input logic clk,
    input logic val,

    output logic start
);
    // intermediate signals
    logic timer_done;
    // SUBMODULES
    lfsr_timer #(
        .COUNT(CLOCKS_PER_SAMPLE)
    ) timer_m (
        .clk,
        .rst(val),

        .done(timer_done)
    );
    assign start = timer_done & ~val;
endmodule  // start_detector
