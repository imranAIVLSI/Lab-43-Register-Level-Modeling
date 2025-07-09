class router_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(router_scoreboard)

    uvm_tlm_analysis_fifo #(yapp_packet) yapp_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chan0_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chan1_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chan2_fifo;
    uvm_tlm_analysis_fifo #(hbus_transaction) hbus_fifo;

    uvm_get_port#(yapp_packet) yapp_get;
    uvm_get_port#(channel_packet) chan0_get;
    uvm_get_port#(channel_packet) chan1_get;
    uvm_get_port#(channel_packet) chan2_get;
    uvm_get_port#(hbus_transaction) hbus_get;

    //packet counters
    int pkts_received = 0;
    int wrong_pkts = 0;
    int matched_pkts = 0;
    int dropped_pkts = 0;

    int rt_en;
    int maxpktsize;

    function new(string name = "router_scoreboard", uvm_component parent);
        super.new(name, parent);
        //implementation ports construction
        yapp_fifo  = new("yapp_fifo", this);
        chan0_fifo = new("chan0_fifo", this);
        chan1_fifo = new("chan1_fifo", this);
        chan2_fifo = new("chan2_fifo", this);
        hbus_fifo = new("hbus_fifo", this);

        yapp_get = new("yapp_get", this);
        chan0_get = new("chan0_get", this);
        chan1_get = new("chan1_get", this);
        chan2_get = new("chan2_get", this);
        hbus_get = new("hbus_get", this);

    endfunction

//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  Connect Phase  * * * * * * * * * * * * * * * *  * * * *  * * * *  *   *  * * * *  //
//========================================================================================================================//

    function void connect_phase(uvm_phase phase);
        yapp_get.connect(yapp_fifo.get_peek_export);
        chan0_get.connect(chan0_fifo.get_peek_export);
        chan1_get.connect(chan1_fifo.get_peek_export);
        chan2_get.connect(chan2_fifo.get_peek_export);
        hbus_get.connect(hbus_fifo.get_peek_export);

    endfunction

//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  Connect Phase  * * * * * * * * * * * * * * * *  * * * *  * * * *  *   *  * * * *  //
//========================================================================================================================//

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if(yapp_fifo.used() != 0) begin
            `uvm_error(get_type_name(), $sformatf("YAPP FIFO not empty, packets left: %0d", yapp_fifo.used()))
        end
        if(hbus_fifo.used() != 0) begin
            `uvm_error(get_type_name(), $sformatf("HBUS FIFO not empty, packets left: %0d", hbus_fifo.used()))
        end
        if(chan0_fifo.used() != 0) begin
            `uvm_error(get_type_name(), $sformatf("Channel_0 FIFO not empty, packets left: %0d", chan0_fifo.used()))
        end
        if(chan1_fifo.used() != 0) begin
            `uvm_error(get_type_name(), $sformatf("Channel_1 FIFO not empty, packets left: %0d", chan1_fifo.used()))
        end
        if(chan2_fifo.used() != 0) begin
            `uvm_error(get_type_name(), $sformatf("Channel_2 FIFO not empty, packets left: %0d", chan2_fifo.used()))
        end
    endfunction

//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  Run Phase  * * * * * * * * * * * * * * * *  * * * *  * * * *  *   *  * * * *  * * //
//========================================================================================================================//

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        fork
            yapp_t();
            hbus_t();
        join_none

    endtask

//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  YAPP Task  * * * * * * * * * * * * * * * *  * * * *  * * * *  *   *  * * * *  * * //
//========================================================================================================================//
    task yapp_t();
        forever begin
            yapp_packet ypkt;
            channel_packet cpkt;
            yapp_get.get(ypkt);
            if(!rt_en || (ypkt.length > 63 || ypkt.addr > 2)) begin
                dropped_pkts++;
            end
            if(rt_en || (ypkt.length < 63 || ypkt.addr <= 2))begin
                pkts_received++;
                case(ypkt.addr)
                2'b00 : chan0_get.get(cpkt);
                2'b01 : chan1_get.get(cpkt);
                2'b10 : chan2_get.get(cpkt);
                endcase
                if(comp_equal(ypkt, cpkt)) begin
                    `uvm_error(get_type_name, "Packet Matched")
                    matched_pkts++;
                end
                else begin
                    `uvm_error(get_type_name, "Packet Not Matched")
                    wrong_pkts++;
                end
            end
        end

    endtask

//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  HBUS task  * * * * * * * * * * * * * * * *  * * * *  * * * *  *   *  * * * *  * * //
//========================================================================================================================//

    task hbus_t();
        hbus_transaction hpkt;
        forever begin
            hbus_get.get(hpkt);
            if(hpkt.hwr_rd == HBUS_WRITE) begin
                if(hpkt.haddr == 16'h1000)
                    maxpktsize = hpkt.hdata;
                else if(hpkt.haddr)
                    rt_en =  hpkt.hdata;
                else
                `uvm_info(get_type_name(), $sformatf("HBUS write to addr: %0h, data: %0h", hpkt.haddr, hpkt.hdata), UVM_LOW)
            end
        end
    endtask

//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  YAPP write implementation  * * * * * * * * * * * * * * * *  * * * *  * * * *  *   //
//========================================================================================================================//
    // function void write_yapp(yapp_packet packet);
    //     yapp_packet ypkt;
    //     $cast(ypkt, packet.clone());
    //     case(ypkt.addr)
    //         2'b00 : q0.push_back(ypkt);
    //         2'b01 : q1.push_back(ypkt);
    //         2'b10 : q2.push_back(ypkt);
    //     endcase
    // endfunction
//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  Channel-0 write implementation  * * * * * * * * * * * * * * * *  * * * *  * * *   //
//========================================================================================================================//
    // function void write_channel0(channel_packet packet);
    //     yapp_packet ypkt;
    //     if(q0.size()>0) begin 
    //     ypkt = q0.pop_front();
    //     end
    //     pkts_received++;
    //     if(comp_equal(ypkt, packet)) begin // given comapre function
    //     // if(ccomp(ypkt, packet)) begin  // uvm_compare function
    //         `uvm_info(get_type_name(), "Inside IF BLOCK of Q1", UVM_LOW)
    //         matched_pkts++;
    //     end
    //     else begin
    //         wrong_pkts++;
    //     end 
        

    // endfunction
//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  Channel-1 write implementation  * * * * * * * * * * * * * * * *  * * * *  * * *   //
//========================================================================================================================//
    // function void write_channel1(channel_packet packet);
    //     yapp_packet ypkt;
    //     if(q1.size()>0) begin 
    //     ypkt = q1.pop_front();
    //     end 
    //     pkts_received++;
    //     if(comp_equal(ypkt, packet)) begin
    //     // if(ccomp(ypkt, packet)) begin
    //         `uvm_info(get_type_name(), "Inside IF BLOCK of Q1", UVM_LOW)
    //         matched_pkts++;
    //     end
    //     else begin
    //         `uvm_info(get_type_name(), "Inside ELSE BLOCK of Q1", UVM_LOW)
    //         wrong_pkts++;
    //     end

    // endfunction
//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  Channel-2 write implementation  * * * * * * * * * * * * * * * *  * * * *  * * *   //
//========================================================================================================================//
    // function void write_channel2(channel_packet packet);
    //     yapp_packet ypkt;
    //     if(q2.size()>0) begin 
    //     ypkt = q2.pop_front();
    //     end
    //     pkts_received++;
    //     if(comp_equal(ypkt, packet)) begin
    //     // if(ccomp(ypkt, packet)) begin
    //         matched_pkts++;
    //     end
    //     else begin
    //         wrong_pkts++;
    //     end
    // endfunction
//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  Custom_Compare Method  * * * * * * * * * * * * * * * *  * * * *  * * * *  * * * * //
//========================================================================================================================//
    function bit comp_equal (input yapp_packet yp, input channel_packet cp);
      // returns first mismatch only
      if (yp.addr != cp.addr) begin
        `uvm_error("PKT_COMPARE",$sformatf("Address mismatch YAPP %0d Chan %0d",yp.addr,cp.addr))
        return(0);
      end
      if (yp.length != cp.length) begin
        `uvm_error("PKT_COMPARE",$sformatf("Length mismatch YAPP %0d Chan %0d",yp.length,cp.length))
        return(0);
      end
      foreach (yp.payload [i])
        if (yp.payload[i] != cp.payload[i]) begin
          `uvm_error("PKT_COMPARE",$sformatf("Payload[%0d] mismatch YAPP %0d Chan %0d",i,yp.payload[i],cp.payload[i]))
          return(0);
        end
      if (yp.parity != cp.parity) begin
        `uvm_error("PKT_COMPARE",$sformatf("Parity mismatch YAPP %0d Chan %0d",yp.parity,cp.parity))
        return(0);
      end
      return(1);
   endfunction


//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  UVM_Compare Method  * * * * * * * * * * * * * * * *  * * * *  * * * *  * * * *    //
//========================================================================================================================//

    function bit ccomp(yapp_packet yp, channel_packet cp, uvm_comparer comparer = null);
      if(comparer == null)
        comparer = new();
        ccomp = comparer.compare_field("addr", yp.addr, cp.addr, 2);
        ccomp &= comparer.compare_field("length", yp.length, cp.length, 6);
        ccomp &= comparer.compare_field("parity", yp.parity, cp.parity, 8);

        foreach(yp.payload[i])
          ccomp &= comparer.compare_field("payload", yp.payload[i], cp.payload[i], 8);

        return ccomp;

    endfunction
//========================================================================================================================//
//  * * * * * * * * * * * * * * * *  *  Report Phase Method  * * * * * * * * * * * * * * * *  * * * *  * * * *  * * * *    //
//========================================================================================================================//
    function void report_phase(uvm_phase phase);
        `uvm_info("[Scoreboard]", $sformatf("Packets Received: %0d", pkts_received), UVM_HIGH)
        `uvm_info("[Scoreboard]", $sformatf("Wrong Packets: %0d", wrong_pkts), UVM_HIGH)
        `uvm_info("[Scoreboard]", $sformatf("Matched Packets: %0d", matched_pkts), UVM_HIGH)
        `uvm_info("[Scoreboard]", $sformatf("Dropped Packets: %0d", dropped_pkts), UVM_HIGH)
        // `uvm_info("[Scoreboard]", $sformatf("Packets Left: %0d", ((q0.size())+(q1.size())+(q2.size()))), UVM_HIGH)

    endfunction

endclass