/********************************************************************************* 
 * Simple flip-flop module
 * - Synchronous reset
 * - Registers input at rising edge clock
*********************************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module ff #(
    parameter DATA_WIDTH = 8
) (
    input  logic clk_i,
    input  logic rstn_i,
    input  logic [DATA_WIDTH-1:0] data_i,
    output logic [DATA_WIDTH-1:0] data_o
);

timeunit 1ns;
timeprecision 1ps;

/********************************************************************************* 
 * Module logic
*********************************************************************************/

    always_ff @(posedge clk_i) begin : ff_update
        if (!rstn_i) data_o <= 0;
        else data_o <= data_i;
    end

endmodule