module axi_apb_bridge #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32,
  parameter ID_WIDTH = 32)
  (
  input clk, rst,

  input [ID_WIDTH-1:0] axi_awid,
  input [ADDR_WIDTH-1:0]axi_awaddr,
  input [7:0] axi_awlen,
  input [2:0] axi_awsize,
    input [1:0] axi_awburst,
  input axi_awvalid,
  output reg axi_awready,

  input [DATA_WIDTH-1:0] axi_wdata,
  input [DATA_WIDTH/8-1:0] axi_wstrb,
  input axi_wlast,
  input axi_wvalid,
  output reg axi_wready,

  output reg [ID_WIDTH-1:0] axi_bid,
  output reg [1:0] axi_bresp,
  output reg axi_bvalid,
  input axi_bready,

  input [ID_WIDTH-1:0] axi_arid,
  input [ADDR_WIDTH-1:0]axi_araddr,
  input [7:0] axi_arlen,
  input [2:0] axi_arsize,
  input [1:0] axi_arburst,
  input reg axi_arvalid,
  output reg axi_arready,

  output reg [DATA_WIDTH-1:0] axi_rdata,
  output reg [ID_WIDTH-1:0] axi_rid,
  output reg axi_rlast,
  output reg axi_rvalid,
  input axi_rready,
  output reg [1:0] axi_rresp,

  //APB SIGNALS

  output reg [ADDR_WIDTH-1:0] paddr,
  output reg pwrite,
  output reg [DATA_WIDTH-1:0] pwdata,
  output reg psel,
  output reg penable,
  input [DATA_WIDTH-1:0] prdata,
  output reg [3:0]pstrb,
  input pready,
  input pslverr

  );

//fifo's
  reg [75:0]aw_ar_fifo[8];
  reg [35:0]w_fifo[2 ** 8];
  reg [63:0]r_fifo[30];
  reg [32:0]b_fifo[8];

  //pointer's for each fifo
  reg [2:0]aw_ar_wptr;
  reg [2:0]aw_ar_rptr;
  reg [7:0]w_wptr;
  reg [7:0]w_rptr;
  reg [2:0]b_wptr;
  reg [2:0]b_rptr;
  reg [7:0]r_wptr;
  reg [7:0]r_rptr;

  //counter's for fifo
  reg [7:0]counter_aw_ar;
  reg [2 ** 8]counter_w;
  reg [2 ** 8]counter_r;
  reg [7:0]counter_b;

  //local variables
  reg [31:0]addr;
  reg [31:0]id;
  reg [31:0]data;
  reg [7:0]len;
  reg [2:0]size;
  reg [3:0]strb;
  reg resp;

  assign axi_awready = (counter_aw_ar < 8)?1:0;
  assign axi_wready = (counter_w < 2**8)?1:0;
  assign axi_bvalid = (counter_b)?1:0;
  assign axi_arready = (counter_aw_ar < 8)?1:0;
  assign axi_rvalid = (counter_r > 0)?1:0;

 
  
  typedef enum logic [2:0] { IDLE =0, SETUP_WRITE = 1, SETUP_READ = 2, WAIT_WRITE = 3, WAIT_READ = 4, ACCESS_WRITE = 5, ACCESS_READ = 6 } apb_state;

  apb_state apb;


//aw fifo
  always@(posedge clk, rst) begin
    if(!rst) begin
      aw_ar_wptr <= 0;
      aw_ar_rptr <= 0;
      counter_aw_ar <= 0;
    end
    else begin
      if(axi_awvalid && axi_awready)begin
        aw_ar_fifo[aw_ar_wptr][75] <= 1;
        aw_ar_fifo[aw_ar_wptr][74:43] <= axi_awid;
        aw_ar_fifo[aw_ar_wptr][42:11] <= axi_awaddr;
        aw_ar_fifo[aw_ar_wptr][10:3] <= axi_awlen;
        aw_ar_fifo[aw_ar_wptr][2:0] <= axi_awsize;
        aw_ar_wptr <= aw_ar_wptr+1;
        counter_aw_ar <= counter_aw_ar+1;
     
      end
      else if(axi_arvalid && axi_arready)begin
        aw_ar_fifo[aw_ar_wptr][75] <= 0;
        aw_ar_fifo[aw_ar_wptr][74:43] <= axi_arid;
        aw_ar_fifo[aw_ar_wptr][42:11] <= axi_araddr;
        aw_ar_fifo[aw_ar_wptr][10:3] <= axi_arlen;
        aw_ar_fifo[aw_ar_wptr][2:0] <= axi_arsize;
        aw_ar_wptr <= aw_ar_wptr+1;
        counter_aw_ar <= counter_aw_ar+1;
    
      end
      else begin
      counter_aw_ar <= counter_aw_ar;
      end
    end
  end
  
  //w fifo
  always@(posedge clk, rst)begin
    if(!rst) begin
      w_wptr <= 0;
      w_rptr <= 0;
      counter_w <= 0;
    end
    else begin
      if(axi_wvalid && axi_wready) begin
        w_fifo[w_wptr][35:32] <= axi_wstrb;
        w_fifo[w_wptr][31:0] <= axi_wdata;
        w_wptr <= w_wptr+1;
        counter_w <= counter_w+1;
      end
      else begin
      counter_w<= counter_w;

      end
    end
  end

  //b fifo
  always@(posedge clk, rst)begin
    if(!rst) begin
      b_wptr <= 0;
      b_rptr <= 0;
      counter_b <= 0;
    end
    else begin
      if(axi_bvalid && axi_bready && counter_b > 0)begin
        axi_bresp <= {1'b0,b_fifo[b_rptr][0]};
        axi_bid <= b_fifo[b_rptr][32:1];
        b_rptr <= b_rptr+1;
        counter_b <= counter_b-1;
      end
      else begin
        b_rptr <= b_rptr;
      end
    end
  end

  //r fifo
  always@(posedge clk, rst) begin
    if(!rst)begin
      r_wptr <= 0;
      r_rptr <= 0;
      counter_r <= 0;
    end
    else begin
      if(axi_rvalid && counter_r > 0 && axi_rready) begin

        axi_rdata <= r_fifo[r_rptr][31:0];
        axi_rid <= r_fifo[r_rptr][63:32] ;
        axi_rresp <= {1'b0, resp};
        r_rptr <= r_rptr+1;
        counter_r <= counter_r-1;

      end
      else begin
        axi_rid <= axi_rid;
      end
    end
  end

  assign psel = (apb == SETUP_WRITE || apb == SETUP_READ || apb == WAIT_WRITE || apb == WAIT_READ || apb == ACCESS_WRITE || apb == ACCESS_READ)?1:0;
  assign penable = (apb == ACCESS_WRITE || apb == ACCESS_READ)?1:0;
  assign pwrite = (apb == SETUP_WRITE || apb == WAIT_WRITE || apb == ACCESS_WRITE ) ?1:0;
  assign paddr = addr;
  assign pwdata = data;
  assign pstrb = (apb == SETUP_WRITE || apb == WAIT_WRITE || apb == ACCESS_WRITE)?strb:0;
  
  always@(posedge clk ,rst) begin
    if(!rst) begin
      apb <= IDLE;
      strb <= 0;
    end
    else begin
      case (apb)
          IDLE: begin
            if(counter_aw_ar > 0 && counter_w > 0 && aw_ar_fifo[aw_ar_rptr][75] == 1'b1)begin
              apb <= SETUP_WRITE;
            end
            else if(counter_aw_ar > 0 && aw_ar_fifo[aw_ar_rptr][75] == 0)begin
              apb <= SETUP_READ;
            end
            else begin
              apb <= apb;
            end
        end
       
         SETUP_WRITE: begin     
          id <= aw_ar_fifo[aw_ar_rptr][74:43];
          addr <= aw_ar_fifo[aw_ar_rptr][42:11];
          len <= (aw_ar_fifo[aw_ar_rptr][10:3])+1;
          size <= aw_ar_fifo[aw_ar_rptr][2:0];
          strb <= w_fifo[w_rptr][35:32];
          data <= w_fifo[w_rptr][31:0];
          counter_w <= counter_w-1;
          w_rptr <= w_rptr+1;
          apb <= ACCESS_WRITE;           
        end

        ACCESS_WRITE: begin
          if(pready)begin
            if((len) > 1)begin
              len <= len - 1;
              apb <= WAIT_WRITE;
            end
            else begin
              len <= 0;
              apb <= IDLE;

              b_fifo[b_wptr][0] <= pslverr;
              b_fifo[b_wptr][32:1] <= id;
              b_wptr <= b_wptr+1;
              counter_b <= counter_b+1;

              aw_ar_rptr <= aw_ar_rptr+1;
              counter_aw_ar <= counter_aw_ar-1;
            end
          end
        end

        WAIT_WRITE: begin
          addr <= addr+1;
          data <= w_fifo[w_rptr];
          counter_w <= counter_w-1;
          w_rptr <= w_rptr+1;
          apb <= ACCESS_WRITE;
        end
        
        WAIT_READ: begin      
          addr <= addr+1;
          apb <= ACCESS_READ;          
        end

        SETUP_READ: begin
          id <= aw_ar_fifo[aw_ar_rptr][74:43];
          addr <= aw_ar_fifo[aw_ar_rptr][42:11];
          len <= (aw_ar_fifo[aw_ar_rptr][10:3] )+1;
          size <= aw_ar_fifo[aw_ar_rptr][2:0];
          apb <= ACCESS_READ;
        end

        ACCESS_READ: begin
          if(pready)begin
            if((len) > 1 )begin
              r_fifo[r_wptr][31:0] <= prdata;
              r_fifo[r_wptr][63:32] <= id;
              resp <= pslverr;
              r_wptr <= r_wptr+1;
              counter_r <= counter_r+1;
              len <= len-1;
              apb <= WAIT_READ;
            end
            else begin
             r_fifo[r_wptr][31:0] <= prdata;
              r_fifo[r_wptr][63:32] <= id;
              resp <= pslverr;
              r_wptr <= r_wptr+1;
              counter_r <= counter_r+1;
              aw_ar_rptr <= aw_ar_rptr+1;
              counter_aw_ar <= counter_aw_ar-1;
              apb <= IDLE;
            end
          end
        end
      endcase
    end
  end
  
endmodule

     
