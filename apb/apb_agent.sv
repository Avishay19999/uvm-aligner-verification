`ifndef APB_AGENT_SV
  `define APB_AGENT_SV

class apb_agent extends uvm_ext_agent#(.VIRTUAL_INTF(apb_vif), .ITEM_MON(apb_item_mon), .ITEM_DRV(apb_item_drv));

  `uvm_component_utils(apb_agent)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    
    uvm_ext_agent_config#(.VIRTUAL_INTF(apb_vif))::type_id::set_inst_override(apb_agent_config::get_type(), "agent_config", this);
    uvm_ext_monitor#(.VIRTUAL_INTF(apb_vif), .ITEM_MON(apb_item_mon))::type_id::set_inst_override(apb_monitor::get_type(), "monitor", this);
    uvm_ext_coverage#(.VIRTUAL_INTF(apb_vif), .ITEM_MON(apb_item_mon))::type_id::set_inst_override(apb_coverage::get_type(), "coverage", this);
    uvm_ext_driver#(.VIRTUAL_INTF(apb_vif), .ITEM_DRV(apb_item_drv))::type_id::set_inst_override(apb_driver::get_type(), "driver", this);
  endfunction

endclass

`endif
