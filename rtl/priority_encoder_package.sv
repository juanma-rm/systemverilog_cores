`ifndef PRIORITY_ENCODER_PACKAGE
`define PRIORITY_ENCODER_PACKAGE

package priority_encoder_package;

    // Note: enum would be better thatn defines, but iverilog is failing when using them within the generate if
    `define V1_WIDTH_8  0
    `define V2_GENERIC  1

endpackage

`endif