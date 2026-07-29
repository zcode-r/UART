module uart_top(
  input clk,reset,tx_start,
  input [7:0] tx_data,
  output [7:0] rx_data,
  output tx_done,rx_done);
  
  wire baud_tick;
  wire loopback_wire;
  
  baud_generator #(
    .master_clk(500000),
    .baud(9600)
  ) baud_gen_block (
    .clk(clk),
    .reset(reset),
    .baud_tick(baud_tick)
  );
  
  uart_tx tx_block(
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


//////////////BAUD GENERATOR//////////////
module baud_generator #(parameter master_clk=50000000,baud=9600)(input clk,reset,output reg baud_tick);
  
  reg [15:0] count;
  
  localparam integer max_count=master_clk/(baud*16);
  
  always@(posedge clk or posedge reset) begin
    if(reset) begin
      baud_tick<=0;
      count<=0;
    end
    else begin
      if(count==(max_count-1)) begin
        baud_tick<=1;
        count<=0;
      end
      else begin
        count<=count+1;
        baud_tick<=0;
      end
    end
  end
  
endmodule

///////////////////////////////////////////////////////
//UART_TX//
///////////////////////////////////////////////////////

module uart_tx(
  input clk,reset,baud_tick,tx_start,
  input [7:0] tx_data,
  output reg tx_pin,tx_done);
  
  localparam IDLE=2'b00;
  localparam START=2'b01;
  localparam DATA=2'b10;
  localparam END=2'b11;
  
  reg [1:0] cur_state,next_state;
  reg [3:0] tick_count;
  reg [2:0] bit_count;
  reg [7:0] tx_shift_reg;
  
  //////////////PROCESS-1 COUNTER TRACKING//////////////
  
  always@(posedge clk or posedge reset) begin
    if(reset) begin
      cur_state<=IDLE;
      tick_count<=0;
      bit_count<=0;
      tx_shift_reg<=0;
    end
    else begin
      cur_state<=next_state;
      
      if(cur_state==IDLE && tx_start) begin
    		tx_shift_reg <= tx_data;
      end
    
      if(baud_tick) begin
        case(cur_state)
          
          IDLE: begin
            tick_count<=0;
            bit_count<=0;
          end
          
          START: begin
            if(tick_count==4'd15) tick_count<=0;
            else tick_count<=tick_count+1;
          end
          
          DATA: begin
            if(tick_count==4'd15) begin 
              tick_count<=0;
              if(bit_count==3'd7) begin
                bit_count<=0;
              end
              else begin
                bit_count<=bit_count+1;
                tx_shift_reg<={1'b0,tx_shift_reg[7:1]};
              end
            end
            else tick_count<=tick_count+1;
          end
          
          END: begin
            if(tick_count==4'd15) tick_count<=4'b0;
            else tick_count<=tick_count+1;
          end
          
        endcase
      end
    end
  end
          

  //////////////PROCESS-2 NEXT-STATE FSM LOGIC//////////////
    
  always@(*) begin
    next_state=cur_state;
    
    case(cur_state)
      
      IDLE: begin
        if(tx_start) next_state=START;
      end
      
      START: begin
        if(baud_tick && (tick_count==4'd15)) begin
          next_state=DATA;
        end
      end
      
      DATA: begin
        if(baud_tick && (tick_count==4'd15) && (bit_count==3'd7)) begin
          next_state=END;
        end
      end
      
      END: begin
        if(baud_tick && (tick_count==4'd15)) begin
          next_state=IDLE;
        end
      end
      
     endcase
   end
    
    //////////////PROCESS-3 OUTPUT SIGNAL GENERATION//////////////
  
  always@(*) begin
    
    tx_pin=1;
    tx_done=0;
    
    
    case(cur_state) 
      
      IDLE: begin
        tx_pin=1;
      end
      
      START: begin
        tx_pin=0;
      end
      
      DATA: begin
        tx_pin=tx_shift_reg[0];
      end
      
      END: begin
        tx_pin=1;
        tx_done=(baud_tick && (tick_count==4'd15));
      end
      
    endcase
  end
  
endmodule


///////////////////////////////////////////////////////
//UART_RX//
///////////////////////////////////////////////////////

module uart_rx(
  input clk,reset,baud_tick,rx_pin,
  output reg [7:0] rx_data,
  output reg rx_done);
  
  
  localparam IDLE=2'b00;
  localparam START=2'b01;
  localparam DATA=2'b10;
  localparam END=2'b11;
  
  reg [1:0]cur_state,next_state;
  reg [3:0] tick_count;
  reg [2:0] bit_count;
  reg [7:0] rx_shift_reg;
  
   //////////////PROCESS-1 COUNTER TRACKING//////////////
  
  always@(posedge clk or posedge reset) begin
    
    if(reset) begin
      cur_state<=IDLE;
      tick_count<=0;
      bit_count<=0;
      rx_shift_reg<=0;
    end
    else begin
      cur_state<=next_state;
      
      if(baud_tick) begin
        
        case(cur_state) 
          
          IDLE: begin
			tick_count<=0;
            bit_count<=0;
          end
          
          START: begin
            if(tick_count==4'd7) tick_count<=0;
            else tick_count<=tick_count+1;
          end
    		
          DATA: begin
            if(tick_count==4'd15) begin
              tick_count<=0;
              
              rx_shift_reg<={rx_pin,rx_shift_reg[7:1]};
              
              if(bit_count==3'd7) begin
                bit_count<=0;
              end
              else bit_count<=bit_count+1;
              
            end
            else tick_count<=tick_count+1;
          end
            
          END: begin
            if(tick_count==4'd15) tick_count<=0;
            else tick_count<=tick_count+1;
          end
          
        endcase
      end
    end
  end
          
   //////////////PROCESS-2 NEXT-STATE FSM LOGIC//////////////
         
    always@(*) begin
      
      next_state=cur_state;
      
      case(cur_state)
        
        IDLE: begin
          if(!rx_pin) next_state=START;
        end
        
        START: begin
          if(baud_tick && (tick_count==4'd7)) next_state=DATA;
        end
        
        DATA: begin
          if(baud_tick && (tick_count==4'd15) && (bit_count==3'd7)) next_state=END;
        end
        
        END: begin
          if(baud_tick && (tick_count==4'd15)) next_state=IDLE;
        end
        
        default: next_state=IDLE;
        
      endcase
    end
    
     //////////////PROCESS-3 OUTPUT SIGNAL GENERATION//////////////  
    
    always@(*) begin
      rx_done=0;
      rx_data=rx_shift_reg;
      
      if(cur_state==END && baud_tick && (tick_count==4'd15)) rx_done=1;
    end
  
endmodule
