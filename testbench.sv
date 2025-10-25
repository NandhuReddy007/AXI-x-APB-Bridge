
`include "interface.sv"
`include "test.sv"
`include "uvm_macros.svh"
//`include "package.sv"


module top;
  import uvm_pkg::*;
 // import tb_pkg::*;
  
  
  bit clk, rst;
  intf_bridge intf(clk, rst);
  
  axi_apb_bridge dut(.clk(clk), .rst(rst),
  .axi_awid(intf.axi_awid),
  .axi_awaddr(intf.axi_awaddr),
  .axi_awlen(intf.axi_awlen),
  .axi_awsize(intf.axi_awsize),
  .axi_awburst(intf.axi_awburst),
  .axi_awvalid(intf.axi_awvalid),
  .axi_awready(intf.axi_awready) ,

  .axi_wdata(intf.axi_wdata),
  .axi_wstrb(intf.axi_wstrb),
  .axi_wlast(intf.axi_wlast),
  .axi_wvalid(intf.axi_wvalid),
  .axi_wready(intf.axi_wready),

  .axi_bid(intf.axi_bid),
  .axi_bresp(intf.axi_bresp),
  .axi_bvalid(intf.axi_bvalid),
  .axi_bready(intf.axi_bready),

  .axi_arid(intf.axi_arid),
  .axi_araddr(intf.axi_araddr),
  .axi_arlen(intf.axi_arlen),
  .axi_arsize(intf.axi_arsize),
  .axi_arburst(intf.axi_arburst),
  .axi_arvalid(intf.axi_arvalid),
  .axi_arready(intf.axi_arready),

  .axi_rdata(intf.axi_rdata),
  .axi_rid(intf.axi_rid),
  .axi_rlast(intf.axi_rlast),
  .axi_rvalid(intf.axi_rvalid),
  .axi_rready(intf.axi_rready),
  .axi_rresp(intf.axi_rresp),

  .paddr(intf.paddr),
  .pwrite(intf.pwrite),
  .pwdata(intf.pwdata),
  .psel(intf.psel),
  .penable(intf.penable),
  .prdata(intf.prdata),
  .pstrb(intf.pstrb),
  .pready(intf.pready),
  .pslverr(intf.pslverr));


  always #5 clk = ~ clk;

  initial begin
    
    clk = 0;
    rst = 0;
    #15
    rst = 1;
    
    

    // #1000
     //$finish;
  end
  
  initial begin
      $dumpfile("dump.vcd"); 
    $dumpvars(0,top); 
  end

endmodule

