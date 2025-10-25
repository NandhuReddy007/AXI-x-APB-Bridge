`ifndef APB_AGENT_SV
  `define APB_AGENT_SV

  `include "transaction.sv"
  `include "apb_monitor.sv"
  `include "apb_driver.sv"

  typedef uvm_sequencer #(apb_packet) packet_apb_sequencer;

  class apb_agent extends uvm_agent;
    virtual intf_bridge intf;
    packet_apb_sequencer seqr;
    apb_driver drv;
    apb_monitor mon;
    uvm_analysis_port #(apb_packet) analysis_port;

    `uvm_component_utils(apb_agent)

    function new(string name, uvm_component parent);
      super.new(name, parent) ;
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual intf_bridge)::get(this,"","intf",intf))
        `uvm_fatal("NO VIF","INTF NOT FOUND")

      seqr = packet_apb_sequencer:: type_id::create ("seqr", this);
      drv = apb_driver::type_id::create ("drv", this);
      mon = apb_monitor::type_id:: create ("mon", this) ;


    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase) ;
      drv.seq_item_port.connect(seqr.seq_item_export);
      this.analysis_port = mon.analysis_port;
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);
    endfunction
    
  endclass
`endif
