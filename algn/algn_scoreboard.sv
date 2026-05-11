// Description: Scoreboard component for the Aligner RTL.
///////////////////////////////////////////////////////////////////////////////

`ifndef ALGN_SCOREBOARD_SV
  `define ALGN_SCOREBOARD_SV
 
  `uvm_analysis_imp_decl(_in_model_rx)
  `uvm_analysis_imp_decl(_in_model_tx)
  `uvm_analysis_imp_decl(_in_model_irq)
  `uvm_analysis_imp_decl(_in_agent_rx)
  `uvm_analysis_imp_decl(_in_agent_tx)
 
  class algn_scoreboard extends uvm_component implements uvm_ext_reset_handler;
    
    //Pointer to the environment configuration
    algn_env_config env_config;
 
    //Analysis implementation port for receiving RX information from model
    uvm_analysis_imp_in_model_rx#(md_response, algn_scoreboard) port_in_model_rx;
    
    //Analysis implementation port for receiving TX information from model
    uvm_analysis_imp_in_model_tx#(md_item_mon, algn_scoreboard) port_in_model_tx;
    
    //Analysis implementation port for receiving IRQ information from model
    uvm_analysis_imp_in_model_irq#(bit, algn_scoreboard) port_in_model_irq;
    
    //Analysis implementation port for receiving RX information from RX MD agent
    uvm_analysis_imp_in_agent_rx#(md_item_mon, algn_scoreboard) port_in_agent_rx;
    
    //Analysis implementation port for receiving RX information from TX MD agent
    uvm_analysis_imp_in_agent_tx#(md_item_mon, algn_scoreboard) port_in_agent_tx;
    
    
    //Expected responses on RX interface
    protected md_response exp_rx_responses[$];
    
    //Expected items on TX interface
    protected md_item_mon exp_tx_items[$];
    
    //Expected interrupt requests
    protected bit exp_irqs[$];
    
    
    //Processes associated with task exp_rx_response_watchdog()
    local process process_exp_rx_response_watchdog[$];
    
    //Processes associated with task exp_tx_item_watchdog()
    local process process_exp_tx_item_watchdog[$];
    
    //Processes associated with task exp_irq_watchdog()
    local process process_exp_irq_watchdog[$];
    
    //Process associated with task rcv_irq()
    local process process_rcv_irq;
    
    
    `uvm_component_utils(algn_scoreboard)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
      
      port_in_model_rx  = new("port_in_model_rx",  this);
      port_in_model_tx  = new("port_in_model_tx",  this);
      port_in_model_irq = new("port_in_model_irq", this);
      port_in_agent_rx  = new("port_in_agent_rx",  this);
      port_in_agent_tx  = new("port_in_agent_tx",  this);
    endfunction
    
    virtual function void handle_reset(uvm_phase phase);
      `uvm_info("SCOREBOARD_RESET", "Clearing expected RX responses, expected TX items, expected IRQs and watchdog processes", UVM_LOW)

      exp_rx_responses.delete();
      exp_tx_items.delete();
      exp_irqs.delete();
       
      kill_processes_from_queue(process_exp_rx_response_watchdog);
      kill_processes_from_queue(process_exp_tx_item_watchdog);
      kill_processes_from_queue(process_exp_irq_watchdog);
      
      if(process_rcv_irq != null) begin
        process_rcv_irq.kill();
        
        process_rcv_irq = null;
      end
      
      rcv_irq_nb();
    endfunction
    
    //Function to kill all the processes from a queue
    virtual function void kill_processes_from_queue(ref process processes[$]);
      while(processes.size() > 0) begin
        processes[0].kill();
        
        void'(processes.pop_front());
      end
    endfunction
    
    //Task for waiting for DUT to output its RX response
    protected virtual task exp_rx_response_watchdog(md_response response);
      algn_vif vif       = env_config.get_vif();
      int unsigned threshold = env_config.get_exp_rx_response_threshold();
      time start_time        = $time();
      
      repeat(threshold) begin
        @(posedge vif.clk);
      end 
      
      if(env_config.get_has_checks()) begin 
        `uvm_error("DUT_ERROR", $sformatf("The RX response, with value %0s, expected from time %0t, was not received after %0d clock cycles",
                                          response.name(), start_time, threshold))
      end 
    endtask
    
    //Task for waiting for DUT to output its TX item
    protected virtual task exp_tx_item_watchdog(md_item_mon item_mon);
      algn_vif vif       = env_config.get_vif();
      int unsigned threshold = env_config.get_exp_tx_item_threshold();
      time start_time        = $time();
      
      repeat(threshold) begin
        @(posedge vif.clk);
      end 
      
      if(env_config.get_has_checks()) begin 
        `uvm_error("DUT_ERROR", $sformatf("The TX item expected from time %0t, was not received after %0d clock cycles - item: %0s",
                                          start_time, threshold, item_mon.convert2string()))
      end 
    endtask
    
    //Task for waiting for DUT to output its IRQ
    protected virtual task exp_irq_watchdog(bit irq);
      algn_vif vif       = env_config.get_vif();
      int unsigned threshold = env_config.get_exp_irq_threshold();
      time start_time        = $time();
      
      repeat(threshold) begin
        @(posedge vif.clk);
      end 
      
      if(env_config.get_has_checks()) begin 
        `uvm_error("DUT_ERROR", $sformatf("The IRQ expected from time %0t, was not received after %0d clock cycles",
                                          start_time, threshold))
      end 
    endtask
    
    //Function to start the task exp_rx_response_watchdog()
    local function void exp_rx_response_watchdog_nb(md_response response);
      fork
        begin
          process p = process::self();
          
          process_exp_rx_response_watchdog.push_back(p);
          
          exp_rx_response_watchdog(response);
          
          if(process_exp_rx_response_watchdog.size() == 0) begin
            `uvm_fatal("ALGORITHM_ISSUE", "At the end of task exp_rx_response_watchdog the queue of processes process_exp_rx_response_watchdog is empty")
          end 
          
          void'(process_exp_rx_response_watchdog.pop_front());
        end
      join_none
    endfunction
    
    //Function to start the task exp_tx_item_watchdog()
    local function void exp_tx_item_watchdog_nb(md_item_mon item_mon);
      fork
        begin
          process p = process::self();
          
          process_exp_tx_item_watchdog.push_back(p);
          
          exp_tx_item_watchdog(item_mon);
          
          if(process_exp_tx_item_watchdog.size() == 0) begin
            `uvm_fatal("ALGORITHM_ISSUE", "At the end of task exp_tx_item_watchdog the queue of processes process_exp_tx_item_watchdog is empty")
          end 
          
          void'(process_exp_tx_item_watchdog.pop_front());
        end
      join_none
    endfunction
    
    //Function to start the task exp_irq_watchdog()
    local function void exp_irq_watchdog_nb(bit irq);
      fork
        begin
          process p = process::self();
          
          process_exp_irq_watchdog.push_back(p);
          
          exp_irq_watchdog(irq);
          
          if(process_exp_irq_watchdog.size() == 0) begin
            `uvm_fatal("ALGORITHM_ISSUE", "At the end of task exp_irq_watchdog the queue of processes process_exp_irq_watchdog is empty")
          end 
          
          void'(process_exp_irq_watchdog.pop_front());
        end
      join_none
    endfunction
    
    virtual function void write_in_model_rx(md_response response);
      if(exp_rx_responses.size() >= 1) begin
        `uvm_error("ALGORITHM_ISSUE", $sformatf("Something went wrong as there are already %0d entries in exp_rx_responses and just received one more",
                                                exp_rx_responses.size()))
      end 
      
      exp_rx_responses.push_back(response);

      `uvm_info("SCOREBOARD_EXPECTED_RX", $sformatf("Queued expected RX response: expected_response=%0s, queue_level=%0d", response.name(), exp_rx_responses.size()), UVM_LOW)
      
      exp_rx_response_watchdog_nb(response);
    endfunction

    virtual function void write_in_model_tx(md_item_mon item_mon);
      if(exp_tx_items.size() >= 1) begin
        `uvm_error("ALGORITHM_ISSUE", $sformatf("Something went wrong as there are already %0d entries in exp_tx_items and just received one more",
                                                exp_tx_items.size()))
      end 
      
      exp_tx_items.push_back(item_mon);

      `uvm_info("SCOREBOARD_EXPECTED_TX", $sformatf("Queued expected TX item: queue_level=%0d, expected_item=%0s", exp_tx_items.size(), item_mon.convert2string()), UVM_LOW)
      
      exp_tx_item_watchdog_nb(item_mon);
    endfunction

    virtual function void write_in_model_irq(bit irq);
      if(exp_irqs.size() >= 5) begin
        `uvm_error("ALGORITHM_ISSUE", $sformatf("Something went wrong as there are already %0d entries in exp_irqs and just received one more",
                                                exp_irqs.size()))
      end 
      
      exp_irqs.push_back(irq);

      `uvm_info("SCOREBOARD_EXPECTED_IRQ", $sformatf("Queued expected IRQ: expected_irq=%0b, queue_level=%0d", irq, exp_irqs.size()), UVM_MEDIUM)
      
      exp_irq_watchdog_nb(irq);
    endfunction

    virtual function void write_in_agent_rx(md_item_mon item_mon);
      if(!item_mon.is_active()) begin
        md_response exp_response = exp_rx_responses.pop_front();
        
        process_exp_rx_response_watchdog[0].kill();
        
        void'(process_exp_rx_response_watchdog.pop_front());
        
        `uvm_info("SCOREBOARD_ACTUAL_RX", $sformatf("Received actual RX response: actual_response=%0s, actual_item=%0s", item_mon.response.name(), item_mon.convert2string()), UVM_LOW)
        
        if(env_config.get_has_checks()) begin
          if(item_mon.response != exp_response) begin
            `uvm_error("DUT_ERROR_RX_RESPONSE", $sformatf("Mismatch detected for the RX response -> expected: %0s, received: %0s, item: %0s",
                                                          exp_response.name(), item_mon.response.name(), item_mon.convert2string()))
          end
          else begin
            `uvm_info("SCOREBOARD_MATCH_RX", $sformatf("MATCH RX response: expected=%0s, actual=%0s", exp_response.name(), item_mon.response.name()), UVM_LOW)
          end
        end
      end 
    endfunction

    virtual function void write_in_agent_tx(md_item_mon item_mon);
      if(!item_mon.is_active()) begin
        md_item_mon exp_item = exp_tx_items.pop_front();
        
        process_exp_tx_item_watchdog[0].kill();
        
        void'(process_exp_tx_item_watchdog.pop_front());
        
        `uvm_info("SCOREBOARD_ACTUAL_TX", $sformatf("Received actual TX item: actual_item=%0s", item_mon.convert2string()), UVM_LOW)
        
        if(env_config.get_has_checks()) begin
          if(item_mon.data != exp_item.data) begin
            `uvm_error("DUT_ERROR_TX_DATA", $sformatf("Mismatch detected for the TX data -> expected: %0s, received: %0s",
                                                      exp_item.convert2string(), item_mon.convert2string()))
          end
          
          if(item_mon.offset != exp_item.offset) begin
            `uvm_error("DUT_ERROR_TX_OFFSET", $sformatf("Mismatch detected for the TX offset -> expected: %0s, received: %0s",
                                                        exp_item.convert2string(), item_mon.convert2string()))
          end

          if((item_mon.data == exp_item.data) && (item_mon.offset == exp_item.offset)) begin
            `uvm_info("SCOREBOARD_MATCH_TX_DATA_OFFSET", $sformatf("MATCH TX data/offset only: expected=%0s, actual=%0s",
                                                                   exp_item.convert2string(), item_mon.convert2string()), UVM_LOW)
          end
        end
      end
    endfunction
    
    //Task to collect IRQ information from DUT
    protected virtual task rcv_irq();
      algn_vif vif = env_config.get_vif();
      
      forever begin
        @(posedge vif.clk iff(vif.irq & vif.reset_n));
        
        if(exp_irqs.size() == 0) begin
          if(env_config.get_has_checks()) begin
            `uvm_error("DUT_ERROR_IRQ_UNEXPECTED", "Unexpected IRQ detected")
          end
        end
        else begin
          void'(exp_irqs.pop_front());

          `uvm_info("SCOREBOARD_MATCH_IRQ", "MATCH IRQ: expected IRQ was observed", UVM_MEDIUM)

          process_exp_irq_watchdog[0].kill();

          void'(process_exp_irq_watchdog.pop_front()); 
        end
      end
    endtask
    
    //Function to start the rcv_irq() task
    local virtual function void rcv_irq_nb();
      if(process_rcv_irq != null) begin
        `uvm_fatal("ALGORITHM_ISSUE", "Can not start two instances of rcv_irq() tasks")
      end
      
      fork
        begin
          process_rcv_irq = process::self();
          
          rcv_irq();
          
          process_rcv_irq = null;
        end
      join_none
    endfunction

  endclass

`endif