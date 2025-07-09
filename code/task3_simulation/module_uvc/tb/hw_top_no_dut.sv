/*-----------------------------------------------------------------
File name     : hw_top.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : lab06_vif hardware top module for acceleration
              : Instantiates clock generator and YAPP interface only for testing - no DUT
Notes         : From the Cadence "SystemVerilog Accelerated Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

module hw_top;

  // Clock and reset signals
  logic [31:0]  clock_period;
  logic         run_clock;
  logic         clock;
  logic         reset;

  clock_and_reset_if clk_rst_if(
      .clock(clock),
      .reset(reset),
      .run_clock(run_clock),
      .clock_period(clock_period)
  );

  hbus_if hbus_if_inst(
      .clock(clock),
      .reset(reset)
  );

  channel_if chan_if0(
      .clock(clock),
      .reset(reset)
  );

  channel_if chan_if1(
      .clock(clock),
      .reset(reset)
  );

  channel_if chan_if2(
      .clock(clock),
      .reset(reset)
  );

  // YAPP Interface to the DUT
  yapp_if in0(clock, reset);

  // CLKGEN module generates clock
  clkgen clkgen (
    .clock(clock),
    .run_clock(run_clock),
    .clock_period(clock_period)
  );


  yapp_router dut(
    .reset(clk_rst_if.reset),
    .clock(clk_rst_if.clock),
    .error(),

    // YAPP interface
    .in_data(in0.in_data),
    .in_data_vld(in0.in_data_vld),
    .in_suspend(in0.in_suspend),

    // Output Channels
    //Channel 0
    .data_0(chan_if0.data),
    .data_vld_0(chan_if0.data_vld),
    .suspend_0(chan_if0.suspend),
    //Channel 1
    .data_1(chan_if1.data),
    .data_vld_1(chan_if1.data_vld),
    .suspend_1(chan_if1.suspend),
    //Channel 2
    .data_2(chan_if2.data),
    .data_vld_2(chan_if2.data_vld),
    .suspend_2(chan_if2.suspend),

    // HBUS Interface 
    .haddr(hbus_if_inst.haddr),
    .hdata(hbus_if_inst.hdata_w),
    .hen(hbus_if_inst.hen),
    .hwr_rd(hbus_if_inst.hwr_rd)
    );


endmodule
