`ifndef APB_DRIVER
  `define APB_DRIVER

//  `include "transaction.sv"

  class apb_driver extends uvm_driver #(apb_packet);

    virtual intf_bridge intf;
    int count=0;

    `uvm_component_utils(apb_driver)

    function new(string name, uvm_component parent);
      super.new(name, parent) ;
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
      
       if(!uvm_config_db#(virtual intf_bridge)::get(this,"","intf",intf))
        `uvm_fatal("NO VIF","INTF NOT FOUND")

    endfunction

    virtual task run_phase(uvm_phase phase);
     // `uvm_info("APB_DRV1", $sformatf("INSIDE1"), UVM_LOW);

      forever begin
        if(phase != null)begin
          uvm_objection objection = phase.get_objection();
          phase. raise_objection(this);
        end

        fork
          begin
          @(posedge intf.clk)
            if(intf.apb.penable && intf.apb.psel && intf.apb.pwrite && intf.rst) begin
             // `uvm_info("APB_DRV2", $sformatf("INSIDE 2"), UVM_LOW);
              intf.apb.pslverr = 0;
              intf.apb.pready = 1;
              @(posedge intf.clk);
              intf.apb.pready = 0;
            end
          end
          
          begin
            @(posedge intf.clk)
            if(intf.apb.penable && intf.apb.psel && !intf.apb.pwrite && intf.rst) begin

            //  `uvm_info("APB_DRV3", $sformatf("INSIDE 3"), UVM_LOW);
              intf.apb.prdata = $urandom();
              intf.apb.pslverr =0;
              intf.apb.pready = 1;
              @(posedge intf.clk);
              intf.apb.pready = 0;
              end
            end

         join_any

        end

        if(phase != null)begin
          phase.drop_objection(this);
         end

    endtask

  endclass

`endif
