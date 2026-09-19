// and_df.v -- 2-input AND, DATAFLOW with a continuous-assignment delay.
// Delay is `DELAY time units (default 1). Override with:  iverilog -DDELAY=2 ...

`ifndef DELAY
  `define DELAY 1
`endif

module and_df (
  input  a,
  input  b,
  output y
);

  assign #(`DELAY) y = a & b;      // for DELAY=1 this is exactly:  assign #1 y = a & b;

endmodule
// Lab 2 final
