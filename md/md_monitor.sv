`ifndef MD_MONITOR_SV
`define MD_MONITOR_SV

class md_monitor#(int unsigned DATA_WIDTH = 32) extends uvm_ext_monitor#(.VIRTUAL_INTF(virtual md_if#(DATA_WIDTH)), .ITEM_MON(md_item_mon));

      typedef virtual md_if#(DATA_WIDTH) md_vif;

      //Pointer to agent configuration
      md_agent_config#(DATA_WIDTH) agent_config;

      `uvm_component_param_utils(md_monitor#(DATA_WIDTH))

      function new(string name = "", uvm_component parent);
        super.new(name, parent);
      endfunction

      virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase); 
         
        if($cast(agent_config, super.agent_config) == 0) begin
          `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Could not cast %0s to %0s", 
            super.agent_config.get_type_name(), md_agent_config#(DATA_WIDTH)::type_id::type_name))
        end
      endfunction

      //Task which drives one single item on the bus
      protected virtual task collect_transaction();
        md_vif vif = agent_config.get_vif();

        int unsigned data_width_in_bytes = DATA_WIDTH / 8;

        md_item_mon item = md_item_mon::type_id::create("item");

        #(agent_config.get_sample_delay_start_tr());

        while(vif.valid !== 1) begin
          @(posedge vif.clk);

          item.prev_item_delay++;

          #(agent_config.get_sample_delay_start_tr());
        end

        item.offset = vif.offset;

        for(int i = 0; i < vif.size; i++) begin
          item.data.push_back((vif.data >> ((item.offset + i) * 8)) & 8'hFF);
        end

        item.length = 1;
 
        void'(begin_tr(item));

        `uvm_info("MD_MONITOR_START", $sformatf("Started collecting MD item: %0s", item.convert2string()), UVM_MEDIUM)

        output_port.write(item);

        @(posedge vif.clk);

        while(vif.ready !== 1) begin
          @(posedge vif.clk);
          item.length++;

          if(agent_config.get_has_checks()) begin
            if(item.length >= agent_config.get_stuck_threshold()) begin
              `uvm_error("PROTOCOL_ERROR", $sformatf("The MD transfer reached the stuck threshold value of %0d", item.length))
            end
          end
        end

        item.response = md_response'(vif.err);

        end_tr(item);

        output_port.write(item);

        `uvm_info("MD_MONITOR_END", $sformatf("Observed MD item: %0s", item.convert2string()), UVM_LOW)
      endtask

    endclass

`endif
