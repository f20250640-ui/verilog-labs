// tb.v -- Task 2: testbench for the parameterized ROM (lut.v)
//
// Two instances:
//   U1 : parameter override  WIDTH=8, DEPTH=8   (sel is 3 bits wide)
//   U2 : module defaults     WIDTH=8, DEPTH=4   (sel is 2 bits wide)
// t_sel is 3 bits, enough for the largest DEPTH used (8). U2 only sees the low
// 2 bits and is only checked for addresses 0..3.
//
// Run:  iverilog -g2012 -o t2 tb.v lut.v   &&  vvp t2 [+vcd=wave.vcd]

module tb;

  reg  [2:0] t_sel;
  wire [7:0] t_dout;      // from U1 (WIDTH=8, DEPTH=8)
  wire [7:0] t_dout_def;  // from U2 (default parameters)

  reg  [7:0] exp_dout;
  integer i, errors, total;

  reg [1023:0] vcd_file;

  // Parameter override: parameters are set only here, at instantiation.
  lut #(.WIDTH(8), .DEPTH(8)) U1 (
    .sel  (t_sel),
    .dout (t_dout)
  );

  // Default parameters (DEPTH=4) for comparison
  lut U2 (
    .sel  (t_sel[1:0]),
    .dout (t_dout_def)
  );

  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, tb);
    end
  end

  initial
    $monitor($time, " sel=%0d | U1.dout=%0d  U2.dout=%0d", t_sel, t_dout, t_dout_def);

  initial begin
    errors = 0;
    total  = 0;

    #1;   // let the ROM's initial block finish before the first read

    for (i = 0; i < 8; i = i + 1) begin
      t_sel = i;
      #5;

      exp_dout = i * i;                       // same formula the ROM used

      // U1: DEPTH=8, every address
      total = total + 1;
      if (t_dout !== exp_dout) begin
        $display("FAIL U1 at time %0t: sel=%0d got %0d expected %0d",
                 $time, t_sel, t_dout, exp_dout);
        errors = errors + 1;
      end

      // U2: DEPTH=4, addresses 0..3 only
      if (i < 4) begin
        total = total + 1;
        if (t_dout_def !== exp_dout) begin
          $display("FAIL U2 at time %0t: sel=%0d got %0d expected %0d",
                   $time, t_sel[1:0], t_dout_def, exp_dout);
          errors = errors + 1;
        end
      end
    end

    $write("SUMMARY: %0d of %0d checks passed", total - errors, total);
    if (errors == 0) $write(" -- ALL PASS");
    $write("\n");
    $finish;
  end

endmodule
