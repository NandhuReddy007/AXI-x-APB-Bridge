`ifndef APB_MONITOR
  `define APB_MONITOR

 `include "transaction.sv"

  class apb_monitor extends uvm_monitor;
    int count=0;
    virtual intf_bridge intf;
    uvm_analysis_port #(apb_packet) analysis_port;

    `uvm_component_utils(apb_monitor)

    function new(string name, uvm_component parent);
      super.new(name, parent);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase (phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;

       if(!uvm_config_db#(virtual intf_bridge)::get(this,"","intf",intf))
        `uvm_fatal("NO VIF","INTF NOT FOUND")

      analysis_port = new("analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);

      apb_packet tr;
      //`uvm_info("TAG", $sformatf("%m"), UVM_LOW);
      forever begin
      tr = apb_packet:: type_id:: create("tr", this);
      receive_write(tr);
    end

    endtask

    task receive_write( apb_packet tr);
      
      wait(intf.apb.penable && intf.apb.psel && intf.apb.pready && intf.rst) begin
      tr.paddr = intf.apb.paddr;
        if(intf.apb.pwrite) begin
          tr.pwdata = intf.apb.pwdata;
         end
        else begin
          tr.prdata = intf.apb.prdata;
        end
      @(posedge intf.clk);

      analysis_port.write(tr);
      // `uvm_info("APB_MON", $sformatf("PKT : %p", tr), UVM_LOW);
      end

    endtask

  endclass

`endif
