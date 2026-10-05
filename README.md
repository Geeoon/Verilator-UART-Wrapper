# Verilator-UART-Wrapper
The goal of this project is to allow serial terminals, like `screen` to interact with Verilator designs.

The general idea is this:
* Create a PTY(s) on Linux
* Have Verilator read from the PTY
  * Have on thread listening for PTY characters
  * Have another thread running the design
* Convert the PTY input into RX line signals
* Have the wrapper read the TX line from the module and send it to the PTY

Questions:
* Figure out how Verilator C/C++ wrapper works
  * How does it handle multiple threads
* Figure out how PTYs handle non-8-bit frames
