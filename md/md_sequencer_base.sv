`ifndef MD_SEQUENCER_BASE_SV
`define MD_SEQUENCER_BASE_SV

class md_sequencer_base#(type ITEM_DRV = md_item_drv) extends uvm_ext_sequencer#(.ITEM_DRV(ITEM_DRV));

      `uvm_component_param_utils(md_sequencer_base#(ITEM_DRV))

      function new(string name = "", uvm_component parent);
        super.new(name, parent);
      endfunction

      virtual function int unsigned get_data_width();
        `uvm_fatal("ALGORITHM_ISSUE", "Implement get_data_width()")
      endfunction

    endclass

`endif
