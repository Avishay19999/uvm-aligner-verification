`ifndef APB_SEQUENCE_SIMPLE_SV
  `define APB_SEQUENCE_SIMPLE_SV

class apb_sequence_simple extends apb_sequence_base;

  //Item to drive
  rand apb_item_drv item;

  `uvm_object_utils(apb_sequence_simple)

  function new(string name = "");
    super.new(name);

    item = apb_item_drv::type_id::create("item");
  endfunction

  virtual task body();
    `uvm_send(item)
  endtask

endclass

`endif
