// Description: APB Agent package.
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_PKG_SV
  `define APB_PKG_SV

  `include "uvm_macros.svh"

  `include "uvm_ext_pkg.sv"

  `include "apb_if.sv"

  package apb_pkg;
    import uvm_pkg::*;
    import uvm_ext_pkg::*;

    `include "apb_types.sv"
    `include "apb_item_base.sv"
    `include "apb_item_drv.sv"
    `include "apb_item_mon.sv"
    `include "apb_agent_config.sv"
    `include "apb_monitor.sv"
    `include "apb_coverage.sv"
    `include "apb_driver.sv"
    `include "apb_agent.sv"
    `include "apb_sequence_base.sv"
    `include "apb_sequence_simple.sv"
    `include "apb_sequence_rw.sv"
    `include "apb_sequence_random.sv"
    `include "apb_reg_adapter.sv"

  endpackage

`endif
