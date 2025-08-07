/********************************************************************************* 
 * This module implements a synchronous counter with the following features:
 * - Parameterizable width
 * - Synchronous reset
 * - Enable input
 * - Up and down counting
 * - Loadable value, enabled by a control signal
 * - Indicator for count having reached maximum or minimum value
*********************************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module counter #(
    parameter WIDTH = 32
) (
    input  logic clk_i,
    input  logic rstn_i,
    input  logic en_i, // enable count update; ignored if load_en_i = 1
    input  logic up_down_i, // 1 to count up, 0 to count down
    input  logic load_en_i, // loads the value at load_count_i in the count
    input  logic unsigned [WIDTH-1:0] load_count_i, // value to load
    output logic unsigned [WIDTH-1:0] count_o,
    output logic count_is_max_min_o // 1 if count is at max or min value
);

timeunit 1ns;
timeprecision 1ps;

/********************************************************************************* 
 * Module logic
*********************************************************************************/

    logic unsigned [WIDTH-1:0] count;

    always_ff @(posedge clk_i) begin: update_count
        if (!rstn_i)
            count <= 0;
        else if (load_en_i)
            count <= load_count_i;
        else if (en_i)
            if (up_down_i) count <= count + 1;
            else count <= count - 1;
    end

    always_comb count_o = count;
    always_comb count_is_max_min_o = (up_down_i && count == '1) || (!up_down_i && count == 0);

endmodule;