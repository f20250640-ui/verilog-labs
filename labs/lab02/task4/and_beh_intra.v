// and_beh_intra.v -- 2-input AND, BEHAVIORAL, INTRA-assignment delay.
// Delay is `DELAY time units (default 1). Override with:  iverilog -DDELAY=2 ...
//
// y = #D a & b;  : a & b is evaluated NOW, with the current a and b; only the
// write of that already-computed value into y is delayed by D. The process is
// blocked for those D units, so input changes in that window are not seen.

`ifndef DELAY
  `define DELAY 1
`endif

module and_beh_intra (
  input      a,
  input      b,
  output reg y
);

  always @(*) begin
    y = #(`DELAY) a & b;           // for DELAY=1:  y = #1 a & b;
  end

endmodule
