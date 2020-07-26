
`include "hvsync_generator.v"

module top(clk, reset, hsync, vsync, rgb, clock_out, counter);

  input clk, reset;
  output hsync, vsync;
  output [2:0] rgb;
  wire display_on;
  wire [8:0] hpos;
  wire [8:0] vpos;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  wire [8:0] vpos_change;
  output [8:0] counter = 9'd0;
  output clock_out;
  parameter DIVISOR = 9'd511;
  parameter ONE = 9'd1;
  parameter ZERO = 9'd0;
  
  always_ff @(posedge clk)
    begin
      counter <= counter + ONE;
      if (counter >= (DIVISOR - 1))
        begin
          counter <= ZERO;
        end
    end
  
  always_ff @(posedge clock_out)
    begin
      // hpos change  
      vpos_change <= vpos_change + 9'd511;
      if (vpos_change >= 9'd511) 
        vpos_change <= 9'd0;  
    end
  
  wire r = display_on && 1;
  wire g = display_on && vpos[1 % vpos_change];
  wire b = display_on && 1;
  
  assign clock_out = ( counter < DIVISOR / 9'd511) ? 1'b0 : 1'b1;
  assign rgb = {b,g,r};

endmodule
