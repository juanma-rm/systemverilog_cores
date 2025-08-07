# SystemVerilog Cores

This repository provides a collection of reusable SystemVerilog modules and cores for digital design projects. Each core is designed for easy integration and customization.

## Repository Structure

- `rtl/` — SystemVerilog core source files
- `tests/` — Testbenches and verification resources

## Tools Used
- **Icarus Verilog** — Simulation and compilation of SystemVerilog code
- **Verilator** — High-performance SystemVerilog simulator for cycle-accurate modeling
- **Vivado** — FPGA synthesis and implementation tool
- **Cocotb** — Python-based testbench framework for verification
- **Make** — Build automation and workflow management
- **GTKWave** — Waveform viewer for simulation results

Notes:
- Icarus Verilog used for the simpler modules.
- Verilator used for some SystemVerilog features unsupported by Icarus Verilog (e.g. interfaces).
- Vivado suite used for more advanced designs, to check synth/impl or to run on hardware (AMD KV260 board)
- Cocotb used to verify some of the modules

## Running Tests

To run a test for a specific core, navigate to `tests/test_<core>` and use the following commands:

- `make` — Runs the simulation and generates results
- `make build` — Compiles the testbench and core
- `make wave` — Opens the waveform viewer (GTKWave) for simulation visualization
