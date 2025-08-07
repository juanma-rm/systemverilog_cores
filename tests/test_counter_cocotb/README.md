Alternative 1 (make flow)
    - Configure "Makefile" file to set up the general test configuration
    - Run "make" from terminal
    - Run "make wave" to load the waveform with gtkwave
    - Run "make clean" to clean generated files

Alternative 2 (cocotb-test flow)
    - Configure "test_*" function located at the py file to configure the general test configuration
    - Run "SIM=questa pytest -o log_cli=True" from terminal. Adapt SIM variable or any other required variables as convenient.
    - Run "cocotb-clean -r" to clean generated files