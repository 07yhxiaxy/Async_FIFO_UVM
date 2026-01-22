// dv/agents/write_agent/write_monitor.sv
class write_monitor extends uvm_monitor;
  `uvm_component_utils(write_monitor)

  // 1. Virtual Interface Handle
  virtual fifo_if vif;

  // 2. Analysis Port (The Broadcaster)
  uvm_analysis_port #(fifo_seq_item) item_collected_port;

  // 3. Placeholder for captured transaction
  fifo_seq_item trans_collected;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    // Initialize the port
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Robustness Check: Did we get the interface?
    if(!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction

  task run_phase(uvm_phase phase);
    // Always create the transaction object ONCE to save memory, 
    // or create new ones per loop. Creating new ones is safer for beginners.
    
    forever begin
      // A. Wait for the Clocking Block event (Sync with hardware)
      @(vif.w_mon_cb);

      // B. Reset Handling (Critical for Robustness)
      // If reset is active (low), do nothing.
      if (vif.rst_n === 0) begin
         continue; 
      end

      // C. Sample Protocol
      // We only capture if Write Enable is HIGH and the FIFO is NOT FULL.
      // (Standard Async FIFO logic drops writes when full).
      if (vif.w_mon_cb.w_en === 1 && vif.w_mon_cb.w_full === 0) begin
        
        // Create a new object to send
        trans_collected = fifo_seq_item::type_id::create("trans_collected");
        
        // Sample the data pins
        trans_collected.data = vif.w_mon_cb.wdata;
        trans_collected.w_en = 1;
        
        // Logging (Use UVM_HIGH so we don't spam logs in regression)
        `uvm_info("MON", $sformatf("Packet Captured: Data=0x%0h", trans_collected.data), UVM_HIGH)

        // Broadcast to Scoreboard / Coverage
        item_collected_port.write(trans_collected);
      end 
      
      // D. Robustness: Detect Protocol Violation (Optional but Pro)
      // If we try to write while full, warn the user.
      else if (vif.w_mon_cb.w_en === 1 && vif.w_mon_cb.w_full === 1) begin
        `uvm_warning("MON", "Attempted write while FIFO is FULL. Data dropped.")
      end
    end
  endtask

endclass