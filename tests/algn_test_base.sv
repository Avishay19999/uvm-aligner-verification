
// Description: Basic test class. It creates the instance of the environment.
//              This class should be the parent of all the tests used in the
//              verification of the Aligner.
///////////////////////////////////////////////////////////////////////////////
`ifndef ALGN_TEST_BASE_SV
  `define ALGN_TEST_BASE_SV

  class algn_test_base extends uvm_test;
    
    //Environment instance
    algn_env#(`ALGN_TEST_ALGN_DATA_WIDTH) env;

    `uvm_component_utils(algn_test_base)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      env = algn_env#(`ALGN_TEST_ALGN_DATA_WIDTH)::type_id::create("env", this);
    endfunction
    
  endclass

`endif