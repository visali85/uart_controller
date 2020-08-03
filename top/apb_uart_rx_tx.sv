
class apb_uart_rx_tx extends uvm_test;

  uart_ctrl_tb uart_ctrl_tb0;

  `uvm_component_utils(apb_uart_rx_tx)

  function new(string name, uvm_component parent=null);
      super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(uvm_object_wrapper)::set(this, "uart_ctrl_tb0.virtual_sequencer.run_phase",
          "default_sequence", concurrent_u2a_a2u_rand_trans_vseq::type_id::get());
    uart_ctrl_tb0 = uart_ctrl_tb::type_id::create("uart_ctrl_tb0",this);

  endfunction : build_phase

endclass
