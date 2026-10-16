module uart_top (
    input  logic       clk,
    input  logic       reset,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       tx_done,
    output logic       rx_done
);

    logic baud_tick;
    logic loopback_wire;

    baud_generator #(
        .master_clk(500000), // Reduced from 50MHz to 500kHz for super-fast simulation!
        .baud(9600)
    ) baud_gen_block (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    uart_tx tx_block (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_pin(loopback_wire),
        .tx_done(tx_done)
    );

    uart_rx rx_block (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .rx_pin(loopback_wire),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule