// alu.v
// 1-bit-opcode ALU: op=0 -> add, op=1 -> sub. 4-bit operands.
// Subtraction is implemented the way real hardware does it: negate b (one's
// complement, then +1 for two's complement) and add.
//
// FIXES (two bugs found by simulation):
//   1. Sensitivity list was (a, b): a change on op alone never re-ran the
//      block, so result went stale when only op switched. Now (a, b, op).
//   2. The subtract branch used non-blocking (<=) for a chain of dependent
//      steps. With <=, every right-hand side is read before any update lands,
//      so b_twos used the OLD b_inv and result used the OLD b_twos (the chain
//      ran one step behind per evaluation). Blocking (=) makes each step's
//      new value visible to the next statement in the same block.

module alu (
  input      [3:0] a,
  input      [3:0] b,
  input            op,      // 0 = add, 1 = sub
  output reg [3:0] result
);

  reg [3:0] b_inv;
  reg [3:0] b_twos;

  always @(a, b, op) begin
    case (op)
      1'b0: begin
        result = a + b;                 // add
      end
      1'b1: begin
        b_inv  = ~b;                    // sub, via two's complement
        b_twos = b_inv + 1;
        result = a + b_twos;
      end
    endcase
  end

endmodule
