module tb_top;
// import the UVM library
// include the UVM macros
import uvm_pkg::*;
`include "uvm_macros.svh"
// import the YAPP package
import yapp_pkg::*;
import channel_pkg::*;
import clock_and_reset_pkg::*;
import hbus_pkg::*;
import router_module::*;

`include "router_mcsequencer.sv"
`include "router_mcseqs_lib.sv"
// `include "router_scoreboard.sv"
import yapp_router_reg_pkg::*;
`include "router_tb.sv"
`include "router_test_lib.sv"
// generate 5 random packets and use the print method
// to display the results

initial begin
   yapp_vif_config::set(null, "uvm_test_top.tb.YAPP.*", "vif", hw_top.in0);
   channel_vif_config::set(null, "uvm_test_top.tb.chan0.*", "vif", hw_top.chan_if0);
   channel_vif_config::set(null, "uvm_test_top.tb.chan1.*", "vif", hw_top.chan_if1);
   channel_vif_config::set(null, "uvm_test_top.tb.chan2.*", "vif", hw_top.chan_if2); 
   hbus_vif_config::set(null, "uvm_test_top.tb.hbus.*", "vif", hw_top.hbus_if_inst);
   clock_and_reset_vif_config::set(null, "uvm_test_top.tb.clk_rst.*", "vif", hw_top.clk_rst_if);
   run_test();
   end
// experiment with the copy, clone and compare UVM method
endmodule : tb_top
