class router_tb extends uvm_env;

    yapp_env YAPP;
    channel_env chan0;
    channel_env chan1;
    channel_env chan2;
    hbus_env hbus;
    clock_and_reset_env clk_rst;

    router_mcsequencer mcsequencer;

    // scoreboard
    // router_scoreboard scb;
    router_module_env rt_env;

    yapp_router_regs_vendor_Cadence_Design_Systems_library_Yapp_Registers_version_1_5  yapp_rm;
    hbus_reg_adapter    reg2hbus;

    `uvm_component_utils_begin(router_tb)
    `uvm_field_object(yapp_rm, UVM_ALL_ON)
    `uvm_component_utils_end

    function new(string name = "router_tb", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // YAPP = new("YAPP", this);
        uvm_config_int::set(this, "chan0", "channel_id", 0);
        uvm_config_int::set(this, "chan1", "channel_id", 1);
        uvm_config_int::set(this, "chan2", "channel_id", 2);
        uvm_config_int::set(this, "hbus", "num_masters", 1);
        uvm_config_int::set(this, "hbus", "num_slaves", 0);

        YAPP = yapp_env::type_id::create("YAPP", this);
        chan0 = channel_env::type_id::create("chan0", this);
        chan1 = channel_env::type_id::create("chan1", this);
        chan2 = channel_env::type_id::create("chan2", this);
        hbus = hbus_env::type_id::create("hbus", this);
        clk_rst = clock_and_reset_env::type_id::create("clk_rst", this);

        mcsequencer = router_mcsequencer::type_id::create("mcsequencer", this);

        // scb = router_scoreboard::type_id::create("scb", this);
        rt_env = router_module_env::type_id::create("rt_env", this);

        // register model integration
        yapp_rm = yapp_router_regs_vendor_Cadence_Design_Systems_library_Yapp_Registers_version_1_5::type_id::create("yapp_rm", this);
        yapp_rm.build();
        yapp_rm.lock_model();
        yapp_rm.set_hdl_path_root("hw_top.dut");
        // set the suto predict ON
        yapp_rm.default_map.set_auto_predict(1);

        reg2hbus = hbus_reg_adapter::type_id::create("reg2hbus", this);

        `uvm_info("BUILD_PHASE", "Build phase of the testbench is being executed", UVM_HIGH)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mcsequencer.hbus_seqr = hbus.masters[0].sequencer;
        mcsequencer.yapp_seqr = YAPP.agent.sequencer;
        
        chan0.rx_agent.monitor.item_collected_port.connect(rt_env.chan0_pkt_in);
        chan1.rx_agent.monitor.item_collected_port.connect(rt_env.chan1_pkt_in);
        chan2.rx_agent.monitor.item_collected_port.connect(rt_env.chan2_pkt_in);

        YAPP.agent.monitor.yapp_out.connect(rt_env.ypkt_in);
        hbus.masters[0].monitor.item_collected_port.connect(rt_env.hbus_pkt_in);

        yapp_rm.default_map.set_sequencer(hbus.masters[0].sequencer, reg2hbus);
    endfunction


    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation...", UVM_HIGH)
    endfunction

endclass