`ifndef MD_SEQUENCE_BASE_MASTER_SV
`define MD_SEQUENCE_BASE_MASTER_SV

class md_sequence_base_master extends md_sequence_base#(.ITEM_DRV(md_item_drv_master));
    
    `uvm_declare_p_sequencer(md_sequencer_base_master)
    
    `uvm_object_utils(md_sequence_base_master)
    
    function new(string name = "");
      super.new(name);
    endfunction

  endclass

`endif
