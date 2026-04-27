`ifndef MD_SEQUENCER_SLAVE_SV
`define MD_SEQUENCER_SLAVE_SV

class md_sequencer_slave#(int unsigned DATA_WIDTH = 32) extends md_sequencer_base_slave;

    `uvm_component_param_utils(md_sequencer_slave#(DATA_WIDTH))

    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function int unsigned get_data_width();
      return DATA_WIDTH;
    endfunction
    
  endclass

`endif
