/********************************************************************************* 
 * SPI slave receiver working at Mode 3 (sampling at rising edge, mosi idling high)
*********************************************************************************/

/********************************************************************************* 
 * Compiler directives and macros
*********************************************************************************/

`resetall
`default_nettype none

/********************************************************************************* 
 * Module ports
*********************************************************************************/

module spi_slave_receiver #(
    parameter IDLE_VAL = 1'b1,
    parameter DATA_WIDTH = 8
) (
    spi_bus.slave spi_bus_0,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic data_valid // goes high for one clock cycle when a complete
                            // DATA_WIDTH bit has been successfully received
);

timeunit 1ns;
timeprecision 1ps;

/********************************************************************************* 
 * Module logic
*********************************************************************************/

    enum {IDLE, RECEIVE, DATA_OUT} state_reg, state_next;

    logic sclk = spi_bus_0.sclk;
    logic cs_n = spi_bus_0.cs_n;
    logic mosi = spi_bus_0.mosi;

    logic [DATA_WIDTH-1:0] data_temp;
    logic [$clog2(DATA_WIDTH)-1:0] data_count;
    logic byte_is_received = (data_count == DATA_WIDTH-1) ? 1'b1 : 1'b0;

    always_ff @(posedge sclk, posedge cs_n) begin : register_state
        if (cs_n) state_reg <= IDLE;
        else      state_reg <= state_next;
    end

    always_comb begin: set_next_state
        state_next = state_reg;
        unique case (state_reg)
            IDLE     : state_next = RECEIVE;
            RECEIVE  : if (byte_is_received) state_next = DATA_OUT;
            DATA_OUT : state_next = RECEIVE;
        endcase
    end

    always_ff @(posedge sclk) begin : update_count
        unique case (state_reg)
            IDLE     : data_count <= 0;
            RECEIVE  : data_count <= data_count + 1;
            DATA_OUT : data_count <= 0;
        endcase
    end

    always_ff @(posedge sclk) begin : update_data_temp
        data_temp <= {data_temp[DATA_WIDTH-2:0], mosi};
    end

    always_ff @(posedge sclk) begin: set_outputs
        data_out = 0;
        data_valid = 0;
        if (state_reg == RECEIVE && byte_is_received) begin
            data_out = data_temp;
            data_valid = 1;
        end
    end

endmodule
