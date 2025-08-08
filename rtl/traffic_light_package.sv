`ifndef TRAFFIC_LIGHT_PACKAGE
`define TRAFFIC_LIGHT_PACKAGE

package traffic_light_package;

    typedef enum logic [2:0] {
        RED         = 3'b001,
        GREEN       = 3'b010,
        YELLOW      = 3'b100
    } state_t;

    typedef shortint count_width_t;

endpackage

`endif