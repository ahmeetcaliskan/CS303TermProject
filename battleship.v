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
 

  parameter IDLE       = 4'b0000;
  parameter SHOW_A     = 4'b0001;
  parameter A_IN       = 4'b0010;
  parameter ERROR_A    = 4'b0011;
  parameter SHOW_B     = 4'b0100;
  parameter B_IN       = 4'b0101;
  parameter ERROR_B    = 4'b0110;
  parameter SHOW_SCORE = 4'b0111;
  parameter A_SHOOT    = 4'b1000;
  parameter A_SINK     = 4'b1001;
  parameter A_WIN      = 4'b1010;
  parameter B_SHOOT    = 4'b1011;
  parameter B_SINK     = 4'b1100;
  parameter B_WIN      = 4'b1101;
  parameter NEW  = 4'b1110;



  reg [3:0] state;
  reg [5:0] counter = 0;
  reg [5:0] counter_error = 0;
  reg [2:0] WinA = 0;
  reg [2:0] WinB = 0;
  reg check = 0;
  reg [2:0] input_counter = 0;
  reg [15:0] A_MAP = 16'b0000000000000000;
  reg [15:0] B_MAP = 16'b0000000000000000;
 
  reg [1:0] roundCount = 0;
  reg [1:0] scoreA = 0;
  reg [1:0] scoreB = 0;
  reg       nextStarter = 0;
 
  always @(posedge clk or posedge rst)
    begin
      if (rst)
      begin
        state <= IDLE;
        counter <= 0;
        counter_error <= 0;
        WinA <= 0;
        WinB <= 0;
        input_counter <= 0;
        A_MAP <= 16'b0000000000000000;
        B_MAP <= 16'b0000000000000000;
        check <= 0;
        roundCount <= 0;
        scoreA <= 0;
        scoreB <= 0;
        nextStarter <= 0;
      end
      else
      begin
        case (state)
          IDLE:
            begin
              if (start) begin
                state <= SHOW_A;
              end
            end
 
          SHOW_A:
            begin
              counter <= counter + 1;
              if (counter == 49)
              begin
                counter <= 0;
                state <= A_IN;
              end
            end
 




 
          ERROR_A:
            begin
              counter_error <= counter_error + 1;
              if (counter_error == 49)
              begin
                counter_error <= 0;
                state <= A_IN;
              end
            end

 
          A_IN:
            begin
              if (pAb)
              begin
                if (A_MAP[X*4+Y])
                  state <= ERROR_A;
                else
                begin
                  if (input_counter == 3)
                  begin
                    A_MAP[X*4+Y] <= 1;
                    input_counter <= 0;
                    if (nextStarter == 0)
                      state <= SHOW_B;
                    else
                      state <= SHOW_SCORE;
                  end
                  else
                  begin
                    input_counter <= input_counter + 1;
                    A_MAP[X*4+Y] <= 1;
                  end
                end
              end
            end


          B_IN:
            begin
              if (pBb)
              begin
                if (B_MAP[X*4+Y])
                  state <= ERROR_B;
                else
                begin
                  if (input_counter == 3)
                  begin
                    B_MAP[X*4+Y] <= 1;
                    input_counter <= 0;
                    if(nextStarter == 0)
                      state <= SHOW_SCORE;
                    else
                      state <= SHOW_A;
                  end
                  else
                  begin
                    input_counter <= input_counter + 1;
                    B_MAP[X*4+Y] <= 1;
                  end
                end
              end
            end
         
          SHOW_B:
            begin
              counter <= counter + 1;
              if (counter == 49)
              begin
                counter <= 0;
                state <= B_IN;
              end
            end
 
       
 

          ERROR_B:
            begin
              counter_error <= counter_error + 1;
              if (counter_error == 49)
              begin
                counter_error <= 0;
                state <= B_IN;
              end
            end
 
          SHOW_SCORE:
            begin
              counter <= counter + 1;
              if (counter == 49)
              begin
                counter <= 0;
                if(nextStarter == 0)
                begin
                  state <= A_SHOOT;
                end
                else
                begin
                  state <= B_SHOOT;
                end
              end
            end
 
          A_SHOOT:
            begin
              if (pAb)
              begin
                if (B_MAP[X*4+Y])
                begin
                  WinA <= WinA + 1;
                  B_MAP[X*4+Y] <= 0;
                  check <= 1;
                end
                else
                begin
                  check <= 0;
                  WinA <= WinA;
                end
                state <= A_SINK;  
              end
              else
              begin
                check <= 0;
                WinA <= WinA;
                state <= A_SHOOT;
              end
            end
 
          A_SINK:
            begin
              counter <= counter + 1;
              if (counter == 49)
              begin
                counter <= 0;
                if(WinA > 3) begin
                  scoreA <= scoreA + 1;
                  nextStarter <= 0;
                  if(scoreA == 1) begin
                    state <= A_WIN;
                  end
                  else begin
                    state <= NEW;
                  end
                end
                else begin
                  state <= B_SHOOT;
                end
              end
            end
 
          A_WIN:
            begin
              counter <= counter + 1;
            end
 



          NEW:
            begin
              counter <= counter + 1;
             
              A_MAP <= 16'b0000000000000000;
              B_MAP <= 16'b0000000000000000;
              WinA <= 0;
              WinB <= 0;
              check <= 0;
              input_counter <= 0;

             
              if (counter == 0) begin
               
                roundCount <= roundCount + 1;
             
              end

              if (counter == 49)
              begin
                counter <= 0;
                if(roundCount < 3) begin
                  if(nextStarter == 0)
                    state <= A_IN;
                  else
                    state <= B_IN;
                end
                else begin
                  state <= IDLE;
                end
              end
            end

           
          B_SHOOT:
            begin
              if (pBb)
              begin
                if (A_MAP[X*4+Y])
                begin
                  WinB <= WinB + 1;
                  A_MAP[X*4+Y] <= 0;
                  check <= 1;
                end
                else
                begin
                  check <= 0;
                  WinB <= WinB;
                end
                state <= B_SINK;  
              end
              else
              begin
                check <= 0;
                WinB <= WinB;
                state <= B_SHOOT;
              end
            end
 
          B_SINK:
          begin
            counter <= counter + 1;
            if (counter == 49)
            begin
              counter <= 0;
              if(WinB > 3) begin
                scoreB <= scoreB + 1;
                nextStarter <= 1;
                if(scoreB == 1) begin
                  state <= B_WIN;
                end
                else begin
                  state <= NEW;
                end
              end
              else begin
                state <= A_SHOOT;
              end
            end
          end
 
          B_WIN:
            begin
              counter <= counter + 1;
            end


         

          default:
            begin
              state <= IDLE;
            end
       
        endcase
      end
    end

  always @(*)
    begin

      case (state)
       
        IDLE:
          begin
            disp0 = 8'b01111001; // 'E'
            disp1 = 8'b00111000; // 'L'
            disp2 = 8'b01011110; // 'D'
            disp3 = 8'b00000110; // 'I'
            led   = 8'b10011001;
          end

        SHOW_A:
          begin
            disp0 = 8'b00000000;
            disp1 = 8'b00000000;
            disp2 = 8'b00000000;
            disp3 = 8'b01110111; // 'A'
            led   = 8'b10000000;
          end

        A_IN:
          begin
            disp3 = 8'b00000000;
            disp2 = 8'b00000000;
            led   = 8'b10000000;
            case (Y)
              2'b00: disp0 = 8'b00111111;
              2'b01: disp0 = 8'b00000110;
              2'b10: disp0 = 8'b01011011;
              2'b11: disp0 = 8'b01001111;
              default: disp0 = 8'b00000000;
            endcase

            case (X)
              2'b00: disp1 = 8'b00111111;
              2'b01: disp1 = 8'b00000110;
              2'b10: disp1 = 8'b01011011;
              2'b11: disp1 = 8'b01001111;
              default: disp1 = 8'b00000000;
            endcase

            case(input_counter)
              2'b00: led[5:4] = 2'b00;
              2'b01: led[5:4] = 2'b01;
              2'b10: led[5:4] = 2'b10;
              2'b11: led[5:4] = 2'b11;
              default: led[5:4] = 2'b00;
            endcase
          end

        ERROR_A:
          begin
            disp0 = 8'b00111111; // 'O'
            disp1 = 8'b01110111; // 'R'
            disp2 = 8'b01110111; // 'R'
            disp3 = 8'b01111001; // 'E'
            led   = 8'b10011001;
          end

        SHOW_B:
          begin
            disp0 = 8'b00000000;
            disp1 = 8'b00000000;
            disp2 = 8'b00000000;
            disp3 = 8'b01111100; // 'B'
            led   = 8'b00000001;
          end

        B_IN:
          begin
            disp3 = 8'b00000000;
            disp2 = 8'b00000000;
            led   = 8'b00000001;
            case (Y)
              2'b00: disp0 = 8'b00111111;
              2'b01: disp0 = 8'b00000110;
              2'b10: disp0 = 8'b01011011;
              2'b11: disp0 = 8'b01001111;
              default: disp0 = 8'b00000000;
            endcase

            case (X)
              2'b00: disp1 = 8'b00111111;
              2'b01: disp1 = 8'b00000110;
              2'b10: disp1 = 8'b01011011;
              2'b11: disp1 = 8'b01001111;
              default : disp1 = 8'b00000000;
            endcase

            case(input_counter)
              2'b00: led[3:2] = 2'b00;
              2'b01: led[3:2] = 2'b01;
              2'b10: led[3:2] = 2'b10;
              2'b11: led[3:2] = 2'b11;
              default: led[5:4] = 2'b00;
            endcase
          end

        ERROR_B:
          begin
            disp0 = 8'b00111111; // 'O'
            disp1 = 8'b01110111; // 'R'
            disp2 = 8'b01110111; // 'R'
            disp3 = 8'b01111001; // 'E'
            led   = 8'b10011001;
          end

        SHOW_SCORE:
          begin
            disp0 = 8'b00111111; // '0'
            disp1 = 8'b01000000; // '-'
            disp2 = 8'b00111111; // '0'
            disp3 = 8'b00000000;
            led   = 8'b10011001;
          end

        A_SHOOT:
          begin
            disp2 = 8'b00000000;
            disp3 = 8'b00000000;
            led   = 8'b10000000;
            case (Y)
              2'b00: disp0 = 8'b00111111;
              2'b01: disp0 = 8'b00000110;
              2'b10: disp0 = 8'b01011011;
              2'b11: disp0 = 8'b01001111;
            default: disp0 = 8'b00000000;
             
            endcase

            case (X)
              2'b00: disp1 = 8'b00111111;
              2'b01: disp1 = 8'b00000110;
              2'b10: disp1 = 8'b01011011;
              2'b11: disp1 = 8'b01001111;
              default: disp1 = 8'b00000000;

            endcase

            case(WinA)
              2'b00: led[5:4] = 2'b00;
              2'b01: led[5:4] = 2'b01;
              2'b10: led[5:4] = 2'b10;
              2'b11: led[5:4] = 2'b11;
              default:  led[5:4] = 2'b00;


            endcase
            case(WinB)
              2'b00: led[3:2] = 2'b00;
              2'b01: led[3:2] = 2'b01;
              2'b10: led[3:2] = 2'b10;
              2'b11: led[3:2] = 2'b11;
              default:  led[3:2] = 2'b00;
            endcase
          end

        A_SINK:
          begin
            disp1 = 8'b01000000;
            disp3 = 8'b00000000;
            case(WinB)
              2'b00: disp0 = 8'b00111111;
              2'b01: disp0 = 8'b00000110;
              2'b10: disp0 = 8'b01011011;
              2'b11: disp0 = 8'b01001111;
              default: disp0 = 8'b00000000;
            endcase


            case(WinA)
              2'b00: disp2 = 8'b00111111;
              2'b01: disp2 = 8'b00000110;
              2'b10: disp2 = 8'b01011011;
              2'b11: disp2 = 8'b01001111;
              default: disp2 = 8'b00000000;
            endcase

            case(check)
              1'b0: led = 8'b00000000;
              1'b1: led = 8'b11111111;
              default: led = 8'b00000000;
            endcase
          end

        A_WIN:
          begin
            disp3 = 8'b01110111; // 'A'
            disp1 = 8'b01000000; // '-'

            case(counter % 4)
              2'b00: led = 8'b10000001;
              2'b01: led = 8'b01000010;
              2'b10: led = 8'b00100100;
              2'b11: led = 8'b00011000;
              default: led = 8'b00000000;
            endcase

            case(WinB)
              2'b00: disp0 = 8'b00111111;
              2'b01: disp0 = 8'b00000110;
              2'b10: disp0 = 8'b01011011;
              2'b11: disp0 = 8'b01001111;
              default: disp0 = 8'b00000000;
            endcase

            disp2 = 8'b01100110;
          end

        B_SHOOT:
          begin
            disp2 = 8'b00000000;
            disp3 = 8'b00000000;
            led   = 8'b00000001;
            case (Y)
              2'b00: disp0 = 8'b00111111;
              2'b01: disp0 = 8'b00000110;
              2'b10: disp0 = 8'b01011011;
              2'b11: disp0 = 8'b01001111;
              default: disp0 = 8'b00000000;
            endcase

            case (X)
              2'b00: disp1 = 8'b00111111;
              2'b01: disp1 = 8'b00000110;
              2'b10: disp1 = 8'b01011011;
              2'b11: disp1 = 8'b01001111;
              default: disp1 = 8'b00000000;
            endcase

            case(WinA)
              2'b00: led[5:4] = 2'b00;
              2'b01: led[5:4] = 2'b01;
              2'b10: led[5:4] = 2'b10;
              2'b11: led[5:4] = 2'b11;
              default: led[5:4] = 2'b00;
            endcase
            case(WinB)
              2'b00: led[3:2] = 2'b00;
              2'b01: led[3:2] = 2'b01;
              2'b10: led[3:2] = 2'b10;
              2'b11: led[3:2] = 2'b11;
              default: led[3:2] = 2'b00;
            endcase
          end

        B_SINK:
          begin
            disp1 = 8'b01000000;
            disp3 = 8'b00000000;
            case(WinB)
              2'b00: disp0 = 8'b00111111;
              2'b01: disp0 = 8'b00000110;
              2'b10: disp0 = 8'b01011011;
              2'b11: disp0 = 8'b01001111;
              default: disp0 = 8'b00000000;
            endcase

            case(WinA)
              2'b00: disp2 = 8'b00111111;
              2'b01: disp2 = 8'b00000110;
              2'b10: disp2 = 8'b01011011;
              2'b11: disp2 = 8'b01001111;
              default: disp2 = 8'b00000000;
            endcase

            case(check)
              1'b0: led = 8'b00000000;
              1'b1: led = 8'b11111111;
              default: led = 8'b00000000;
            endcase
          end

        B_WIN:
          begin
            disp3 = 8'b01111100; // 'B'
            disp1 = 8'b01000000; // '-'
            case(counter % 4)
              2'b00: led = 8'b10000001;
              2'b01: led = 8'b01000010;
              2'b10: led = 8'b00100100;
              2'b11: led = 8'b00011000;
              default: led = 8'b00000000;
            endcase

            disp0 = 8'b01100110;

            case(WinA)
              2'b00: disp2 = 8'b00111111;
              2'b01: disp2 = 8'b00000110;
              2'b10: disp2 = 8'b01011011;
              2'b11: disp2 = 8'b01001111;
              default: disp2 = 8'b00000000;
            endcase
          end


        NEW:
          begin
            disp1 = 8'b01000000;
            disp3 = 8'b00000000;
           
            case(scoreB)
              2'b00: disp0 = 8'b00111111;
              2'b01: disp0 = 8'b00000110;
              2'b10: disp0 = 8'b01011011;
              2'b11: disp0 = 8'b01001111;
            endcase
            case(scoreA)
              2'b00: disp2 = 8'b00111111;
              2'b01: disp2 = 8'b00000110;
              2'b10: disp2 = 8'b01011011;
              2'b11: disp2 = 8'b01001111;
            endcase
            led = 8'b10011001;
          end

        default :
          begin
            disp0 = 8'b00000000;
            disp1 = 8'b00000000;
            disp2 = 8'b00000000;
            disp3 = 8'b00000000;
            led   = 8'b00000000;
          end
        endcase
    end

endmodule
 
 
