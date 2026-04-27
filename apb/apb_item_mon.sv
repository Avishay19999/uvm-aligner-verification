`ifndef APB_ITEM_MON_SV
  `define APB_ITEM_MON_SV

class apb_item_mon extends apb_item_base;

  //Response
  apb_response response;

  //Lenght, in clock cycles, of the APB transfer
  int unsigned length;

  //Number of clock cycles from the previous item
  int unsigned prev_item_delay;

  `uvm_object_utils(apb_item_mon)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual function string convert2string();
    string result = super.convert2string();

    result = $sformatf("%s, data: %0x, response: %0s, length: %0d, prev_item_delay: %0d",
                       result, data, response.name(), length, prev_item_delay);

    return result;
  endfunction

endclass

`endif
