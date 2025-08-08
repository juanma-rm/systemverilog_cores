/********************************************************************
* Priority encoder. Receives n-bit data and outputs the binary 
* representation of the highest bit that is set in the input data.
* Works asynchronously
********************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none

/********************************************************************************* 
 * Packages
*********************************************************************************/

import priority_encoder_package::*;

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module priority_encoder #(
    parameter CORE_VERSION = `V2_GENERIC,
    parameter DATA_WIDTH = 8
) (
    input  wire logic [DATA_WIDTH-1:0] data_i,
    output var  logic [$clog2(DATA_WIDTH)-1:0] data_o,
    output var  logic valid_o
);

timeunit 1ns;
timeprecision 1ps;

/********************************************************************************* 
 * Module logic
*********************************************************************************/

generate if (CORE_VERSION == `V1_WIDTH_8) begin : V1_WIDTH_8

    always_comb begin: update_output
        priority casex (data_i)
        8'b1xxxxxxx: begin data_o = 7; valid_o = 1'b1; end
        8'b01xxxxxx: begin data_o = 6; valid_o = 1'b1; end
        8'b001xxxxx: begin data_o = 5; valid_o = 1'b1; end
        8'b0001xxxx: begin data_o = 4; valid_o = 1'b1; end
        8'b00001xxx: begin data_o = 3; valid_o = 1'b1; end
        8'b000001xx: begin data_o = 2; valid_o = 1'b1; end
        8'b0000001x: begin data_o = 1; valid_o = 1'b1; end
        8'b00000001: begin data_o = 0; valid_o = 1'b1; end
        default    : begin data_o = 0; valid_o = 1'b0; end
        endcase
    end

end else if (CORE_VERSION == `V2_GENERIC) begin : V2_GENERIC

    always_comb begin: update_output
        // By default, no priority found
        data_o = 'x;
        valid_o = 1'b0;
        // Using incremental order for the index i is essential, since the last assignment will be the one remaining
        for (int i=0; i<DATA_WIDTH; i++) begin
            if (data_i[i] == 1'b1) begin
                data_o = i;
                valid_o = 1'b1;
            end
        end

        // Alternative code to start from highest values (could favour latency to highest bits); to be tested
        /*
        for (int i=DATA_WIDTH-1; i>=0; i--) begin
            if (data_i[i] == 1'b1 && !valid_o) begin
                data_o = i;
                valid_o = 1'b1;
            end
        end       
        */
    end

end else begin : UNKNOWN_CORE_VERSION

    initial begin
        $error("priority_encoder: Unknown CORE_VERSION parameter value (%0d). Supported values are V1_WIDTH_8 (%0d) and V2_GENERIC (%0d).", CORE_VERSION, `V1_WIDTH_8, `V2_GENERIC);
    end

end
endgenerate


endmodule