/********************************************************************************* 
 * Interface to model the SPI bus
*********************************************************************************/

interface spi_bus ();

    logic sclk;
    logic cs_n;
    logic mosi;

    modport slave (input sclk, input cs_n, input mosi);
    modport master (output sclk, output cs_n, output mosi);

endinterface
