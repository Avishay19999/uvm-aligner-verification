
// Description: Base class for the virtual sequences.
///////////////////////////////////////////////////////////////////////////////

`ifndef ALGN_VIRTUAL_SEQUENCE_BASE_SV
  `define ALGN_VIRTUAL_SEQUENCE_BASE_SV
 
  class algn_virtual_sequence_base extends uvm_sequence;
    
    `uvm_declare_p_sequencer(algn_virtual_sequencer)

    `uvm_object_utils(algn_virtual_sequence_base)
    
    function new(string name = "");
      super.new(name);
    endfunction
    
  endclass

`endif
    