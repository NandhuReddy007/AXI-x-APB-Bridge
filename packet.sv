`ifndef PACKET_SV
  `define PACKET_SV


   class packet extends uvm_sequence_item;
    `uvm_object_utils(packet);
    
    rand bit [31:0] axi_awaddr;
    rand bit [7:0] axi_awlen;
    rand bit [2:0] axi_awsize;
    rand bit [1:0] axi_awburst;
    rand bit [31:0] axi_awid;

    rand bit [31:0] axi_wdata[];
    rand bit [3:0] axi_wstrb;

    rand bit [1:0] axi_bresp;
    rand bit [31:0] axi_bid;

    rand bit [31:0] axi_araddr;
    rand bit [31:0] axi_arid;
    rand bit [7:0] axi_arlen;
    rand bit [2:0] axi_arsize;
    bit[31:0] axi_rid;

    bit [31:0] axi_rdata[];

    rand bit read_write_mode;
    
    function new(string name = "packet");
      super.new(name);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;
    endfunction

    constraint cl { axi_bresp == 0; }
    constraint c2 { axi_awburst == 1; }
    constraint c3 { axi_awlen inside {[2:3]}; axi_arlen inside { [2:3]}; }
    constraint c4 { axi_wdata.size() == axi_awlen+1; }
    constraint c5 { axi_awsize == 2; axi_arsize == 2; }
    constraint c6 { axi_wstrb dist { 4'b1111 := 50, 4'b0111 := 30 , 4'b0011 := 20 }; }
    constraint c7 { read_write_mode dist { 1'b1 := 50, 1'b0 := 50};}

    
  endclass
`endif
