/**
 * @file bit_detector.sv
 * @author Geeoon Chung
 * @brief continuously reads the value at the midpoint for each symbol, basically a wraper for the timer
 * @param CLOCK_SPEED       the speed of the clk signal in Hz
 * @param BAUD_RATE         the UART baud rate
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           reset signal
 * @param[out] valid        whether the \p val is valid
 */
module bit_detector #(
    parameter int CLOCK_SPEED,  // in Hz
    parameter int BAUD_RATE=115200,
    
    localparam int CLOCKS_PER_SAMPLE=CLOCK_SPEED/BAUD_RATE
)(
    input logic clk,
    input logic rst,

    output logic out
);
    lfsr_timer #(
        .COUNT(CLOCKS_PER_SAMPLE-1)
    ) timer_m (
        .clk,
        .rst(rst | out),
        .done(out)
    );
endmodule  // bit_detector
