/********************************************************************************* 
 * spi_slave_receiver_tb.sv
*********************************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none

`define VCD_PATH "spi_slave_receiver_tb.vcd"

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module spi_slave_receiver_tb (
    input logic clk,
    input logic rst_n
);

timeunit 1ns;
timeprecision 1ps;

/********************************************************************************* 
 * Module logic
*********************************************************************************/

    // Parameters
    localparam IDLE_VAL = 1;
    localparam DATA_WIDTH = 8;

    // TB signals
    spi_bus spi_bus_0();
    assign spi_bus_0.sclk = clk;
    logic [DATA_WIDTH-1:0] data_from_spi_slave;
    logic data_from_spi_valid;

    // DUT instance
    spi_slave_receiver # (
        .IDLE_VAL(IDLE_VAL),
        .DATA_WIDTH(DATA_WIDTH)
    ) spi_slave_receiver_inst (
        .spi_bus_0(spi_bus_0.slave),
        .data_out(data_from_spi_slave),
        .data_valid(data_from_spi_valid)
    );    

    // DUT stimulation
    
    localparam NUM_WORDS = 4;
    logic [NUM_WORDS-1:0][DATA_WIDTH-1:0] data_to_spi_slave = '{8'hA5, 8'h3C, 8'h7E, 8'h12};

    initial begin

        $dumpfile(`VCD_PATH); $dumpvars;

        // Initial state: reset active
        spi_bus_0.cs_n = 1;
        repeat (5) @(posedge clk);

        // Send several words to the receiver
        spi_bus_0.cs_n = 0;
        for (int word_index = 0; word_index < NUM_WORDS; word_index++) begin
            for (int bit_index = DATA_WIDTH-1; bit_index >= 0; bit_index--) begin

                spi_bus_0.mosi = data_to_spi_slave[word_index][bit_index];
                @(posedge clk);

                // Test reset of dut when cs_n goes high. Only two first words (0x7e and 0x12) should be properly transmitted
                if (word_index == 2 && bit_index == 4) begin
                    spi_bus_0.cs_n = 1;
                end
            end
            @(posedge clk); // 1-cycle wait between words, to leave room for valid cycle
        end

        repeat (10) @(posedge clk); // extra time at the end to ease visual inspection
        $finish;
    end

endmodule
