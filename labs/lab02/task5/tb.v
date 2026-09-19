// tb.v -- Task 5: self-checking testbench for alu
//
// Phase 1 (directed): for several fixed operand pairs, hold a and b constant
//   and switch ONLY op (0 -> 1 -> 0). Catches the sensitivity-list bug
//   (result must respond to op alone).
// Phase 2 (exhaustive): operands change through all 16 x 16 pairs with op=0,
//   then again with op=1. Catches the blocking/non-blocking bug in the sub
//   path on essentially every subtraction.
//
// Expected values are computed with Verilog's own + and - on 4 bits (mod 16),
// NOT by repeating the DUT's invert-and-add steps.
//
// Run:  iverilog -g2012 -o t5 tb.v alu.v   &&  vvp t5 [+vcd=wave.vcd]
// Only the first MAXPRINT failures are printed so a badly broken design
// doesn't flood the console; the summary still counts every failure.

module tb;

  localparam MAXPRINT = 20;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  reg  [3:0] exp_res;
  integer    i, j, errors, total;

  reg [1023:0] vcd_file;

  alu U1 (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, tb);
    end
  end

  // Wait for the design to settle, then compare result with the expected value
  task check;
    begin
      #5;
      exp_res = t_op ? (t_a - t_b) : (t_a + t_b);   // 4-bit, wraps mod 16
      total = total + 1;
      if (t_result !== exp_res) begin
        if (errors < MAXPRINT)
          $display("FAIL at time %0t: op=%b a=%0d b=%0d  got %0d expected %0d",
                   $time, t_op, t_a, t_b, t_result, exp_res);
        errors = errors + 1;
      end
    end
  endtask

  // one directed pair: same operands, op toggled 0 -> 1 -> 0
  task pair_switch_op;
    input [3:0] a;
    input [3:0] b;
    begin
      t_a = a;  t_b = b;
      t_op = 0;  check;
      t_op = 1;  check;      // ONLY op changed
      t_op = 0;  check;      // ONLY op changed
    end
  endtask

  initial begin
    errors = 0;
    total  = 0;

    // ---- Phase 1: fixed operands, switch op ----
    pair_switch_op(4'd9,  4'd3);
    pair_switch_op(4'd3,  4'd9);     // negative result wraps
    pair_switch_op(4'd15, 4'd1);
    pair_switch_op(4'd0,  4'd0);
    pair_switch_op(4'd5,  4'd5);
    pair_switch_op(4'd7,  4'd12);

    // ---- Phase 2: operands change, op fixed (add, then sub) ----
    t_op = 0;
    for (i = 0; i < 16; i = i + 1)
      for (j = 0; j < 16; j = j + 1) begin
        t_a = i;  t_b = j;  check;
      end

    t_op = 1;
    for (i = 0; i < 16; i = i + 1)
      for (j = 0; j < 16; j = j + 1) begin
        t_a = i;  t_b = j;  check;
      end

    $write("SUMMARY: %0d of %0d checks passed", total - errors, total);
    if (errors == 0) $write(" -- ALL PASS");
    else             $write(" -- %0d FAILED", errors);
    $write("\n");
    $finish;
  end

endmodule
