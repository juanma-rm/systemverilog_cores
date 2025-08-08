/********************************************************************
* Traffic light tb
********************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none

`define VCD_PATH "traffic_light_tb.vcd"
`define CLK_SEMIPERIOD 5 // 100MHz clock

/********************************************************************************* 
 * Packages
*********************************************************************************/

import traffic_light_package::*;

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module traffic_light_tb();

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
    localparam count_width_t NUM_CYCLES_RED = 5;
    localparam count_width_t NUM_CYCLES_YELLOW = 2;
    localparam count_width_t NUM_CYCLES_GREEN = 10;
    localparam count_width_t wait_cycles = 2 * (NUM_CYCLES_RED + NUM_CYCLES_GREEN + NUM_CYCLES_YELLOW);

    // TB signals
    logic clk, rstn, valid_o; // clock and reset not used by this DUT
    logic red_o, yellow_o, green_o, bad_state_o;
    int num_errors_found;

    // DUT instance
    traffic_light # (
        .NUM_CYCLES_RED(NUM_CYCLES_RED),
        .NUM_CYCLES_YELLOW(NUM_CYCLES_YELLOW),
        .NUM_CYCLES_GREEN(NUM_CYCLES_GREEN)
    ) traffic_light_inst (
        .clk_i(clk),
        .rstn_i(rstn),
        .red_o(red_o),
        .yellow_o(yellow_o),
        .green_o(green_o),
        .bad_state_o(bad_state_o)
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

        // Just wait for some time and visualize waveform as first tb approach
        repeat (wait_cycles) @(posedge clk);        

        if (num_errors_found == 0)
            $display("\nTest finished successfully. All tests passed.\n");
        else
            $display("\nTest finished with errors. %0d errors found.\n", num_errors_found);

        $finish;
    end

endmodule