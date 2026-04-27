`ifndef APB_SEQUENCE_BASE_SV
  `define APB_SEQUENCE_BASE_SV

class apb_sequence_base extends uvm_sequence#(.REQ(apb_item_drv));

  `uvm_declare_p_sequencer(uvm_ext_sequencer#(.ITEM_DRV(apb_item_drv)))

  `uvm_object_utils(apb_sequence_base)

  function new(string name = "");
    super.new(name);
  endfunction

endclass

`endif
