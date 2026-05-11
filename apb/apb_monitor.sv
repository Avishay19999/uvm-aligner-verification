`ifndef APB_MONITOR_SV
  `define APB_MONITOR_SV

class apb_monitor extends uvm_ext_monitor#(.VIRTUAL_INTF(apb_vif), .ITEM_MON(apb_item_mon));

  //Pointer to agent configuration
  apb_agent_config agent_config;

  `uvm_component_utils(apb_monitor)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
     
    if($cast(agent_config, super.agent_config) == 0) begin
      `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Could not cast %0s to %0s", 
         super.agent_config.get_type_name(), apb_agent_config::type_id::type_name))
    end
  endfunction

  //Task which drives one single item on the bus
  protected virtual task collect_transaction();
    apb_vif vif = agent_config.get_vif();
    apb_item_mon item = apb_item_mon::type_id::create("item");

    while(vif.psel !== 1) begin
      @(posedge vif.pclk);
      item.prev_item_delay++;
    end

    item.addr   = vif.paddr;
    item.dir    = apb_dir'(vif.pwrite);
    item.length = 1;

    if(item.dir == APB_WRITE) begin
      item.data = vif.pwdata;
    end

    @(posedge vif.pclk);
    item.length++;

    while(vif.pready !== 1) begin
      @(posedge vif.pclk);
      item.length++;

      if(agent_config.get_has_checks()) begin
        if(item.length >= agent_config.get_stuck_threshold()) begin
          `uvm_error("PROTOCOL_ERROR", $sformatf("The APB transfer reached the stuck threshold value of %0d", item.length))
        end
      end
    end

    item.response = apb_response'(vif.pslverr);

    if(item.dir == APB_READ) begin
      item.data = vif.prdata;
    end
 
    output_port.write(item);

    `uvm_info("APB_MONITOR", $sformatf("Observed APB transaction: %0s", item.convert2string()), UVM_LOW)

    @(posedge vif.pclk);
  endtask

endclass

`endif
