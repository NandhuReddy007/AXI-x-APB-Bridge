interface intf_bridge#(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32, ID_WIDTH = 32) (input bit clk, rst);

  logic [ID_WIDTH-1:0] axi_awid;
  logic [ADDR_WIDTH-1:0]axi_awaddr;
  logic [7:0] axi_awlen;
  logic [2:0] axi_awsize;
  logic [1:0] axi_awburst;
  logic axi_awvalid;
  logic axi_awready;

  logic [DATA_WIDTH-1:0] axi_wdata;
  logic [DATA_WIDTH/8-1:0] axi_wstrb;
  logic axi_wlast;
  logic axi_wvalid;
  logic axi_wready;

  logic [ID_WIDTH-1:0] axi_bid;
  logic [1:0] axi_bresp;
  logic axi_bvalid;
  logic axi_bready;

  logic [ID_WIDTH-1:0] axi_arid;
  logic [31:0]axi_araddr;
  logic [7:0] axi_arlen;
  logic [2:0] axi_arsize;
  logic [1:0] axi_arburst;
  logic axi_arvalid;
  logic axi_arready;

  logic [DATA_WIDTH-1:0] axi_rdata;
  logic [ID_WIDTH-1:0] axi_rid;
  logic axi_rlast;
  logic axi_rvalid;
  logic axi_rready;

  logic [1:0] axi_rresp;

  logic [ADDR_WIDTH-1:0] paddr;
  logic pwrite;
  logic [DATA_WIDTH-1:0] pwdata;
  logic psel;
  logic penable;
  logic [DATA_WIDTH-1:0] prdata;
  logic [3:0] pstrb;
  logic pready;
  logic pslverr;
  
  modport axi(
  output axi_awaddr,axi_awid, axi_awvalid, axi_wdata, axi_awlen, axi_awsize, axi_awburst, axi_wstrb, axi_wvalid, axi_bready,
  output axi_arid, axi_araddr, axi_arlen, axi_arsize, axi_arburst, axi_arvalid, axi_rready, axi_wlast,
  input axi_rvalid,
  input axi_awready, axi_wready, axi_bresp, axi_bvalid,
    input axi_arready, axi_rdata, axi_rresp, axi_rid);

  modport apb(
  input paddr,pwdata, pstrb, psel, penable, pwrite,
  output pready, pslverr, prdata
  );
  
  property p1;
  @(posedge clk) disable iff(!rst)
  (psel && !penable) ##[1:3] (psel && penable) |-> pready;
  endproperty

  property p2;
  @(posedge clk) disable iff(!rst)
    $rose(penable) |=> $stable(paddr) ##0 $stable(pwdata || prdata) ##0 $stable(pwrite || !pwrite) ; 
  endproperty

  property p3;
  @(posedge clk) disable iff(!rst)
  axi_awvalid |-> ##[0:2] axi_awready;
  endproperty

  property p4;
  @(posedge clk) disable iff(!rst)
  axi_wvalid |-> ##[0:2] axi_wready;
  endproperty

  property p5;
  @(posedge clk) disable iff(!rst)
  axi_bvalid |-> ##[0:2] axi_bready;
  endproperty

  property p6;
  @(posedge clk) disable iff(!rst)
  axi_arvalid |-> ##[0:2] axi_arready;
  endproperty

  property p7;
  @(posedge clk) disable iff(!rst)
  axi_rvalid |-> ##[0:2] axi_rready;
  endproperty
  
  assert property(p7)begin
  `uvm_info("ASSERTION7", $sformatf("P7 PASSED"), UVM_LOW)
  end
  else
  `uvm_error("A7 FAILED", UVM_LOW)

  assert property(p6)begin
  `uvm_info("ASSERTION6", $sformatf("P6 PASSED"), UVM_LOW)
  end
  else
  `uvm_error("A6 FAILED", UVM_LOW)

  assert property(p5)begin
  `uvm_info("ASSERTION5", $sformatf("P5 PASSED"), UVM_LOW)
  end
  else
  `uvm_error("A5 FAILED", UVM_LOW)

  assert property(p4)begin
  `uvm_info("ASSERTION4", $sformatf("P4 PASSED"), UVM_LOW)
  end
  else
  `uvm_error("A4 FAILED", UVM_LOW)

  assert property(p3)begin
  `uvm_info("ASSERTION3", $sformatf("P3 PASSED"), UVM_LOW)
  end
  else
  `uvm_error("A3 FAILED", UVM_LOW)

  assert property(p2) begin
  `uvm_info("ASSERTION2", $sformatf("P2 PASSED"), UVM_LOW)
  end
  else
  `uvm_error("A2 FAILED", UVM_LOW)

    assert property(p1) begin
  `uvm_info("ASSERTION1", $sformatf("P1 PASSED"), UVM_LOW)
  end
  else
  `uvm_error("Al FAILED", UVM_LOW)

endinterface
  
