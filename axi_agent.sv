`ifndef AXI_AGENT_SV
  `define AXI_AGENT_SV

  `include "packet.sv"
  `include "axi_driver.sv"
  `include "axi_monitor.sv"

  typedef uvm_sequencer#(packet) packet_sequencer;

  class axi_agent extends uvm_agent;
    virtual intf_bridge intf;
    packet_sequencer seqr;
    axi_driver drv;
    axi_monitor mon;
    uvm_analysis_port #(packet) analysis_port;
    uvm_analysis_port #(packet) len_mon;

    `uvm_component_utils(axi_agent)

    function new(string name, uvm_component parent);
      super.new(name, parent);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase) ;

       if(!uvm_config_db#(virtual intf_bridge)::get(this,"","intf",intf))
        `uvm_fatal("NO VIF","INTF NOT FOUND")


      seqr = packet_sequencer :: type_id :: create ("seqr", this) ;
      drv = axi_driver::type_id::create("drv", this);
      mon = axi_monitor::type_id::create ("mon", this) ;

      /*uvm_config_db#(virtual intf_bridge) :: set(this,"seqr","intf_bridge",intf);
      uvm_config_db#(virtual intf_bridge) :: set(this,"drv","intf_bridge",intf);
      uvm_config_db#(virtual intf_bridge) :: set(this,"mon","intf_bridge",intf);*/

    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase) ;

      drv.seq_item_port.connect(seqr.seq_item_export);
      this.analysis_port = mon.analysis_port;
      this.len_mon = mon.len_mon;
    endfunction

     virtual function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);
    endfunction

  endclass

`endif
