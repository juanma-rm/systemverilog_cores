DUT = counter
SRC = ../../rtl/$(DUT).sv

all: wave

build: 
	iverilog -g2012 -o my_sim.vvp $(SRC) $(DUT)_tb.sv

run: build
	vvp my_sim.vvp

wave: run
	gtkwave $(DUT)_tb.vcd

clean:
	rm -f my_sim.vvp $(DUT)_tb.vcd