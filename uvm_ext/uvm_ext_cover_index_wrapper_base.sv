`ifndef UVM_EXT_COVER_INDEX_WRAPPER_BASE_SV
`define UVM_EXT_COVER_INDEX_WRAPPER_BASE_SV

virtual class uvm_ext_cover_index_wrapper_base extends uvm_component;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  //Function used to sample the information
  pure virtual function void sample(int unsigned value);

  //Function to print the coverage information.
  //This is only to be able to visualize some basic coverage information
  //in EDA Playground.

  pure virtual function string coverage2string();   
endclass

`endif
