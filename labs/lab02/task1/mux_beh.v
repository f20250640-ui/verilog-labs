// mux_beh.v
// 2-to-1 multiplexer, BEHAVIORAL style.
//
// FIX: Y was declared "output wire". Inside an always block the left-hand
// side of "=" must be a VARIABLE (reg): procedural assignment stores a value
// that persists until the next time the block runs. A wire has no storage,
// it only reflects whatever its drivers currently say. Y is now a reg.

module mux_beh (
  input      I0,
  input      I1,
  input      S,
  output reg Y
);

  always @(*) begin
    if (S)
      Y = I1;
    else
      Y = I0;
  end

endmodule
