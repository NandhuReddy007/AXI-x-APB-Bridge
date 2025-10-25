`ifndef TEST_COLLECTION_SV
  `define TEST_COLLECTION_SV

  `include "environment.sv"

  class test_base extends uvm_test;

    `uvm_component_utils(test_base)

    environment env;
    uvm_event Done;

    function new(string name, uvm_component parent) ;
      super.new(name, parent);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
      env = environment :: type_id::create ("env", this) ;
  
      uvm_config_db#(virtual intf_bridge)::set(this,"env.*", "intf", top.intf);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
      uvm_top.print_topology();
      if(!uvm_config_db#(uvm_event)::get(this,"","Done",Done))
      `uvm_fatal("EVENT NOT FOUND", "EVENT NOT ACCESSED") ;
    endfunction

    task run_phase(uvm_phase phase) ;
      if(phase != null) begin
        uvm_objection objection = phase.get_objection();
        phase. raise_objection (this);
      end

      Done.wait_trigger();
      $display("EVENT TRIGGERED");
      $finish();

      if(phase != null)begin
        phase.drop_objection(this);
      end
      
    endtask
    
  endclass

`endif
