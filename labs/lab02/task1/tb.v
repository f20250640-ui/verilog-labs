// tb.v -- Task 1: testbench for the 2-to-1 mux (works with either dut.v option)
//
// Applies all 8 combinations of {S, I1, I0}, 5 time units apart, and checks Y
// against the mux equation after each one.
//
// Run:  iverilog -g2012 -o t1 tb.v dut.v mux_df.v   &&  vvp t1 [+vcd=wave.vcd]

module tb;

  // testbench drives inputs -> reg; observes output -> wire
  reg  t_i0, t_i1, t_s;
  wire t_y;

  reg  exp_y;
  integer i, errors;

  reg [1023:0] vcd_file;      // (reg, not string, so plain -g2005 also works)

  // Device under test
  DUT U_DUT (
    .I0 (t_i0),
    .I1 (t_i1),
    .S  (t_s),
    .Y  (t_y)
  );

  // Optional waveform dump:  vvp t1 +vcd=wave.vcd
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, tb);
    end
  end

  // Print every change
  initial
    $monitor($time, " S=%b I1=%b I0=%b | Y=%b", t_s, t_i1, t_i0, t_y);

  // Stimulus: 8 combinations, 5 time units apart, each checked before the next
  initial begin
    errors = 0;
    for (i = 0; i < 8; i = i + 1) begin
      {t_s, t_i1, t_i0} = i[2:0];           // 000, 001, ... 111

      #5;                                   // hold this combination for 5 units

      exp_y = (t_s & t_i1) | (~t_s & t_i0); // mux equation
      if (t_y !== exp_y) begin
        $display("FAIL at time %0t: S=%b I1=%b I0=%b  got Y=%b expected Y=%b",
                 $time, t_s, t_i1, t_i0, t_y, exp_y);
        errors = errors + 1;
      end
    end

    $write("SUMMARY: %0d of 8 combinations passed", 8 - errors);
    if (errors == 0) $write(" -- ALL PASS");
    $write("\n");
    $finish;
  end

endmodule
