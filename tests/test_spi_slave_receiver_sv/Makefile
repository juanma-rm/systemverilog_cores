DUT = spi_slave_receiver
SRC = $(DUT)_tb.sv $(DUT).sv main.cpp
INC = ../../rtl

all: wave

build:
	verilator -Wall -Wno-fatal --cc --exe --build --trace --timing --Mdir obj_dir -I$(INC) --top-module $(DUT)_tb $(SRC)

run: build
	./obj_dir/Vspi_slave_receiver_tb

wave: run
	gtkwave $(DUT)_tb.vcd

clean:
	rm -f my_sim.vvp $(DUT)_tb.vcd
	rm -rf obj_dir