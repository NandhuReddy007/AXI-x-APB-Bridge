`ifndef SCOREBOARD_SV
  `define SCOREBOARD_SV

  `include "packet.sv"
  `include "transaction.sv"

  class scoreboard extends uvm_scoreboard;

    uvm_tlm_analysis_fifo #(packet) before_fifo;
    uvm_tlm_analysis_fifo #(apb_packet) after_fifo;
    uvm_analysis_imp#(packet, scoreboard) len_sb;

    packet len;
    bit[7:0] len_q[$];

    bit[31:0] axi_addr[$];
    bit[31:0] axi_data[$];

    bit[31:0] apb_addr[$];
    bit[31:0] apb_data[$];
    int k=0;
    int l=0;
    packet pkt;
    apb_packet tr;
    int sb_count = 0;
    uvm_event Done;

    int bin;
    int i=0;
    int total_beats = 0;

    `uvm_component_utils(scoreboard)

    function new(string name, uvm_component parent);
      super.new(name, parent);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);
      before_fifo = new("before_fifo",this);
      after_fifo = new("after_fifo",this);
      len_sb = new("len_sb", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase (phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH);
      Done = new("Done") ;
      uvm_config_db#(uvm_event) :: set(null,"uvm_test_top","Done", Done);
    endfunction
    
    function void write(packet len);
      if(len.read_write_mode) begin
        len_q.push_back(len.axi_awlen);
        total_beats = len_q[i]+1+total_beats;
        `uvm_info("len_w", $sformatf("len:%d",total_beats), UVM_LOW)
        i=i+1;
      end
      else begin
        if(len.read_write_mode == 0)begin
          len_q.push_back(len.axi_arlen);
          `uvm_info("len_r", $sformatf("len:%d",len_q[i]), UVM_LOW)
          total_beats = len_q[i]+1+total_beats;
          i=i+1;
      end
    end
    endfunction

    virtual task run_phase(uvm_phase phase);
      `uvm_info("TAG", $sformatf("%m"), UVM_HIGH) ;

      fork

        forever begin

          before_fifo.get(pkt);
          if(pkt.read_write_mode == 1)begin
            for(int i=0;i <= pkt.axi_awlen;i++)begin
              axi_data.push_back(pkt.axi_wdata[i]);
              axi_addr.push_back((pkt.axi_awaddr)+i);
              //`uvm_info("AXI_SCOREBOARD", $sformatf("\n %p %p In",axi_data,axi_addr), UVM_LOW);
            end
         // `uvm_info("AXI_SCOREBOARD", $sformatf("\n %p %p \n",axi_data,axi_addr), UVM_LOW);

            repeat(pkt.axi_awlen+1)begin
              after_fifo.get(tr);
             // `uvm_info("PKT RX FROM APB", $sformatf("%m"),UVM_LOW)
              apb_data.push_back(tr.pwdata);
              apb_addr.push_back(tr.paddr) ;
             // `uvm_info("APB_SCOREBOARD", $sformatf("In %p %p \n",apb_data,apb_addr), UVM_LOW);
            end
         // `uvm_info("APB_SCOREBOARD", $sformatf("In %p %p \n",apb_data,apb_addr), UVM_LOW);

            repeat(pkt.axi_awlen+1)begin
              if(apb_data[0] == axi_data[0] && apb_addr[0] == axi_addr[0])begin
                `uvm_info("COMPARE", $sformatf("\n (apb_addr = %h) == (axi_addr = %h) && (apb_data = %h) == (axi_data = %h) (SB_COUNT %D) \n", apb_addr[0], axi_addr[0],apb_data[0],axi_data[0], sb_count), UVM_LOW) ;


                sb_count = sb_count + 1;
                bin=apb_data.pop_front();
                bin=apb_addr.pop_front();
                bin=axi_data.pop_front ();
                bin=axi_addr.pop_front();
              end
              else begin
                `uvm_fatal("COMPARISON NOT SUCCESSFULL", $sformatf("%m") ) ;
              end
            end
          end

          else begin
            for(int i=0;i<pkt.axi_arlen+1;i++)begin
              axi_data.push_back(pkt.axi_rdata[i]);
              axi_addr.push_back((pkt.axi_araddr)+i);
            end

            repeat(pkt.axi_arlen+1)begin
              after_fifo.get(tr);

              apb_data.push_back(tr.prdata);
              apb_addr.push_back(tr.paddr);
            end
            //`uvm_info("APB_SCOREBOARD", $sformatf("\n %p %p \n",apb_data,apb_addr), UVM_LOW);
            repeat(pkt.axi_arlen+1)begin
              if(apb_data[0] == axi_data[0] && apb_addr[0] == axi_addr[0])begin
                `uvm_info("COMPARE", $sformatf("\n (apb_addr = %h) == (axi_addr = %h) && (apb_data = %h) == (axi_data = %h) (SB_COUNT: %d) \n",apb_addr[0],axi_addr[0], apb_data[0], axi_data[0],sb_count), UVM_LOW);

                sb_count = sb_count + 1;
                bin=apb_data.pop_front();
                bin=apb_addr.pop_front();
                bin=axi_data.pop_front();
                bin=axi_addr.pop_front();
              end
              else begin
                `uvm_fatal("COMPARISON NOT SUCCESSFULL", $sformatf("%m"));
              end
            end
          end
        end
        
        wait((sb_count+1)==total_beats)begin
          Done.trigger();
          `uvm_info("",$sformatf("SB_COUNT:%d..TOTAL_BEATS:%d",sb_count,total_beats),UVM_LOW);
        end
      join_any
    endtask
    
  endclass
`endif
