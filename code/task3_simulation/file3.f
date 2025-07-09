// 64 bit option for AWS labs
-64

-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d
-timescale 1ns/1ns
// include directories
//*** add incdir include directories here
// -uvmhome $UVMHOME

-incdir .
-incdir ./YAPP/sv
-incdir ./channel/sv
-incdir ./clock_and_reset/sv
-incdir ./hbus/sv
// -incdir ./tb
// -incdir ./task1_mcseq/tb
-incdir ./module_uvc/sv
-incdir ./module_uvc/tb
// compile files

./YAPP/sv/yapp_pkg.sv
./channel/sv/channel_pkg.sv
./clock_and_reset/sv/clock_and_reset_pkg.sv
./hbus/sv/hbus_pkg.sv

// ../sv/yapp_packet.sv
./channel/sv/channel_if.sv
./YAPP/sv/yapp_if.sv
./clock_and_reset/sv/clock_and_reset_if.sv
./hbus/sv/hbus_if.sv

./module_uvc/tb/clkgen.sv
./router_rtl/yapp_router.sv
./module_uvc/tb/hw_top_no_dut.sv
./module_uvc/sv/router_module.sv
./module_uvc/tb/cdns_uvmreg_utils_pkg.sv
./module_uvc/tb/yapp_router_regs_rdb.sv
./module_uvc/tb/tb_top.sv
+UVM_TESTNAME=reg_access_test
+UVM_VERBOSITY=UVM_HIGH
+SVSEED=random
//*** add compile files here

