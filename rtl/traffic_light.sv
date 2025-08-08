/********************************************************************************* 
* Traffic light controller. It consists on a simple FSM with timing-based 
* events to transition between states
*********************************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none

/********************************************************************************* 
 * Packages
*********************************************************************************/

import traffic_light_package::*;

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module traffic_light #(
    parameter count_width_t NUM_CYCLES_RED = 10,
    parameter count_width_t NUM_CYCLES_YELLOW = 2,
    parameter count_width_t NUM_CYCLES_GREEN = 20
) (
    input  logic clk_i,
    input  logic rstn_i,
    output logic red_o,
    output logic yellow_o,
    output logic green_o,
    output logic bad_state_o
);

timeunit 1ns;
timeprecision 1ps;

/********************************************************************************* 
 * Module logic
*********************************************************************************/

    state_t state_next, state_reg;
    count_width_t count_cycles;
    logic count_is_last, red_count_is_last, yellow_count_is_last, green_count_is_last;

    // Update current state
    always_ff @(posedge clk_i) begin: update_state_reg
        if (!rstn_i) state_reg <= RED;
        else         state_reg <= state_next;
    end

    // Update next state
    always_comb begin : update_state_next
        state_next = state_reg;
        unique case (state_reg)
        RED     : if (red_count_is_last) state_next = GREEN;
        GREEN   : if (green_count_is_last) state_next = YELLOW;
        YELLOW  : if (yellow_count_is_last) state_next = RED;
        default : state_next = RED;
        endcase
    end

    // Handle timing and intermediary logic
    assign count_is_last = (count_cycles == 0) ? 1'b1 : 1'b0;
    assign red_count_is_last    = (count_is_last && state_reg == RED    ) ? 1'b1 : 1'b0;
    assign yellow_count_is_last = (count_is_last && state_reg == YELLOW ) ? 1'b1 : 1'b0;
    assign green_count_is_last  = (count_is_last && state_reg == GREEN  ) ? 1'b1 : 1'b0;
    always_ff @(posedge clk_i) begin: counter
        if (!rstn_i) count_cycles = NUM_CYCLES_RED;
        else if (red_count_is_last) count_cycles = NUM_CYCLES_RED;
        else if (yellow_count_is_last) count_cycles = NUM_CYCLES_GREEN;
        else if (green_count_is_last) count_cycles = NUM_CYCLES_YELLOW;
        else if (count_cycles > 0) count_cycles = count_cycles - 1;
    end

    // Handle outputs
    assign bad_state_o = (state_reg == RED || state_reg == YELLOW || state_reg == GREEN) ? 1'b0 : 1'b1;
    always_comb begin : set_outputs
        red_o = 0;
        green_o = 0;
        yellow_o = 0;
        unique case (state_reg)
        RED     : red_o = 1;
        GREEN   : green_o = 1;
        YELLOW  : yellow_o = 1;
        default : red_o = 1;
        endcase
    end

endmodule