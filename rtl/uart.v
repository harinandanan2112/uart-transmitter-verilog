module baud_rate(clk,reset,baud_tick);
input clk,reset;
output reg baud_tick;
reg [12:0]baud_count;
always @(posedge clk or posedge reset)begin
    if (reset)begin
        baud_count<=0;
    end
    else begin
        if (baud_count==1)begin
            baud_count<=0;
        end
        else begin
            baud_count<=baud_count+1;
        end
    end
end

always @(*)begin
    if (baud_count==1)begin
        baud_tick =1;
    end
    else begin
        baud_tick=0;
    end
end
endmodule


module uart_tx(tx,clk,reset,data,tx_start);
input clk,reset,tx_start;
input [7:0]data;
output reg tx;
wire baud_tick;
reg [2:0]pst,nst;
reg [2:0]bit_count;
reg count_clear,count_enable;
reg [7:0]shift_reg;
reg load,shift_enable;

parameter IDLE=2'b00;
parameter START =2'b01;
parameter DATA = 2'b10;
parameter STOP =2'b11;

baud_rate baud1(clk,reset,baud_tick);

always @(posedge clk or posedge reset)begin
    if (reset)begin
        pst<=IDLE;
    end
    else begin
        pst<=nst;
    end
end

always @(*)begin
    case(pst)
    IDLE:
    begin
    if (tx_start)begin
        nst=START;
    end
    else begin
        nst=IDLE;
    end
    end
    
    START:
    begin
        nst=DATA;
    end
    
    DATA:
    begin
    if (bit_count==7)begin
        nst=STOP;
    end
    else begin
        nst=DATA;
    end
    end
    
    STOP:
    begin
        nst=IDLE;
    end
    
    default:nst=IDLE;
    endcase
end

always @(posedge clk)begin                                              
    if (reset)begin                                                        
        bit_count<=0;
    end
    else begin
        if (count_clear || ~count_enable)begin
            bit_count<=0;
        end
        else begin
            if (baud_tick && count_enable)begin
                bit_count<=bit_count+1;
            end
            else begin
                bit_count<=bit_count;
            end
        end
    end
end
         
always @(*)begin
    if (bit_count==8)begin
        count_clear=1;
    end
    else begin
        count_clear=0;
    end
end

always @(*)begin
    if (pst==DATA)begin
        count_enable=1;
    end
    else begin
        count_enable=0;
    end
end

always @(*)begin
    if (pst==START)begin
        load=1;
    end
    else begin
        load=0;
    end
end

always @(*)begin
    if (pst==DATA)begin
        shift_enable=1;
    end
    else begin
        shift_enable=0;
    end
end

always @(posedge clk)begin
    if (load)begin
        shift_reg <= data;
    end
    else if(shift_enable)begin
        if (baud_tick)begin
            shift_reg <= shift_reg>>1;
        end
        else begin
            shift_reg <= shift_reg;
        end
    end
    else begin
        shift_reg<=shift_reg;
    end
end

always @(*)begin
    case(pst)
    IDLE:
    begin
        tx=1'b1;
    end
    
    START:
    begin
        tx=1'b0;
    end
    
    DATA:
    begin
        tx=shift_reg[0];
    end
    
    STOP:
    begin
        tx=1'b1;
    end
    
    default:tx=1'b1;
    endcase
end
endmodule
    







    
    
        
    



    
    
        
            
            
            
            
                
    
    
    
