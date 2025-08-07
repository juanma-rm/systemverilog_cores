/********************************************************************
* Priority encoder tb
********************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none

`define VCD_PATH "priority_encoder_tb.vcd"
`define CLK_SEMIPERIOD 5 // 100MHz clock

/********************************************************************************* 
 * Packages
*********************************************************************************/

import priority_encoder_package::*;

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module priority_encoder_tb();

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
    localparam DATA_WIDTH = 8;

    // TB signals
    logic clk, rstn, valid_o; // clock and reset not used by this DUT
    logic [DATA_WIDTH-1:0] data_i;
    logic [$clog2(DATA_WIDTH)-1:0] data_o;
    int num_errors_found;

    // DUT instance
    priority_encoder # (
        .CORE_VERSION(`V2_GENERIC), // V1_WIDTH_8, V2_GENERIC
        .DATA_WIDTH(DATA_WIDTH)
    ) priority_encoder_inst (
        .data_i(data_i),
        .data_o(data_o),
        .valid_o(valid_o)
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
        
        data_i = 'b00001000;
        @(posedge clk);
        verify_assert("data_o for 00001000", 3, data_o, num_errors_found);
        verify_assert("valid_o for 00001000", 1, valid_o, num_errors_found);
        
        data_i = 'b11000001;
        @(posedge clk);
        verify_assert("data_o for 11000001", 7, data_o, num_errors_found);
        verify_assert("valid_o for 11000001", 1, valid_o, num_errors_found);

        data_i = 'b00000010;
        @(posedge clk);
        verify_assert("data_o for 00000010", 1, data_o, num_errors_found);
        verify_assert("valid_o for 00000010", 1, valid_o, num_errors_found);

        data_i = 'b00000000;
        @(posedge clk);
        verify_assert("valid_o for 00000000", 0, valid_o, num_errors_found);

        if (num_errors_found == 0)
            $display("\nTest finished successfully. All tests passed.\n");
        else
            $display("\nTest finished with errors. %0d errors found.\n", num_errors_found);

        $finish;
    end

endmodule