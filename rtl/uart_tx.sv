module uart_tx (
    input  logic       clk,
    input  logic       reset,
    input  logic       baud_tick,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_pin,
    output logic       tx_done
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
    logic [7:0] tx_shift_reg;

    // PROCESS-1: COUNTER TRACKING
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cur_state    <= IDLE;
            tick_count   <= 4'd0;
            bit_count    <= 3'd0;
            tx_shift_reg <= 8'd0;
        end else begin
            cur_state <= next_state;

            if (cur_state == IDLE && tx_start) begin
                tx_shift_reg <= tx_data;
            end

            if (baud_tick) begin
                unique case (cur_state)
                    IDLE: begin
                        tick_count <= 4'd0;
                        bit_count  <= 3'd0;
                    end

                    START: begin
                        if (tick_count == 4'd15) tick_count <= 4'd0;
                        else tick_count <= tick_count + 1'b1;
                    end

                    DATA: begin
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            if (bit_count == 3'd7) begin
                                bit_count <= 3'd0;
                            end else begin
                                bit_count    <= bit_count + 1'b1;
                                tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};
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
                if (tx_start) next_state = START;
            end

            START: begin
                if (baud_tick && (tick_count == 4'd15)) begin
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
        tx_pin  = 1'b1;
        tx_done = 1'b0;

        unique case (cur_state)
            IDLE:  tx_pin = 1'b1;
            START: tx_pin = 1'b0;
            DATA:  tx_pin = tx_shift_reg[0];
            END: begin
                tx_pin  = 1'b1;
                tx_done = (baud_tick && (tick_count == 4'd15));
            end
        endcase
    end

endmodule