###################################################################################
# Usage
###################################################################################

# See README.md

###################################################################################
# Imports
###################################################################################

# General
import logging
import os
import cocotb
import cocotb_test.simulator
from cocotb.log import SimLog
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.handle import Release, Force

###################################################################################
# TB class (common for all tests)
###################################################################################

class TB:

    def __init__(self, dut):
        self.dut = dut

        self.log = SimLog("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk_i, 10, units="ns").start())

    async def init(self):
        
        for _ in range(2): await RisingEdge(self.dut.clk_i)
        self.dut.rstn_i.value = 0
        for _ in range(5): await RisingEdge(self.dut.clk_i)
        self.dut.rstn_i.value = 1

###################################################################################
# Test: run_test 
# Stimulus: -
# Expected: -
###################################################################################

@cocotb.test()
async def run_test_counter(dut):

    # Initialize TB
    tb = TB(dut)
    await tb.init()
    
    # Test count up
    dut.en_i.value = 1
    dut.up_down_i.value = 1
    dut.load_en_i.value = 0
    dut.load_count_i.value = 0
    for _ in range(20): await RisingEdge(dut.clk_i)

    # Test count down
    dut.en_i.value = 1
    dut.up_down_i.value = 0
    for _ in range(20): await RisingEdge(dut.clk_i)

    # Test enable
    dut.en_i.value = 0
    for _ in range(4): await RisingEdge(dut.clk_i)
    dut.en_i.value = 1
    for _ in range(4): await RisingEdge(dut.clk_i)

    # Test load count
    dut.load_en_i.value = 1
    dut.load_count_i.value = 2
    for _ in range(4): await RisingEdge(dut.clk_i)
    dut.load_en_i.value = 0
    for _ in range(4): await RisingEdge(dut.clk_i)

###################################################################################
# cocotb-test flow (alternative to Makefile flow)
###################################################################################

tests_path = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_path, '..', '..', 'rtl'))

def test_counter(request):
    dut = "counter"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]
    
    parameters = {}
    parameters['WIDTH'] = 4
    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}
    
    plus_args = ["-t", "1ps"]
    # plus_args['-t'] = "1ps"

    sim_build = os.path.join(tests_path, "sim_build",
        request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_path],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
        plus_args=plus_args,
    )
