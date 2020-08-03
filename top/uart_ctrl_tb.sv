
`include "uart_ctrl_reg_seq_lib.sv"

//Include UART Controller-specific UVC sequences
`include "uart_ctrl_seq_lib.sv"
`include "uart_ctrl_virtual_seq_lib.sv"

//--------------------------------------------------------------
//  Simulation Verification Environment 
//--------------------------------------------------------------
class uart_ctrl_tb extends uvm_env;

  // UVC Components
  apb_package::apb_env   apb0;          // APB UVC
  test_pkg::tb uart0;         // UART UVC
  uart_ctrl_env      uart_ctrl0;    // Module UVC
  
  // Virtual sequencer
  uart_ctrl_virtual_sequencer virtual_sequencer;

  // Configurations object
  uart_ctrl_config cfg;
	env_config e_cfg;  

	int no_of_ragent = 1;
         int no_of_wagent=1;
         int has_ragent = 1;
         int has_wagent = 1;

  // UVM_REG - Register Model
  uart_ctrl_reg_model_c reg_model;    // Register Model
  //uvm_reg_predictor#(apb_transfer) apb_predictor; //Predictor - APB to REG  //KAM -removed
  // Enable coverage for the register model
  bit coverage_enable = 1;

  uvm_table_printer printer = new();

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(uart_ctrl_tb)
     `uvm_field_object(reg_model, UVM_DEFAULT | UVM_REFERENCE)
     `uvm_field_object(cfg, UVM_DEFAULT)
     `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  // Constructor - required UVM syntax
  function new(input string name, input uvm_component parent=null);
    super.new(name,parent);
  endfunction

  // Additional class methods
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task reset_reg_model();
  //extern virtual function void update_config(uart_ctrl_config uart_ctrl_cfg);

endclass : uart_ctrl_tb

  function void uart_ctrl_tb::start_of_simulation_phase(uvm_phase phase);
    uvm_test_done.set_drain_time(this, 1000);
    uvm_test_done.set_report_verbosity_level(UVM_HIGH);
  endfunction : start_of_simulation_phase

  function void uart_ctrl_tb::build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Configure UVCs
    if (cfg == null) 
      if (!uvm_config_db#(uart_ctrl_config)::get(this, "", "cfg", cfg)) begin
        `uvm_info("NOCONFIG", "No uart_ctrl_config, creating...", UVM_LOW)
        cfg = uart_ctrl_config::type_id::create("cfg", this);
        cfg.apb_cfg.add_master("master", UVM_ACTIVE);
        cfg.apb_cfg.add_slave("uart0", 32'h000000, 32'h81FFFF, 0, UVM_PASSIVE);
        `uvm_info(get_type_name(), {"Printing cfg:\n", cfg.sprint()}, UVM_MEDIUM)
      end 

   // Configure the sub-components. 
   uvm_config_object::set(this, "apb0", "cfg", cfg.apb_cfg);
   uvm_config_object::set(this, "uart0", "cfg", cfg.uart_cfg);
   uvm_config_object::set(this, "uart_ctrl0", "cfg", cfg);
   uvm_config_object::set(this, "virtual_sequencer", "cfg", cfg);
   uvm_config_object::set(this, "uart_ctrl0", "apb_slave_cfg", cfg.apb_cfg.slave_configs[0]);

	 e_cfg=env_config::type_id::create("e_cfg");

 if(has_wagent)
        e_cfg.w_cfg = new[no_of_wagent];

        if(has_ragent)
        e_cfg.r_cfg = new[no_of_ragent];

e_cfg.w_cfg=new[no_of_wagent];
         e_cfg.r_cfg=new[no_of_ragent];

         if (has_wagent)
         begin
         w_cfg = new[no_of_wagent];
         foreach(w_cfg[i])
                begin
                w_cfg[i]=master_agent_config::type_id::create($sformatf("w_cfg[%0d]", i));
                if(!uvm_config_db #(virtual uart_if)::get(this,"","vif_0",w_cfg[i].vif))
                `uvm_fatal("VIF CONFIG","cannot get()interface vif from uvm_config_db. Have you set() it?")
                w_cfg[i].is_active = UVM_ACTIVE;
                e_cfg.w_cfg[i] = w_cfg[i];
                end
          end

         if (has_ragent)
         begin
         r_cfg=new[no_of_ragent];
         foreach(r_cfg[i])
                begin
                r_cfg[i]=slave_agent_config::type_id::create($sformatf("r_cfg[%0d]",i));
                if(!uvm_config_db #(virtual uart_if)::get(this,"","vif_0",r_cfg[i].vif))
                `uvm_fatal("VIF CONFIG","cannot get() interface vif from uvm_config_db. Have you set() it?")
                r_cfg[i].is_active = UVM_ACTIVE;
                e_cfg.r_cfg[i]=r_cfg[i];
                end
         end
         e_cfg.no_of_ragent = no_of_ragent;
         e_cfg.no_of_wagent = no_of_wagent;

         e_cfg.has_ragent = has_ragent;
         e_cfg.has_wagent = has_wagent;

uvm_config_db #(env_config)::set(this,"*","env_config",e_cfg);
    //UVM_REG - Create and configure the register model
    if (reg_model == null) begin
      // Only enable reg model coverage if enabled for the testbench
      if (coverage_enable == 1) uvm_reg::include_coverage("*", UVM_CVR_ALL);
      reg_model = uart_ctrl_reg_model_c::type_id::create("reg_model");
      reg_model.build();  //NOTE: not same as build_phase: reg_model is an object
      reg_model.lock_model();
    end
    // set the register model for the rest of the testbench
    uvm_config_object::set(this, "*", "reg_model", reg_model);

    // Create APB, UART, Module UVC and Virtual Sequencer
    apb0              = apb_package::apb_env::type_id::create("apb0",this);
    uart0             = test_pkg::tb::type_id::create("uart0",this);
    uart_ctrl0        = uart_ctrl_env::type_id::create("uart_ctrl0",this);
    virtual_sequencer = uart_ctrl_virtual_sequencer::type_id::create("virtual_sequencer",this);
  
  //ToDo: Add register sequencer //KAM - removed

  //UVM_REG
  //apb_predictor = uvm_reg_predictor#(apb_transfer)::type_id::create("apb_predictor", this);  //KAM -removed
  
  endfunction : build_phase

  // UVM connect_phase
  function void uart_ctrl_tb::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //UVM_REG - set the sequencer and adapter for the register model
    
    reg_model.default_map.set_sequencer(apb0.master.sequencer, uart_ctrl0.reg2apb);  //
    // ToDo: repmove this line when apb connection is working //KAM - removed
    //reg_model.default_map.set_auto_predict(1); //KAM - removed
    // ***********************************************************
    //  Hookup virtual sequencer to interface sequencers
    // ***********************************************************
    //virtual_sequencer.reg_seqr = uart_ctrl0.reg_sequencer;  //KAM - removed
    virtual_sequencer.apb_seqr = apb0.master.sequencer;
    //if (uart0.e_cfg.cfg.is_tx_active == UVM_ACTIVE)  
    // visali   virtual_sequencer.uart_seqr =  uart0.wtop.wagent[0].m_sequencer;

    //SETUP THE UART SLAVE CONFIG
    uart_ctrl0.set_slave_config(cfg.apb_cfg.slave_configs[0], 0);

    // ***********************************************************
    // Connect TLM ports
    // ***********************************************************
	//uart0.wtop.wagent.monh.monitor_port.connect(uart_ctrl0.monitor.uart_tx_in);
//	uart0.rtop.ragent.monh.monitor_port.connect(uart_ctrl0.monitor.uart_rx_in);
	
//    uart0.Rx.monitor.frame_collected_port.connect(uart_ctrl0.monitor.uart_rx_in);
  //  uart0.Tx.monitor.frame_collected_port.connect(uart_ctrl0.monitor.uart_tx_in);
    apb0.bus_monitor.item_collected_port.connect(uart_ctrl0.monitor.apb_in);
    apb0.bus_monitor.item_collected_port.connect(uart_ctrl0.apb_in);
    apb0.bus_monitor.item_collected_port.connect(uart_ctrl0.apb_predictor.bus_in);

    // ***********************************************************
    // Connect the dut_cfg ports
    // ***********************************************************
//    uart_ctrl0.uart_cfg_out.connect(uart0.dut_cfg_port_in);

  endfunction : connect_phase

  task uart_ctrl_tb::run_phase(uvm_phase phase);
    printer.knobs.depth = 5;
    printer.knobs.name_width = 25;
    printer.knobs.type_width = 20;
    printer.knobs.value_width = 20;
    `uvm_info(get_type_name(),
       {"UART_Controller Testbench Topology:\n", this.sprint(printer)},
       UVM_LOW)
      `uvm_info(get_type_name(), {"REGISTER MODEL:\n", reg_model.sprint()}, UVM_MEDIUM)
    fork
      reset_reg_model();
      super.run_phase(phase);
    join_none
  endtask

  task uart_ctrl_tb::reset_reg_model();
    forever begin
      wait (uart_ctrl_top.reset == 0);
      `uvm_info(get_type_name(), "Resetting Registers", UVM_LOW)
      reg_model.reset();
      wait (uart_ctrl_top.reset == 1);
    end
  endtask

/*  function void uart_ctrl_tb::update_config(uart_ctrl_config uart_ctrl_cfg);
     `uvm_info(get_type_name(), {"Update Config\n", uart_ctrl_cfg.sprint()}, UVM_HIGH)
     cfg = uart_ctrl_cfg;
     // SHOULD NOT BE NECESSARY - EVERYTHING IS A POINTER
     uart_ctrl0.update_config(uart_ctrl_cfg, 0);
     uart0.update_config(uart_ctrl_cfg.uart_cfg);
     apb0.update_config(uart_ctrl_cfg.apb_cfg);
  endfunction : update_config
*/

