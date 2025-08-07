/*********************************************************************************
* Simple flip-flop tb
*********************************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
timeunit 1ns;
timeprecision 1ps;
`default_nettype none

`define VCD_PATH "ff_tb.vcd"
`define CLK_SEMIPERIOD 5 // 100MHz clock

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module ff_tb;

/********************************************************************************* 
 * Module logic
*********************************************************************************/

    // Parameters
    localparam DATA_WIDTH = 32;

    // TB signals
    logic clk, rstn;
    logic [DATA_WIDTH-1:0] data_i, data_o;

    // DUT instance
    ff # (
        .DATA_WIDTH(DATA_WIDTH)
    ) ff_inst (
        .clk_i(clk),
        .rstn_i(rstn),
        .data_i(data_i),
        .data_o(data_o)
    );

    // DUT stimulation

    initial begin
        clk <= 0;
        forever #(`CLK_SEMIPERIOD) clk = ~clk;
    end

    initial begin
        rstn <= 1;
        // 2 cycles before asserting reset
        repeat(2) @(posedge clk);
        rstn = 0;
        // reset asserted for 5 cycles and then deasserted (at negedge to avoid race conditions between initial and always blocks)
        repeat(5) @(posedge clk);
        @(negedge clk) rstn = 1;
    end

    initial begin

        $dumpfile(`VCD_PATH); $dumpvars;

        // Wait for reset operation to finish
        repeat (7) @(posedge clk);
        
        // Apply some values to dut input. Update stimulus and assert at falling (inactive) edge to avoid race conditions

        @(negedge clk);
        data_i = 32'hAAAA0000;
        // nothing to assert at this cycle

        @(negedge clk);
        assert (data_o == 32'hAAAA0000) else $error("data_o mismatch: expected 0xAAAA0000, got 0x%08x", data_o);
        data_i = 32'hAAAA0001;
        
        @(negedge clk);
        assert (data_o == 32'hAAAA0001) else $error("data_o mismatch: expected 0xAAAA0001, got 0x%08x", data_o);
        data_i = 32'hAAAA0002;

        @(negedge clk);
        assert (data_o == 32'hAAAA0002) else $error("data_o mismatch: expected 0xAAAA0002, got 0x%08x", data_o);

        $finish;
    end
 
endmodule
