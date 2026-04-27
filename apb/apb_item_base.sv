`ifndef APB_ITEM_BASE_SV
  `define APB_ITEM_BASE_SV

class apb_item_base extends uvm_sequence_item;

  //Direction
  rand apb_dir dir;

  //Address
  rand apb_addr addr;

  //Data
  rand apb_data data;

  `uvm_object_utils(apb_item_base)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual function string convert2string();
    string result = $sformatf("dir: %0s, addr: %0x", dir.name(), addr);

    return result;
  endfunction

endclass

`endif
