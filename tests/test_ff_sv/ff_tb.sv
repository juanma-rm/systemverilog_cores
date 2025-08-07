/*********************************************************************************
* Simple flip-flop tb
*********************************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none

`define VCD_PATH "ff_tb.vcd"
`define CLK_SEMIPERIOD 5 // 100MHz clock

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module ff_tb;

timeunit 1ns;
timeprecision 1ps;

/********************************************************************************* 
 * Auxiliar functions
*********************************************************************************/

task verify_assert(string msg, int expected, int actual, output int error_cnt);
    if (expected !== actual) begin
        $error("%s: Expected %0d, got %0d", msg, expected, actual);
        error_cnt++;
    end
endtask

/********************************************************************************* 
 * Module logic
*********************************************************************************/

    // Parameters
    localparam DATA_WIDTH = 32;

    // TB signals
    logic clk, rstn;
    logic [DATA_WIDTH-1:0] data_i, data_o;
    int num_errors_found;

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
        num_errors_found = 0;

        // Wait for reset operation to finish
        repeat (7) @(posedge clk);
        
        // Apply some values to dut input. Update stimulus and assert at falling (inactive) edge to avoid race conditions

        @(negedge clk);
        data_i = 32'hAAAA0000;
        // nothing to assert at this cycle

        @(negedge clk);
        verify_assert("data_o for 32'hAAAA0000", 32'hAAAA0000, data_o, num_errors_found);
        data_i = 32'hAAAA0001;
        
        @(negedge clk);
        verify_assert("data_o for 32'hAAAA0001", 32'hAAAA0001, data_o, num_errors_found);
        data_i = 32'hAAAA0002;

        @(negedge clk);
        verify_assert("data_o for 32'hAAAA0002", 32'hAAAA0002, data_o, num_errors_found);

        if (num_errors_found == 0)
            $display("\nTest finished successfully. All tests passed.\n");
        else
            $display("\nTest finished with errors. %0d errors found.\n", num_errors_found);

        $finish;
    end
 
endmodule
