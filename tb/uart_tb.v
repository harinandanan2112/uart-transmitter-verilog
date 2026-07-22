module uart_tb;

reg clk, reset, tx_start;
reg [7:0] data;
wire tx;

uart_tx uut (
    .clk(clk),
    .reset(reset),
    .data(data),
    .tx_start(tx_start),
    .tx(tx)
);

always #5 clk = ~clk;

initial begin
$monitor("time=%0t pst=%d bit_count=%d clk=%b reset=%b data=%b shift_reg=%b baud_tick=%b tx=%b",$time,uut.pst,uut.bit_count,clk,reset,data,uut.shift_reg,uut.baud_tick,tx);
    clk = 0;
    reset = 1;
    tx_start = 0;
    data = 8'h00;

    #10;
    reset = 0;

    data = 8'hA7;
    tx_start = 1;
    #10;
    tx_start = 0;
    #550000;

 

    $finish;

end

endmodule


