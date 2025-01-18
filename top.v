


module top (
    input        clk    ,
    input  [3:0] sw     ,
    input  [3:0] btn    ,
    output [7:0] led    ,
    output [7:0] seven  ,
    output [3:0] segment
  );
  
  
    wire divided_clk;
    wire pAb, pBb, start, rst;
    wire [7:0] seven0, seven1, seven2, seven3;
    
    clk_divider clk_divider_inst (
        .clk_in(clk),
        .divided_clk(divided_clk)
    );
    
    
    debouncer debouncer_inst_1 (
        .clk(divided_clk),
        .rst(rst),
        .noisy_in(!btn[3]),
        .clean_out(pAb)
    );
    
    debouncer debouncer_inst_2 (
        .clk(divided_clk),
        .rst(rst),
        .noisy_in(!btn[0]),
        .clean_out(pBb)
    );
    
    debouncer debouncer_inst_3 (
        .clk(divided_clk),
        .rst(rst),
        .noisy_in(!btn[1]),
        .clean_out(start)
    );
    
    debouncer debouncer_inst_4 (
        .clk(divided_clk),
        .rst(1'b0),
        .noisy_in(!btn[2]),
        .clean_out(rst)
    );
    
    battleship battleship_inst (
        .clk(divided_clk),
        .rst(rst),
        .start(start),
        .X(sw[3:2]),
        .Y(sw[1:0]),
        .pAb(pAb),
        .pBb(pBb),
        .disp0(seven0),
        .disp1(seven1),
        .disp2(seven2),
        .disp3(seven3),
        .led(led)
    );
  

    ssd ssd_inst (
        .clk(clk),
        .disp0(seven0),
        .disp1(seven1),
        .disp2(seven2),
        .disp3(seven3),
        .seven(seven),
        .segment(segment)
    );  

  
  endmodule
  
  