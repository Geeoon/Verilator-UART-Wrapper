#include "Vtop_level.h"
#include "verilated.h"
#include <iostream>
#include <queue>
#include <unistd.h>
#include <fcntl.h>

// in ns
#define CLOCK_PERIOD 100

class UartCtrl {
private:
    std::queue<unsigned char> uart_tx_fifo, uart_rx_fifo;
public:
    // constructor
    UartCtrl() {}
    /**
     * @brief adds a new frame to the TX FIFO
     * @param data the data to send
     */
    void transmit_frame(unsigned char data) {
        uart_tx_fifo.push(data);
    }
    /**
     * @brief checks if there's new UART data
     * @param data where the new data should be stored
     * @return 0 if there is no new frames, 1 if there is new data
     * @post \p data contains the new data if 1 is returned, otherwise it is unmodified
     */
    int receive_frame(unsigned char* data) {
        if (uart_rx_fifo.empty()) return 0;
        *data = uart_rx_fifo.front();
        uart_rx_fifo.pop();
        return 1;
    }
    /**
     * @brief should be called every posedge clk, handles all UART comms
     */
    void process_uart(bool& write, unsigned char& tx_frame, bool valid, unsigned char rx_frame) {
        if (valid) {
            uart_rx_fifo.push(rx_frame);
        }
        if (uart_tx_fifo.empty()) {
            write = 0;
            tx_frame = 0;
        } else {
            // hand the next frame to the hardware and consume it so it is only
            // written once. The frame is held on write/tx_frame for one clock
            // cycle, which is when the UART samples it.
            write = 1;
            tx_frame = uart_tx_fifo.front();
            uart_tx_fifo.pop();
        }
    }
};

int main(int argc, char** argv) {
    int uart_fd = open("./uart/pty/uart", O_RDWR | O_NOCTTY);
    if (uart_fd < 0) {
        std::cerr << "Failed to open UART PTY" << std::endl;
        return 1;
    }
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vtop_level* top = new Vtop_level{contextp};

    UartCtrl uart_controller;

    top->clk = 0;
    top->rst = 1;
    top->write = 0;
    top->tx_frame = 0;

    // advance the design by one clock cycle; when \p run_uart is set the
    // wrapper samples the design's outputs and drives its inputs on the posedge
    auto clock_cycle = [&](bool run_uart) {
        top->clk = 1;
        top->eval();
        contextp->timeInc(CLOCK_PERIOD / 2);

        if (run_uart) {
            bool write;
            unsigned char tx_frame;
            uart_controller.process_uart(write, tx_frame,
                                         static_cast<bool>(top->valid),
                                         static_cast<unsigned char>(top->rx_frame));
            top->write = write;
            top->tx_frame = tx_frame;

            unsigned char data;
            if (uart_controller.receive_frame(&data)) {
                std::cout << "Received 0x" << std::hex
                          << static_cast<int>(data) << std::dec << std::endl;
            }
        }

        top->clk = 0;
        top->eval();
        contextp->timeInc(CLOCK_PERIOD / 2);
    };

    // hold reset for a couple of cycles so the UART FIFOs start empty
    clock_cycle(false);
    clock_cycle(false);
    top->rst = 0;

    // start UART transmission thread

    while (!contextp->gotFinish()) {
        clock_cycle(true);
    }

    top->final();
    delete top;
    delete contextp;
    return 0;
}
