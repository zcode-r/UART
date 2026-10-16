`timescale 1ns/1ps

module uart_tb;

    logic       clk;
    logic       reset;
    logic       tx_start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       tx_done;
    logic       rx_done;

    // Instantiate DUT
    uart_top dut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .tx_done(tx_done),
        .rx_done(rx_done)
    );

    // Clock Generation (50 MHz)
    always #10 clk = ~clk;

    // Task for driving and checking loopback transaction
    task automatic send_and_check(input [7:0] data_to_send);
        begin
            @(posedge clk);
            tx_data  = data_to_send;
            tx_start = 1'b1;

            @(posedge clk);
            tx_start = 1'b0;

            $display("[SIM] Transmitting Byte: 8'h%h (%0d)", data_to_send, data_to_send);

            // Wait for receiver to finish
            wait (rx_done == 1'b1);
            @(posedge clk);

            // Automatic Verification
            if (rx_data == data_to_send) begin
                $display(">>> [RESULT] SUCCESS! Sent: 8'h%h | Received: 8'h%h <<<", data_to_send, rx_data);
            end else begin
                $display(">>> [RESULT] ERROR! Sent: 8'h%h | Received: 8'h%h <<<", data_to_send, rx_data);
            end
            $display("---------------------------------------------------------");
        end
    endtask

    // Stimulus Execution
    initial begin
        clk      = 1'b0;
        reset    = 1'b1;
        tx_start = 1'b0;
        tx_data  = 8'h00;

        // Apply Reset
        #40;
        reset = 1'b0;
        #40;

        $display("\n================ STARTING UART LOOPBACK TEST ================");

        send_and_check(8'hA5);
        #500;

        send_and_check(8'h3C);
        #500;

        send_and_check(8'hFF);
        #500;

        $display("================ ALL TESTS COMPLETED ================\n");
        $finish;
    end

    // Waveform Dump Config
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, uart_tb);
    end

endmodule