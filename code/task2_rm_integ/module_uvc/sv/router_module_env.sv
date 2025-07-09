class router_module_env extends uvm_env;

    `uvm_component_utils(router_module_env)

    router_scoreboard rt_scb;
    router_reference rt_reference;

    uvm_analysis_export #(yapp_packet) ypkt_in;
    uvm_analysis_export #(channel_packet) chan0_pkt_in;
    uvm_analysis_export #(channel_packet) chan1_pkt_in;
    uvm_analysis_export #(channel_packet) chan2_pkt_in;
    uvm_analysis_export #(hbus_transaction) hbus_pkt_in;

    function new(string name = "router_module_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rt_scb = router_scoreboard::type_id::create("rt_scb", this);
        rt_reference = router_reference::type_id::create("rt_reference", this);
        ypkt_in = new("ypkt_in", this);
        chan0_pkt_in = new("chan0_pkt_in", this);
        chan1_pkt_in = new("chan1_pkt_in", this);
        chan2_pkt_in = new("chan2_pkt_in", this);
        hbus_pkt_in = new("hbus_pkt_in", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // rt_reference.yapp_out.connect(rt_scb.yapp_in);
        ypkt_in.connect(rt_scb.yapp_fifo.analysis_export);
        chan0_pkt_in.connect(rt_scb.chan0_fifo.analysis_export);
        chan1_pkt_in.connect(rt_scb.chan1_fifo.analysis_export);
        chan2_pkt_in.connect(rt_scb.chan2_fifo.analysis_export);
        hbus_pkt_in.connect(rt_scb.hbus_fifo.analysis_export);
    endfunction

endclass