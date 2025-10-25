`ifndef AXI_MONITOR
`define AXI_MONITOR

//`include "packet.sv"
  class axi_monitor extends uvm_monitor;

    virtual intf_bridge intf;
    uvm_analysis_port#(packet) analysis_port;
    uvm_analysis_port#(packet) len_mon;

    packet pkt;
    packet len;

    packet aw[$] ;
    packet ar[$];
    packet len_q[$];
    bit[31:0] w[$];
    bit[31:0] r[$];
    bit[31:0] rid[$];

    `uvm_component_utils(axi_monitor)

    function new(string name, uvm_component parent);
      super.new(name, parent) ;
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
      len_mon = new("len_mon", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);

       if(!uvm_config_db#(virtual intf_bridge)::get(this,"","intf",intf))
        `uvm_fatal("NO VIF","INTF NOT FOUND")


      analysis_port = new("analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      if(phase != null)begin
      uvm_objection objection = phase.get_objection();
      phase. raise_objection(this);
      end

      `uvm_info("TAG", $sformatf("m"), UVM_HIGH);
      pkt = packet:: type_id::create("pkt", this);
      len = packet::type_id::create ("len", this);
      forever begin
        receive();
      end
      if(phase != null)begin
        phase.drop_objection(this);
      end

    endtask

    task receive();
      @(posedge intf.clk);

      if(intf.axi.axi_awvalid && intf.axi.axi_awready && intf.rst)begin
        packet aw_pkt = packet :: type_id:: create("pkt");
        packet len_pkt = packet:: type_id::create("len", this);
        aw_pkt.axi_awaddr = intf.axi.axi_awaddr;
        aw_pkt.axi_awlen = intf.axi.axi_awlen;
        len_pkt.axi_awlen = intf.axi.axi_awlen;
        len_pkt. read_write_mode = 1;
        aw_pkt. read_write_mode = 1;

        //`uvm_info("len_mon", $sformatf("len:%d .. %d",intf.axi.axi_awlen,len_pkt.axi_awlen), UVM_LOW);
        aw_pkt.axi_awsize = intf.axi.axi_awsize;
        aw_pkt.axi_awid = intf.axi.axi_awid;
        aw.push_back(aw_pkt);
        len_q.push_back(len_pkt) ;
        // 'uvm_info("LEN_MON_w",$sformatf("%d",len_q[0].axi_awlen), UVM_LOW)
        if(len_q.size()>0 && len_pkt.read_write_mode) begin
        len_mon.write(len_q[0]);
       //   `uvm_info("LEN_MON_w", $sformatf("%d",len_q[0].axi_awlen), UVM_LOW)
        len_q.pop_front();
        end

      end

    if(intf.axi.axi_arvalid && intf.axi.axi_arready && intf.rst)begin
      packet ar_pkt = packet:: type_id:: create("pkt");
      packet len_pkt = packet:: type_id:: create("len", this);
      ar_pkt.axi_araddr = intf.axi.axi_araddr;
      ar_pkt.axi_arlen = intf.axi.axi_arlen;
      len_pkt.axi_arlen = intf.axi.axi_arlen;
      ar_pkt.axi_arsize = intf.axi.axi_arsize;
      ar_pkt.axi_arid = intf.axi.axi_arid;
      ar_pkt.read_write_mode = 0;
      len_pkt.read_write_mode = 0;
      ar.push_back(ar_pkt);
      len_q.push_back(len_pkt);
     // `uvm_info("LEN_MON_R",$sformatf("%d",len_q[0].axi_arlen), UVM_LOW)
      if(len_q.size()>0 && !len_pkt.read_write_mode) begin
        len_mon.write(len_q[0]);
        len_q.pop_front();
      end
    end
      
      if(intf.axi.axi_wvalid && intf.axi.axi_wready &&intf.rst)begin
      bit[31:0] write_data;
      write_data = intf.axi.axi_wdata;

      w.push_back(write_data);
      if((aw[0].axi_awlen)+1 == w.size())begin
      //`uvm_info("ANALYSIS PORT", $sformatf("%p",ar[0]),UVM_LOW);
        aw[0].axi_wdata = new[aw[0].axi_awlen+1];
        aw[0].axi_wstrb = intf.axi.axi_wstrb;
    for(int i=0;i <= aw[0].axi_awlen;i++)begin
      aw[0].axi_wdata[i]=w[0];
      w.pop_front();
    end
    analysis_port.write(aw[0]);
   // `uvm_info("ANALYSIS PORT", $sformatf("%p",aw[0]),UVM_LOW);
    aw.pop_front();
      end
    end
      
      
    if(intf.axi.axi_rvalid && intf.axi.axi_rready && intf.rst)begin
      bit[31:0] read_data;
      fork
        begin
        @(posedge intf.clk);
        read_data = intf.axi.axi_rdata;
          ar[0].axi_rid = intf.axi.axi_rid;
        r.push_back(read_data);
          if((ar[0].axi_arlen)+1 == r.size())begin
        //`uvm info("ANALYSIS PORT first push to analysis", $sformatf("%p",r),UVM_LOW);
          ar[0].axi_rdata = new[ar[0].axi_arlen+1];
          for(int i=0;i <= ar[0].axi_arlen;i++)begin
            ar[0].axi_rdata[i]=r[0];
            r.pop_front();
          end
          analysis_port.write(ar[0]);
          `uvm_info("ANALYSIS PORT", $sformatf("%p",ar[0]), UVM_LOW);
          ar.pop_front();
        end

      end
     join_none
   end

  endtask

  endclass

`endif
