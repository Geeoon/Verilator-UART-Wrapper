# Verilator-UART-Wrapper
## Usage
Replace the `dut` in top level with your design.  Connect `uart_tx` with your DUT's receive line, and connect `uart_rx` with your DUT's transmit line.

Navigate to the `tests` directory.

Run `make uart/uart_sim` to start the compile and start.  The design will run forever until Ctrl+C.

Run `screen ./uart/pty/uart_wrapper`.  You now have a serial connection with your DUT.
