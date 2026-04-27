
// Description: Virtual sequencer class.
///////////////////////////////////////////////////////////////////////////////

`ifndef ALGN_VIRTUAL_SEQUENCER_SV
  `define ALGN_VIRTUAL_SEQUENCER_SV
 
  class algn_virtual_sequencer extends uvm_sequencer;
    
    //Reference to the APB sequencer
    uvm_sequencer_base apb_sequencer;
    
    //Reference to the MD RX sequencer
    md_sequencer_base_master md_rx_sequencer;
    
    //Reference to the MD TX sequencer
    md_sequencer_base_slave md_tx_sequencer;
    
    //Reference to the model
    algn_model model;
    
    `uvm_component_utils(algn_virtual_sequencer)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
    
  endclass

`endif
    