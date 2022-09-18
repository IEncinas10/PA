# MIRI - Processor Architecture

## Testing framework
Testing will be done with [svut](https://github.com/dpretet/svut) framework.
- Create tests: *svutCreate* filename
- Run tests: *svutRun* [filename]

### Problems
  - If you have more than 1 module per Verilog/SystemVerilog file the output is very weird. You can manually fix it
  but its best to avoid this if possible.
  - The 'includes' at the top of the testbench dont take into account whole paths so you have to manually correct it
    if the modules and the test are not in the same directory
  
