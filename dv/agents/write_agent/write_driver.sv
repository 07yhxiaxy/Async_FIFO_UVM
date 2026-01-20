// dv/agents/write_agent/write_driver.sv
class write_driver extends uvm_driver #(fifo_seq_item);
  `uvm_component_utils(write_driver)

  virtual fifo_if vif; // Handle to the interface

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase: Get interface from Config DB
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not set for: " ~ get_full_name(".vif"));
  endfunction

  // Run Phase: The Main Loop
  task run_phase(uvm_phase phase);
    forever begin
      // We use fork-join_any to handle Reset.
      // If reset goes low, the "monitor_reset" task finishes immediately, killing the "get_and_drive" task.
      fork
        begin
          // Process A: The Normal Operation
          get_and_drive();
        end
        begin
          // Process B: The Reset Watchdog
          wait(vif.rst_n == 0);
          `uvm_info("DRV", "Reset Detected! Flushing driver...", UVM_MEDIUM)
        end
      join_any
      disable fork; // Kill the surviving process (e.g., stop driving if reset hit)

      // Cleanup after reset or loop
      vif.w_drv_cb.w_en <= 0;
      
      // Wait for reset to be released before restarting the loop
      wait(vif.rst_n == 1);
    end
  endtask

  // Helper Task: The Actual Driving Logic
  task get_and_drive();
    forever begin
      // 1. Get next item from Sequencer
      seq_item_port.get_next_item(req);

      // 2. Wait for optional random delay (pre-drive)
      repeat(req.delay) @(vif.w_drv_cb);

      // 3. FULL FLAG CHECK with TIMEOUT (The "Intense" part)
      // We loop until the FIFO is NOT full.
      int timeout_counter = 0;
      while (vif.w_drv_cb.w_full == 1'b1) begin
        @(vif.w_drv_cb);
        timeout_counter++;
        if (timeout_counter > 10000) begin
            `uvm_error("DRV_TIMEOUT", "FIFO stuck in FULL state for 10,000 cycles!")
        break; // Break loop to avoid stuck
        end
      end

      // 4. Drive the signals safely
      vif.w_drv_cb.w_en <= 1;
      vif.w_drv_cb.wdata <= req.data;
      
      // 5. Pulse control (drive for 1 cycle, then deassert)
      @(vif.w_drv_cb); 
      vif.w_drv_cb.w_en <= 0;

      // 6. SEND RESPONSE BACK (The "Response" part)
      // Create a response packet
      rsp = fifo_seq_item::type_id::create("rsp");
      rsp.set_id_info(req); // Copy transaction ID so sequencer knows which req this matches
      rsp.data = req.data;  // Echo back the data (optional)
      
      // Send it back to the sequencer
      seq_item_port.item_done(rsp); 
      `uvm_info("DRV", $sformatf("Write Complete: %0h", req.data), UVM_HIGH)
    end
  endtask

endclass