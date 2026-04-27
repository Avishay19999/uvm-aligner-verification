`ifndef MD_TYPES_SV
`define MD_TYPES_SV


// Description: MD Agent package.
///////////////////////////////////////////////////////////////////////////////
`ifndef MD_PKG_SV
  `define MD_PKG_SV

  `include "uvm_macros.svh"

  `include "uvm_ext_pkg.sv"

  `include "md_if.sv"
 
  package md_pkg;

    import uvm_pkg::*;
    import uvm_ext_pkg::*;

    //MD response
    typedef enum bit {MD_OKAY = 0, MD_ERR = 1} md_response;

    

`endif
