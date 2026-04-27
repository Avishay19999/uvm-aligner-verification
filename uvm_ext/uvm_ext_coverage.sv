`ifndef UVM_EXT_COVERAGE_SV
`define UVM_EXT_COVERAGE_SV

class uvm_ext_coverage#(type VIRTUAL_INTF = int, type ITEM_MON = uvm_sequence_item) extends uvm_component implements uvm_ext_reset_handler;

  //Pointer to agent configuration
  uvm_ext_agent_config#(VIRTUAL_INTF) agent_config;

  //Port for receiving the collected item
  uvm_analysis_imp_item#(ITEM_MON, uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON)) port_item; 

  `uvm_component_param_utils(uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    port_item = new("port_item", this);
  endfunction

  //Port associated with port_item port
  virtual function void write_item(ITEM_MON item);

  endfunction

  //Function to handle the reset
  virtual function void handle_reset(uvm_phase phase);

  endfunction

  //Function to print the coverage information.
  //This is only to be able to visualize some basic coverage information
  //in EDA Playground.

  virtual function string coverage2string();
    string result = "";

    uvm_component children[$];

    get_children(children);

    foreach(children[idx]) begin
      uvm_ext_cover_index_wrapper_base wrapper;

      if($cast(wrapper, children[idx])) begin
        result = $sformatf("%s\n\nChild component: %0s%0s", result, wrapper.get_name(), wrapper.coverage2string());
      end
    end

    return result;
  endfunction
 
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    //Coverage summary printing is used here for lightweight demo/debug visibility.
    `uvm_info("COVERAGE", $sformatf("Coverage: %0s", coverage2string()), UVM_DEBUG)
  endfunction 

endclass

`endif
