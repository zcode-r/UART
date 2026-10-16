module uart_rx (
    input  logic       clk,
    input  logic       reset,
    input  logic       baud_tick,
    input  logic       rx_pin,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        END   = 2'b11
    } state_t;

    state_t cur_state, next_state;
    logic [3:0] tick_count;
    logic [2:0] bit_count;
    logic [7:0] rx_shift_reg;

    // PROCESS-1: COUNTER TRACKING
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cur_state    <= IDLE;
            tick_count   <= 4'd0;
            bit_count    <= 3'd0;
            rx_shift_reg <= 8'd0;
        end else begin
            cur_state <= next_state;

            if (baud_tick) begin
                unique case (cur_state)
                    IDLE: begin
                        tick_count <= 4'd0;
                        bit_count  <= 3'd0;
                    end

                    START: begin
                        if (tick_count == 4'd7) tick_count <= 4'd0;
                        else tick_count <= tick_count + 1'b1;
                    end

                    DATA: begin
                        if (tick_count == 4'd15) begin
                            tick_count   <= 4'd0;
                            rx_shift_reg <= {rx_pin, rx_shift_reg[7:1]};

                            if (bit_count == 3'd7) begin
                                bit_count <= 3'd0;
                            end else begin
                                bit_count <= bit_count + 1'b1;
                            end
                        end else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end

                    END: begin
                        if (tick_count == 4'd15) tick_count <= 4'd0;
                        else tick_count <= tick_count + 1'b1;
                    end
                endcase
            end
        end
    end

    // PROCESS-2: NEXT-STATE FSM LOGIC
    always_comb begin
        next_state = cur_state;

        unique case (cur_state)
            IDLE: begin
                if (!rx_pin) next_state = START;
            end

            START: begin
                if (baud_tick && (tick_count == 4'd7)) begin
                    next_state = DATA;
                end
            end

            DATA: begin
                if (baud_tick && (tick_count == 4'd15) && (bit_count == 3'd7)) begin
                    next_state = END;
                end
            end

            END: begin
                if (baud_tick && (tick_count == 4'd15)) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    // PROCESS-3: OUTPUT SIGNAL GENERATION
    always_comb begin
        rx_done = 1'b0;
        rx_data = rx_shift_reg;

        if (cur_state == END && baud_tick && (tick_count == 4'd15)) begin
            rx_done = 1'b1;
        end
    end

endmodule