/**
 * @file frame_detector.sv
 * @author Geeoon Chung
 * @brief continously reads for a UART frame
 * @param CLOCK_SPEED       the speed of the clk signal in Hz
 * @param BAUD_RATE         the UART baud rate
 * @param DATA_BITS         the number of data bits in the frame
 * @param STOP_BITS         the number of stop bits in the frame
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           reset signal
 * @param[in] uart_rx       the current UART receive input
 * @param[out] valid        whether the \p val is valid
 * @param[out] data         the data read in
 */
module frame_detector #(
    parameter int CLOCK_SPEED,  // in Hz
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int STOP_BITS=1,
    
    localparam int CLOCKS_PER_SAMPLE=CLOCK_SPEED/BAUD_RATE,
    localparam int TOTAL_BITS=DATA_BITS+STOP_BITS  // not including start
)(
    input logic clk,
    input logic rst,
    input logic uart_rx,

    output logic valid,
    output logic [DATA_BITS-1:0] data
);
    // ASM
    enum logic { s_idle, s_bits } ps, ns;
    logic start, push;  // control signals
    logic [TOTAL_BITS:0] bit_buf;  // datapath
    always_comb begin
        valid = 0;
        start = 0;
        push = 0;
        case (ps)
            s_idle: begin
                if (start_detected) begin
                    start = 1;
                    ns = s_bits;
                end else begin
                    ns = s_idle;
                end
            end
            s_bits: begin
                if (bit_buf[0]) begin
                    valid = 1;
                    ns = s_idle;
                end else begin
                    push = bit_detected;
                    ns = s_bits;
                end
            end
        endcase
    end  // always_comb
    always_ff @(posedge clk) begin
        if (rst) begin
            ps <= s_idle;
        end else begin
            ps <= ns;
        end
        if (start) begin
            bit_buf <= { 1'b1, (TOTAL_BITS)'(0) };
        end
        if (push) begin
            bit_buf <= { uart_rx, bit_buf[TOTAL_BITS:1] };    
        end
    end  // always_ff
    assign data = bit_buf[TOTAL_BITS-1:1];

    // intermediate signals
    logic start_detected;
    logic bit_detected;
    // SUBMODULES
    start_detector #(
        .CLOCK_SPEED(CLOCK_SPEED),
        .BAUD_RATE(BAUD_RATE)
    ) start_detector_m (
        .clk,
        .val(uart_rx),
        .start(start_detected)
    );
    bit_detector #(
        .CLOCK_SPEED(CLOCK_SPEED),
        .BAUD_RATE(BAUD_RATE)
    ) bit_detector_m (
        .clk,
        .rst(push | start),
        .out(bit_detected)
    );
endmodule  // frame_detector
