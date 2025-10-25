`ifndef AXI_SEQUENCE
  `define AXI_SEQUENCE

//  `include "packet.sv"

  class axi_sequence extends uvm_sequence #(packet);

    `uvm_object_utils(axi_sequence)
    
    function new(string name = "axi_sequence");
      super.new(name);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
    endfunction

    task body();

      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);

      if(starting_phase != null)begin
        uvm_objection objection = starting_phase.get_objection();
        starting_phase. raise_objection(this);
      end

      forever begin
      `uvm_do(req) ;
      //`uvm_info("AXI_SEQUENCE", $sformatf("\n %p \n",req), UVM_LOW);
      end
      
      if(starting_phase != null) begin
        starting_phase.drop_objection(this);
      end

    endtask

  endclass

`endif
