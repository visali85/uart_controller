
package uart_ctrl_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import apb_package::*;
import test_pkg::*;

`include "../src/uart_config.sv"
`include "../src/uart_ctrl_reg_model.sv"
`include "../src/uart_ctrl_defines.sv"
//`include "reg_to_apb_adapter.sv"
`include "../src/uart_ctrl_scoreboard.sv"
`include "../coverage/uart_ctrl_cover.sv"
`include "../src/uart_ctrl_monitor.sv"
//`include "uart_ctrl_reg_sequencer.sv"    //KAM - Remove
`include "../src/uart_ctrl_virtual_sequencer.sv"
`include "../src/uart_ctrl_env.sv"

endpackage : uart_ctrl_pkg
