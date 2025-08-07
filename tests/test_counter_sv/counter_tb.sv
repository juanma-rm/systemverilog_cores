/********************************************************************************* 
 * counter_tb.sv
*********************************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
timeunit 1ns;
timeprecision 1ps;
`default_nettype none

`define VCD_PATH "counter_tb.vcd"
`define CLK_SEMIPERIOD 5 // 100MHz clock

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module counter_tb;

/********************************************************************************* 
 * Module logic
*********************************************************************************/

    // Parameters
    localparam WIDTH = 4;

    // TB signals
    logic clk;
    logic rstn;
    logic en;
    logic up_down;
    logic load_en;
    logic [WIDTH-1:0] load_count;
    logic [WIDTH-1:0] count;
    logic count_is_max_min;

    // DUT instance
    counter # (
        .WIDTH(WIDTH)
    ) counter_inst (
        .clk_i(clk),
        .rstn_i(rstn),
        .en_i(en),
        .up_down_i(up_down),
        .load_en_i(load_en),
        .load_count_i(load_count),
        .count_o(count),
        .count_is_max_min_o(count_is_max_min)
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

        // Test count up
        en = 1;
        up_down = 1;
        load_en = 0;
        load_count = 0;
        repeat (20) @(posedge clk);

        // Test count down
        en = 1;
        up_down = 0;
        repeat (20) @(posedge clk);

        // Test enable
        en = 0;
        repeat (4) @(posedge clk);
        en = 1;
        repeat (4) @(posedge clk);

        // Test load count
        load_en = 1;
        load_count = 2;
        repeat (4) @(posedge clk);
        load_en = 0;
        repeat (4) @(posedge clk);
        
        $finish;
    end

endmodule