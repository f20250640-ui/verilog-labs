// and_beh_before.v -- 2-input AND, BEHAVIORAL, delay BEFORE the assignment.
// Delay is `DELAY time units (default 1). Override with:  iverilog -DDELAY=2 ...
//
// #D y = a & b;  : wait D units, THEN evaluate a & b with whatever a and b are
// at that later moment, and write y. While the process sits in the #D, it is
// not waiting on @(*), so input changes during that window are not seen.

`ifndef DELAY
  `define DELAY 1
`endif

module and_beh_before (
  input      a,
  input      b,
  output reg y
);

  always @(*) begin
    #(`DELAY) y = a & b;           // for DELAY=1:  #1 y = a & b;
  end

endmodule
