`ifndef APB_SEQUENCE_RW_SV
  `define APB_SEQUENCE_RW_SV

class apb_sequence_rw extends apb_sequence_base;

  //Address
  rand apb_addr addr;

  //Write data
  rand apb_data wr_data;

  `uvm_object_utils(apb_sequence_rw)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();

    //The above code can be replaced with `uvm_do macros
    apb_item_drv item;

    `uvm_do_with(item, {
      dir  == APB_READ;
      addr == local::addr;
    });

    `uvm_do_with(item, {
      dir  == APB_WRITE;
      addr == local::addr;
      data == wr_data;
    });

  endtask

endclass

`endif
