// DO NOT MODIFY THE MODULE NAMES, SIGNAL NAMES, SIGNAL PROPERTIES
module top (
  input        clk   ,
  input  [3:0] sw    ,
  input  [3:0] btn   ,
  output [7:0] led   ,
  output [7:0] seven0, seven1, seven2, seven3
);

/* Your module instantiations here.*/

// You will instantiate the battleship, clk_divider, debouncer module here

endmodule

module battleship (
  input            clk  ,
  input            rst  ,
  input            start,
  input      [1:0] X    ,
  input      [1:0] Y    ,
  input            pAb  ,
  input            pBb  ,
  output reg [7:0] disp0,
  output reg [7:0] disp1,
  output reg [7:0] disp2,
  output reg [7:0] disp3,
  output reg [7:0] led
);

/* Your design goes here. */

endmodule

// DO NOT MODIFY CLK_DIVIDER, DEBOUNCER MODULES

module clk_divider (
  input      clk_in     ,
  output reg divided_clk
);

  parameter  toggle_value = 10; // This module will give you a 50 Hz clock in the divided_clk (You must investigate why.)
  reg [24:0] cnt              ;

  initial begin
    cnt = 0;
    divided_clk = 0;
  end

  always@(posedge clk_in)
    begin
      if (cnt==toggle_value) begin
        cnt         <= 0;
        divided_clk <= ~divided_clk;
      end
      else begin
        cnt         <= cnt +1;
        divided_clk <= divided_clk;
      end
    end

endmodule



module debouncer (
  input      clk      ,
  input      rst      ,
  input      noisy_in , // port from the push button
  output reg clean_out  // port into the circuit
);

  reg noisy_in_reg;

  reg clean_out_tmp1; // will be used to detect rising edge
  reg clean_out_tmp2; // will be used to detect rising edge
  reg clean_out_tmp3; // will be used to detect rising edge
  reg clean_out_tmp4; // will be used to detect rising edge

  always@(posedge clk or posedge rst)
    begin
      if (rst==1'b1) begin
        noisy_in_reg   <= 0;
        clean_out_tmp1 <= 0;
        clean_out_tmp2 <= 0;

        clean_out <= 0;
      end
      else begin
        // store the input
        noisy_in_reg   <= noisy_in;
        clean_out_tmp1 <= noisy_in_reg;

        // rising edge detect
        clean_out_tmp2 <= clean_out_tmp1;
        clean_out_tmp3 <= clean_out_tmp2;
        clean_out_tmp4 <= clean_out_tmp3;
        clean_out      <= ~clean_out_tmp4 & clean_out_tmp3; // it produce a single pulse during a risingedge
      end
    end

endmodule