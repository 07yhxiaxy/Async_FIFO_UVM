// dv/agents/write_agent/write_agent.sv
class write_agent extends uvm_agent;
  `uvm_component_utils(write_agent)

  // Components
  write_driver    drv;
  write_monitor   mon;
  write_sequencer seqr;

  // Analysis Port to pass monitor data up to the Env
  uvm_analysis_port #(fifo_seq_item) monitor_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // 1. Always build the Monitor (We always want to see what's happening)
    mon = write_monitor::type_id::create("mon", this);

    // 2. Only build Driver/Sequencer if we are ACTIVE
    if (get_is_active() == UVM_ACTIVE) begin
      drv  = write_driver::type_id::create("drv", this);
      seqr = write_sequencer::type_id::create("seqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    // 1. Connect Monitor's port to Agent's port (Passthrough)
    mon.item_collected_port.connect(this.monitor_port);

    // 2. Connect Driver to Sequencer (Only if Active)
    if (get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction

endclass