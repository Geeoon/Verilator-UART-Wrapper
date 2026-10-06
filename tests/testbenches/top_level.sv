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

    localparam int OVERSAMPLING=8
) (
    input logic clk,
    input logic rst,
    input logic rx,

    output logic tx
);
    loopback #(
        .CLOCK_SPEED(BAUD_RATE*OVERSAMPLING),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS),
        .RX_FIFO_SIZE(RX_FIFO_SIZE),
        .TX_FIFO_SIZE(TX_FIFO_SIZE)
    ) dut (
        .clk,
        .rst,
        .rx,
        .tx
    );
    
    initial begin
        forever @(posedge clk);
        $finish;
        // forever @(posedge clk);
    end  // initial

endmodule  // top_level
