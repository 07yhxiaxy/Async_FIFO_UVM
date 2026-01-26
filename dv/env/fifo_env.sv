class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  write_agent    w_agent;
  read_agent     r_agent;
  fifo_scoreboard scb;
  
  // NEW: Coverage Component
  fifo_coverage  cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    w_agent = write_agent::type_id::create("w_agent", this);
    r_agent = read_agent::type_id::create("r_agent", this);
    scb     = fifo_scoreboard::type_id::create("scb", this);
    
    // Build Coverage
    cov     = fifo_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    w_agent.monitor_port.connect(scb.write_export);
    r_agent.monitor_port.connect(scb.read_export);
    
    // Connect Agents to Coverage
    // Note: You can connect multiple listeners to one analysis port!
    w_agent.monitor_port.connect(cov.analysis_export);
    r_agent.monitor_port.connect(cov.analysis_export);
  endfunction

endclass