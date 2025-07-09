package router_module;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import clock_and_reset_pkg::*;
    import yapp_pkg::*;
    import channel_pkg::*;
    import hbus_pkg::*;

    `include "router_scoreboard.sv"
    `include "router_reference.sv"
    `include "router_module_env.sv"

endpackage