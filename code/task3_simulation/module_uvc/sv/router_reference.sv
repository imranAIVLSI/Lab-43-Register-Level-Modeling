class router_reference extends uvm_component;
    `uvm_component_utils(router_reference)

    uvm_analysis_port #(yapp_packet) yapp_out;


    `uvm_analysis_imp_decl(_yapp)
    `uvm_analysis_imp_decl(_hbus)

    uvm_analysis_imp_yapp#(yapp_packet, router_reference) yapp_in;
    uvm_analysis_imp_hbus#(hbus_transaction, router_reference) hbuss_in;

    function new(string name = "router_reference", uvm_component parent);
        super.new(name, parent);
        yapp_out = new("yapp_out", this);
        yapp_in = new("yapp_in", this);
        hbuss_in = new("hbuss_in", this);
    endfunction

    bit [7:0]max_pktsize;
    bit rt_en;

    int size_invalid_pkts;
    int en_invalid_pkts;
    int addr_invalid_pkts;

    function void write_hbus(hbus_transaction ht);
        hbus_transaction hbus_pkt;
        $cast(hbus_pkt, ht.clone());
        if(hbus_pkt.haddr == 16'h1000)
            max_pktsize = hbus_pkt.hdata;

        // rt_en = (hbus_pkt.hwr_rd == 16'h1001)? 1 : 0;
        if(hbus_pkt.haddr == 16'h1001)
            rt_en = hbus_pkt.hdata[0];
    endfunction

    function void write_yapp(yapp_packet ypkt);
        yapp_packet yp;
        $cast(yp, ypkt.clone());
        if(yp == null) begin
        `uvm_error("WRITE_YAPP", "Cloning yapp_packet failed")
      
    end
        if(rt_en && yp.length <= max_pktsize && yp.addr <= 2)
            yapp_out.write(yp);
        else if(!rt_en)
            en_invalid_pkts++;
        else if(yp.length > max_pktsize)
            size_invalid_pkts++;
        else if(yp.addr > 2)
            addr_invalid_pkts++;

    endfunction

endclass