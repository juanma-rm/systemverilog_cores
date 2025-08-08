/********************************************************************
* Priority encoder (Verilog wrapper for integration in Vivado bd).
********************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none
`timescale 1ns/1ps

/********************************************************************************* 
 * Auxiliar functions
*********************************************************************************/

function integer clog2;
    input [31:0] value;
    begin
        value = value - 1;
        for (clog2 = 0; value > 0; clog2 = clog2 + 1) begin
        value = value >> 1;
        end
    end
endfunction

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module priority_encoder_wrapper #(
    parameter CORE_VERSION = 0,
    parameter DATA_WIDTH = 8
) (
    input  wire clk_i,
    input  wire rstn_i,
    input  wire [DATA_WIDTH-1:0] data_i,
    output reg  [$clog2(DATA_WIDTH)-1:0] data_o_reg,
    output reg  valid_o_reg
);

/********************************************************************************* 
 * Module logic
*********************************************************************************/

    reg [DATA_WIDTH-1:0] data_i_reg;
    wire [$clog2(DATA_WIDTH)-1:0] data_o;
    wire valid_o;

    priority_encoder # (
        .CORE_VERSION(CORE_VERSION),
        .DATA_WIDTH(DATA_WIDTH)
    ) priority_encoder_inst (
        .data_i(data_i_reg),
        .data_o(data_o),
        .valid_o(valid_o)
    );

    always @(posedge clk_i) begin
        if (!rstn_i) begin
            data_i_reg <= 0;
            data_o_reg <= 0;
            valid_o_reg <= 0;
        end else begin
            data_i_reg <= data_i;
            data_o_reg <= data_o;
            valid_o_reg <= valid_o;            
        end
    end

endmodule