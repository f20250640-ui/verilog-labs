// mux_df.v
// 2-to-1 multiplexer, DATAFLOW style.
//
// FIX: Y was declared "output reg". A continuous assignment (assign) can only
// drive a NET. A reg is a variable that holds a value written by procedural
// code; it has no "driver" for assign to attach to. Y is now a wire.

module mux_df (
  input       I0,
  input       I1,
  input       S,
  output wire Y
);

  assign Y = S ? I1 : I0;

endmodule
// Lab 2 final
