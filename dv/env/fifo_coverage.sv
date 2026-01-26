// dv/env/fifo_coverage.sv
class fifo_coverage extends uvm_subscriber #(fifo_seq_item);
  `uvm_component_utils(fifo_coverage)

  // Variables to track state
  bit w_en, r_en;
  bit full, empty;
  
  // 1. DEFINE COVERGROUPS
  covergroup fifo_cg;
    
    // CP1: Did we do back-to-back writes?
    cp_write: coverpoint w_en {
      bins single   = (0 => 1 => 0);
      bins burst    = (1 [* 3:10]); // Saw 3-10 consecutive writes
    }

    // CP2: Did we do back-to-back reads?
    cp_read: coverpoint r_en {
      bins single   = (0 => 1 => 0);
      bins burst    = (1 [* 3:10]);
    }
    
    // CP3: Cross Coverage (Simultaneous R/W)
    // This confirms we stressed the dual-port memory
    cross cp_write, cp_read;

  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    fifo_cg = new(); // Create the group
  endfunction

  // 2. SAMPLE FUNCTION
  // This is called automatically whenever the Monitor broadcasts a packet
  function void write(fifo_seq_item t);
    // Update local vars from the packet
    w_en = t.w_en;
    r_en = t.r_en;
    
    // Trigger the sampling
    fifo_cg.sample();
  endfunction

endclass