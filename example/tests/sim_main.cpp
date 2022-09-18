#include "build/Vregister_testbench.h"
#include "verilated.h"

int main(int argc, char** argv, char** env) {

    Verilated::commandArgs(argc, argv);
    Vregister_testbench* top = new Vregister_testbench;
    int timer = 0;

    // Simulate until $finish()
    while (!Verilated::gotFinish()) {

        // Evaluate model;
        top->eval();
    }

    // Final model cleanup
    top->final();

    // Destroy model
    delete top;

    // Return good completion status
    return 0;
}
