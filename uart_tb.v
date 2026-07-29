module uart_system_tb;

  reg clk;
  reg reset;
  reg tx_start;
  reg [7:0] tx_data;

  wire [7:0] rx_data;
  wire rx_done;
  wire tx_done;

  uart_top uut (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .tx_done(tx_done)
  );

  initial clk = 0;
  always #10 clk = ~clk;

  initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, uart_system_tb);

    reset    = 1;
    tx_start = 0;
    tx_data  = 8'h00;

    #100;
    reset = 0;

    #200;

    tx_data = 8'h5A;

    $display("\n====================================");
    $display(" UART LOOPBACK TEST STARTED");
    $display(" Transmitting : 0x%h", tx_data);
    $display("====================================\n");

    tx_start = 1;
    #40;
    tx_start = 0;

    @(posedge rx_done);

    #100;

    if(rx_data == tx_data)
    begin
      $display("\n====================================");
      $display(" TEST PASSED");
      $display(" Expected : 0x%h", tx_data);
      $display(" Received : 0x%h", rx_data);
      $display("====================================\n");
    end
    else
    begin
      $display("\n====================================");
      $display(" TEST FAILED");
      $display(" Expected : 0x%h", tx_data);
      $display(" Received : 0x%h", rx_data);
      $display("====================================\n");
    end

    #1000;
    $finish;

  end

endmodule
