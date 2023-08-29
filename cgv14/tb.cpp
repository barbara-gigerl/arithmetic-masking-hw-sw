#include "Vcgv14.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include<cstdlib>

int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
    Vcgv14* top = new Vcgv14{contextp};

    top->rst_i = 1;
    top->clk_i = 0;

    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy
    tfp->open("dump.vcd");
    bool stop_now = false;

    srand((unsigned) time(NULL));

    //Generate arithmetic shares
    uint16_t A = rand() & 0xffff;
    uint16_t A0 = rand() & 0xffff;
    uint16_t A1 = A - A0;
    top->A0_i = A0;
    top->A1_i = A1;
    top->R0_i = rand() & 0xffff;
    top->R1_i = rand() & 0xffff;
    top->Rxy_i = rand() & 0xffff;
    top->Rxc_i = rand() & 0xffff;
    top->Ryc_i = rand() & 0xffff;

    while (!stop_now) { 
        contextp->timeInc(1);
        top->clk_i = !top->clk_i;

        if (!top->clk_i) {
            if (contextp->time() > 1 && contextp->time() < 10) {
                top->rst_i = 1;  
                
            } else {
                top->rst_i = 0;
            }

            if(contextp->time() > 11 && contextp->time() < 14) {
                top->start_i = 1;
            }
            else {
                top->start_i = 0;
            }
        }

        if (top->finish_o) {
            if((top->B0_o ^ top->B1_o) != A)
            {
                std::cout << "ERROR" << std::endl;
                exit(-1);
            }
            stop_now = true;
        }

        top->eval();
        tfp->dump(contextp->time());
        }
    tfp->close();
    delete top;
    delete contextp;
    return 0;
}