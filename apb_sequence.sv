`ifndef APB_SEQUENCE
  `define APB_SEQUENCE

 // `include "transaction. sv"
  class apb_sequence extends uvm_sequence #(apb_packet);

    `uvm_object_utils(apb_sequence)
    
    function new(string name = "apb_sequence");
      super.new(name);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
    endfunction

    task body();
      
      forever begin
        if(starting_phase != null)begin
          uvm_objection objection = starting_phase.get_objection();
          starting_phase.raise_objection(this);
        end
        `uvm_do(req) ;
        // 'uvm_info("APB_SEQUENCE", $sformatf("\n %p \n",req), UVM_LOW)
        if(starting_phase != null) begin
          starting_phase.drop_objection(this);
        end
      end

    endtask

  endclass
`endif
