interface uart_if(input logic clk);
    logic       reset;
    logic       tx_start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       rx_done;
    logic       tx_done;
endinterface

module uart_system_tb;

    logic clk = 0;
    always #10 clk = ~clk;

    uart_if vif(clk);

    uart_top uut (
        .clk      (vif.clk),
        .reset    (vif.reset),
        .tx_start (vif.tx_start),
        .tx_data  (vif.tx_data),
        .rx_data  (vif.rx_data),
        .rx_done  (vif.rx_done),
        .tx_done  (vif.tx_done)
    );

initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, uart_system_tb);

        reset_dut();
        
        send_data(8'h5A);
        wait_and_check(8'h5A);

        @(posedge vif.tx_done); 
        repeat(2) @(posedge clk); 

        send_data(8'hA5);
        wait_and_check(8'hA5);

        #1000;
        $finish;
    end

    // =========================================================
    // VERIFICATION TASKS (Your reusable building blocks)
    // =========================================================

    task reset_dut();
        vif.reset    <= 1'b1; 
        vif.tx_start <= 1'b0;
        vif.tx_data  <= '0;
        repeat(5) @(posedge clk); 
        vif.reset    <= 1'b0;
        repeat(5) @(posedge clk);
    endtask

    
    task send_data(input logic [7:0] data);
        $display("[TB] Transmitting: 0x%h", data);
        
        @(posedge clk);          
        vif.tx_data  <= data;   
        vif.tx_start <= 1'b1;    
        
        @(posedge clk);         
        vif.tx_start <= 1'b0;    
    endtask

    task wait_and_check(input logic [7:0] expected_data);
        @(posedge vif.rx_done);
        #100;

        if(vif.rx_data == expected_data) begin
            $display("[SUCCESS] Matches! Expected: 0x%h, Received: 0x%h\n", expected_data, vif.rx_data);
        end 
        else begin
            $display("[ERROR] Mismatch! Expected: 0x%h, Received: 0x%h\n", expected_data, vif.rx_data);
        end
    endtask

endmodule
