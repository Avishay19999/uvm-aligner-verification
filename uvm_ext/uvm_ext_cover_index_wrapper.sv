`ifndef UVM_EXT_COVER_INDEX_WRAPPER_SV
`define UVM_EXT_COVER_INDEX_WRAPPER_SV

//Wrapper over the covergroup which covers indices.
//The MAX_VALUE parameter is used to determine the maximum value to sample
class uvm_ext_cover_index_wrapper#(int unsigned MAX_VALUE_PLUS_1 = 16) extends uvm_ext_cover_index_wrapper_base;

  `uvm_component_param_utils(uvm_ext_cover_index_wrapper#(MAX_VALUE_PLUS_1))

  covergroup cover_index with function sample(int unsigned value);
    option.per_instance = 1;

    index : coverpoint value {
      option.comment = "Index";
      bins values[MAX_VALUE_PLUS_1] = {[0:MAX_VALUE_PLUS_1-1]};
    }

  endgroup

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    cover_index = new();
    cover_index.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_index"));
  endfunction

  //Function to print the coverage information.
  //This is only to be able to visualize some basic coverage information
  //in EDA Playground.

  virtual function string coverage2string();
    return {
      $sformatf("\n   cover_index:              %03.2f%%", cover_index.get_inst_coverage()),
      $sformatf("\n      index:                 %03.2f%%", cover_index.index.get_inst_coverage())
    };
  endfunction

  //Function used to sample the information
  virtual function void sample(int unsigned value);
    cover_index.sample(value);
  endfunction

endclass

`endif
