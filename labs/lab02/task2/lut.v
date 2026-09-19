// lut.v
// A small parameterized ROM (lookup table): DEPTH words, each WIDTH bits
// wide. dout continuously reflects mem[sel].

module lut #(
  parameter WIDTH = 8,
  parameter DEPTH = 4
) (
  input      [$clog2(DEPTH)-1:0] sel,
  output reg [WIDTH-1:0]         dout
);

  reg [WIDTH-1:0] mem [0:DEPTH-1];

  integer i;

  // ROM contents: mem[i] = i*i. An initial block runs exactly once at time 0,
  // which is what a ROM needs (contents exist before any read, never change).
  initial begin
    for (i = 0; i < DEPTH; i = i + 1)
      mem[i] = i * i;
  end

  // Combinational read. always @(*) re-evaluates when sel changes (and, because
  // mem is an array, when any word of mem changes -- so even if sel is applied
  // at time 0 before the initial block has run, dout still corrects itself once
  // the ROM is loaded). iverilog may print an informational note that @* is
  // "sensitive to all N words in array 'mem'"; that is harmless.
  always @(*) begin
    dout = mem[sel];
  end

endmodule
