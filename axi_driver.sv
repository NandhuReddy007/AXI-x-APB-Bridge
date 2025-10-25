`ifndef AXI_DRIVER
  `define AXI_DRIVER

 // `include "packet.sv"

  class axi_driver extends uvm_driver #(packet);

    virtual intf_bridge intf;
    packet pkt_queue[$] ;
    packet pkt_queue_write[$] ;
    int no_txn ;

    `uvm_component_utils(axi_driver)

    function new(string name, uvm_component parent) ;
      super.new(name, parent) ;
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);

      if(!uvm_config_db#(virtual intf_bridge)::get(this,"","intf",intf))
        `uvm_fatal("NO VIF","INTF NOT FOUND")

        if(!uvm_config_db#(int)::get(this,"", "no_txn", no_txn))
          `uvm_fatal("NO transaction","TRANSACTION NOT FOUND")

    endfunction

    virtual task run_phase(uvm_phase phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);
      if(phase != null)begin
        uvm_objection objection = phase.get_objection();
        phase. raise_objection (this);
      end
      repeat(no_txn) begin
        seq_item_port.get_next_item(req);
       // `uvm_info("TRANSACTIONS", $sformatf("\n %p \n",req), UVM_LOW) ;
        pkt_queue.push_back(req) ;
        if(req. read_write_mode == 1)begin
          pkt_queue_write.push_back(req);
        end
        seq_item_port.item_done();
        end
      
      fork

    begin
      while(pkt_queue.size()>0)begin
        if(pkt_queue[0].read_write_mode == 1)begin
          send_write_addr(0);
          pkt_queue.pop_front();
          intf.axi.axi_awvalid =0;
        end
        else begin
          intf.axi.axi_rready = 1;
          send_read_addr(0);
          pkt_queue.pop_front();
          intf.axi.axi_arvalid =0;
        end
      end
    end

    begin
      while(pkt_queue_write.size() > 0)begin
        if(pkt_queue_write[0].read_write_mode == 1)begin
          send_data();
          pkt_queue_write.pop_front();
        end
        else begin
          @(posedge intf.clk);
        end
      end
        intf.axi.axi_wvalid=0;
    end

    join_none

    if(phase != null)begin
      phase.drop_objection(this);
    end

    endtask
    
    
    task send_write_addr(int count_addr);
      wait(intf.axi.axi_awready && intf.rst);
      intf.axi.axi_bready = 1;
      intf.axi.axi_awaddr = pkt_queue[count_addr].axi_awaddr;
      intf.axi.axi_awlen = pkt_queue[count_addr].axi_awlen;
      intf.axi.axi_awsize = pkt_queue[count_addr].axi_awsize;
      intf.axi.axi_awid = pkt_queue[count_addr].axi_awid;
      intf.axi.axi_awvalid =1;
      @(posedge intf.clk);
    endtask

    task send_read_addr(int count_addr);
      // uvm_info(" READ FUNCTION BEFORE WAIT", $sformatf(" \n"), UVM_LOW);
      wait(intf.axi.axi_arready && intf.rst);
      // `uvm info("READ FUNCTION AFTER WAIT", $sformatf(" \n"), UVM_LOW);
        intf.axi.axi_araddr = pkt_queue[count_addr].axi_araddr;
        intf.axi.axi_arlen = pkt_queue[count_addr].axi_arlen;
        intf.axi.axi_arsize = pkt_queue[count_addr].axi_arsize;
        intf.axi.axi_arid = pkt_queue[count_addr].axi_arid;
        intf.axi.axi_arvalid =1;
        @(posedge intf.clk);

    endtask

    task send_data();
      for(int i=0;i <= pkt_queue_write[0].axi_awlen;i++)begin
      wait(intf.axi.axi_wready && intf.rst);
        intf.axi.axi_wdata = pkt_queue_write[0].axi_wdata[i];
        intf.axi.axi_wstrb = pkt_queue_write[0].axi_wstrb;
        intf.axi.axi_wvalid = 1;
        @(posedge intf.clk);
      end
    endtask

  endclass
`endif
