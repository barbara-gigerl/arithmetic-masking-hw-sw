#include <iostream>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vcgv14.h"
#include <cstdlib>


Vcgv14 *top;
VerilatedVcdC *tfp;

vluint64_t main_time = 0;


double sc_time_stamp()
{
    return main_time;
}

void tick()
{
    // Falling edge
    top->clk_i = 0;
    top->eval();

    // Rising edge
    top->clk_i = 1;
    top->eval();
    if (tfp)
        tfp->dump(20 * main_time);

    // Falling edge settle eval
    top->clk_i = 0;
    top->eval();
    if (tfp)
        tfp->dump(20 * main_time + 10);
    if (tfp)
        tfp->flush();
    main_time++;
}



int main(int argc, char **argv, char **env)
{

    top = new Vcgv14;
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    Verilated::debug(0);
    Verilated::traceEverOn(true);

    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("build/circuit.vcd");
    assert(tfp);


    top->rst_i = 1;
    top->clk_i = 0;
    // Reset
    while (main_time <= 5)
        tick();
    

    top->rst_i = 0;
    tick();
    tick();
    tick();
    top->start_i = 1;
    tick();
    top->start_i = 0;
    
    // Falling edge
    top->clk_i = 0;
    top->eval();
    // Rising edge
    top->clk_i = 1;
    top->eval();
    if (tfp)
        tfp->dump(20 * main_time);

    // Falling edge settle eval
    top->clk_i = 0;
    top->eval();
    if (tfp)
        tfp->dump(20 * main_time + 10);
    if (tfp)
        tfp->flush();
    main_time++;

    tick();
    tick();

    tick();
    tick();

    top->final();

    if (tfp)
        tfp->close();
}