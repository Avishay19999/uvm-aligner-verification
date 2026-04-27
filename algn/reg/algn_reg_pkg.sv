`ifndef ALGN_REG_PKG_SV
`define ALGN_REG_PKG_SV

package algn_reg_pkg;
  import uvm_pkg::*;

    `include "algn_reg_ctrl.sv"
    `include "algn_reg_status.sv"
    `include "algn_reg_irqen.sv"
    `include "algn_reg_irq.sv"
    `include "algn_reg_block.sv"

endpackage

`endif
