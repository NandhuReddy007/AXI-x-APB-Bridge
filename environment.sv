`ifndef ENVIRONMENT_SV
  `define ENVIRONMENT_SV

  `include "axi_agent.sv"
  `include "apb_agent.sv"
  `include "axi_sequence.sv"
  `include "apb_sequence.sv"
  `include "scoreboard.sv"

  class environment extends uvm_env;

    axi_agent axi_agnt;
    apb_agent apb_agnt;
    scoreboard sb;
    int no_txn;
    uvm_event Done;

    `uvm_component_utils(environment)

    function new(string name, uvm_component parent);
      super.new(name, parent) ;
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase (phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);

      axi_agnt = axi_agent::type_id::create("axi_agnt", this);
      uvm_config_db#(uvm_object_wrapper) :: set(this, { axi_agnt.get_name (), ".", "seqr.main_phase"}, "default_sequence", axi_sequence::get_type( ) ) ;
      uvm_config_db#(int) :: set(this,"*","no_txn", 3);

      apb_agnt = apb_agent::type_id::create("apb_agnt", this);
      uvm_config_db#(uvm_object_wrapper) :: set(this, { apb_agnt.get_name(), ".", "seqr.main_phase"}, "default_sequence", apb_sequence::get_type( ) ) ;
      sb = scoreboard::type_id::create("sb", this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase) ;
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
      axi_agnt.analysis_port.connect(sb.before_fifo.analysis_export);
      axi_agnt.len_mon. connect(sb.len_sb);
      apb_agnt.analysis_port.connect(sb.after_fifo.analysis_export);
    endfunction
    
  endclass
`endif

   
