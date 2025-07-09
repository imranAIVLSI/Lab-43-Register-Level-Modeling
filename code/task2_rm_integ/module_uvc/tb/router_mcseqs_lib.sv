class router_simple_mcseq extends uvm_sequence;
    `uvm_object_utils(router_simple_mcseq)

    `uvm_declare_p_sequencer(router_mcsequencer)

    function new(string name = "router_simple_mcseq");
        super.new(name);
    endfunction

    hbus_small_packet_seq h_small;
    hbus_read_max_pkt_seq maxpkt_reg;
    yapp_012_seq six_012_seq;
    hbus_set_default_regs_seq lrg_payload;
    six_yapp_seq rand_6_seq;


      task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

    virtual task body();
       

        `uvm_do_on(h_small, p_sequencer.hbus_seqr)
        `uvm_do_on(maxpkt_reg, p_sequencer.hbus_seqr)
        repeat(2) 
        begin
            `uvm_do_on(six_012_seq, p_sequencer.yapp_seqr)
        end
        `uvm_do_on(lrg_payload, p_sequencer.hbus_seqr)
        `uvm_do_on(maxpkt_reg, p_sequencer.hbus_seqr)
        `uvm_do_on(rand_6_seq, p_sequencer.yapp_seqr)

    endtask

endclass : router_simple_mcseq
