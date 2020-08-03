
class uart_ctrl_virtual_sequencer extends uvm_sequencer;

    apb_package::apb_master_sequencer apb_seqr;
    test_pkg::virtual_sequencer uart_seqr;
    //uart_ctrl_reg_sequencer reg_seqr;   //KAM - remove

    // UVM_REG: Pointer to the register model
    //uart_ctrl_reg_model_c reg_model;  //KAM - remove
   
    // Uart Controller configuration object
    uart_ctrl_config cfg;

    function new (input string name="uart_ctrl_virtual_sequencer", input uvm_component parent=null);
      super.new(name, parent);
    endfunction : new

    `uvm_component_utils_begin(uart_ctrl_virtual_sequencer)
       `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
       //`uvm_field_object(reg_model, UVM_DEFAULT | UVM_REFERENCE)  //KAM - remove
    `uvm_component_utils_end

endclass : uart_ctrl_virtual_sequencer
