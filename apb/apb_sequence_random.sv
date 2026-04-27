`ifndef APB_SEQUENCE_RANDOM_SV
  `define APB_SEQUENCE_RANDOM_SV

class apb_sequence_random extends apb_sequence_base;

  //NUmber of items to drive
  rand int unsigned num_items;

  constraint num_items_default {
    soft num_items inside {[1:10]}; 
  }

  `uvm_object_utils(apb_sequence_random)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    for(int i = 0; i < num_items; i++) begin
      apb_sequence_simple seq = apb_sequence_simple::type_id::create("seq");
      
      `uvm_do(seq)
    end
  endtask

endclass

`endif
