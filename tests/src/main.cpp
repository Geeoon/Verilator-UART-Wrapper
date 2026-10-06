#include "Vtop_level.h"
#include "verilated.h"
#include <iostream>

// in ns
#define CLOCK_PERIOD 100
int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vtop_level* top = new Vtop_level{contextp};
    
    top->clk = 0;
    // reset
    top->rst = 1;
    top->rx = 1;
    top->clk = !top->clk;
    top->eval();
    contextp->timeInc(CLOCK_PERIOD);
    top->rst = 0;
    
    while (!contextp->gotFinish()) {
        if ((contextp->time() % (CLOCK_PERIOD/2)) == 0) {
            top->clk = !top->clk;
        }
        top->eval();

        if ((contextp->time() % CLOCK_PERIOD) == (CLOCK_PERIOD/2)) { 
            // posedge
            std::cout << "rx: " << (int)top->tx << std::endl;
        }

        contextp->timeInc(1);
    }
    top->final();
    delete top;
    delete contextp;
    return 0;
}
