`ifndef APB_PACKET
  `define APB_PACKET

  class apb_packet extends uvm_sequence_item;
    bit [31:0] paddr;
    bit pwrite;
    bit[31:0] pwdata;
    rand bit [31:0]prdata;
    bit pslverr;
    bit [3:0] pstrb;

    `uvm_object_utils(apb_packet)

    function new(string name = "apb_packet");
      super.new(name) ;
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);
    endfunction
  endclass

`endif
