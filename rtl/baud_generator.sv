module baud_generator #(
    parameter int master_clk = 50000000,
    parameter int baud       = 9600
)(
    input  logic clk,
    input  logic reset,
    output logic baud_tick
);

    logic [15:0] count;
    localparam int max_count = master_clk / (baud * 16);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_tick <= 1'b0;
            count     <= 16'd0;
        end else begin
            if (count == (max_count - 1)) begin
                baud_tick <= 1'b1;
                count     <= 16'd0;
            end else begin
                count     <= count + 1'b1;
                baud_tick <= 1'b0;
            end
        end
    end

endmodule