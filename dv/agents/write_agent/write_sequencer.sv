// dv/agents/write_agent/write_sequencer.sv
class write_sequencer extends uvm_sequencer #(fifo_seq_item);
  `uvm_component_utils(write_sequencer)

  // Standard UVM Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass