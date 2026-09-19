// tb.v -- Task 3: self-checking testbench for comp2 (2-bit magnitude comparator)
//
// Exhaustive: all 16 (A,B) pairs. Expected outputs are computed independently
// of the design's logic -- from the sign of the integer difference A-B -- so a
// bug in the design's comparison operators can't be repeated here.
// Failures are counted (not fatal) so a single run reports how many of the 16
// pairs are wrong.
//
// Run:  iverilog -g2012 -o t3 tb.v comp2.v   &&  vvp t3
//   (to watch every signal change while developing:  -DDEBUG )
// NOTE: no $stop here on purpose -- it would hang an automated run.

module tb;

  reg  [1:0] t_a, t_b;
  wire       t_gt, t_lt, t_eq;

  reg        exp_gt, exp_lt, exp_eq;
  integer    i, j, diff, errors, total;

  comp2 U1 (
    .A  (t_a),
    .B  (t_b),
    .GT (t_gt),
    .LT (t_lt),
    .EQ (t_eq)
  );

`ifdef DEBUG
  initial
    $monitor($time, " A=%b B=%b | GT=%b LT=%b EQ=%b", t_a, t_b, t_gt, t_lt, t_eq);
`endif

  initial begin
    errors = 0;
    total  = 0;

    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        t_a = i;
        t_b = j;

        // independent expected result: look at the sign of the difference
        diff   = i - j;
        exp_gt = (diff > 0);
        exp_lt = (diff < 0);
        exp_eq = (diff == 0);

        #5;                               // let the design settle
        total = total + 1;

        if ({t_gt, t_lt, t_eq} !== {exp_gt, exp_lt, exp_eq}) begin
          $display("FAIL at time %0t: A=%b B=%b  got GT=%b LT=%b EQ=%b  expected GT=%b LT=%b EQ=%b",
                   $time, t_a, t_b, t_gt, t_lt, t_eq, exp_gt, exp_lt, exp_eq);
          errors = errors + 1;
        end
      end
    end

    // one-line summary, built piece by piece with $write
    $write("SUMMARY: %0d of %0d combinations passed", total - errors, total);
    if (errors == 0) $write(" -- ALL PASS");
    else             $write(" -- %0d FAILED", errors);
    $write("\n");
    $finish;
  end

endmodule
