// dv/tb_top/tb_top.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

// Import your Agents and Env (if using packages)
// import fifo_pkg::*; 

module tb_top;

  // 1. Signal Declaration
  logic w_clk, r_clk;
  logic rst_n;

  // 2. Interface Instantiation
  fifo_if intf(w_clk, r_clk, rst_n);

  // 3. DUT Instantiation 
  async_fifo DUT (
    .w_clk   (intf.w_clk),
    .w_rst_n (intf.rst_n),
    .w_en    (intf.w_en),
    .w_data  (intf.wdata),
    .w_full  (intf.w_full),
    
    .r_clk   (intf.r_clk),
    .r_rst_n (intf.rst_n),
    .r_en    (intf.r_en),
    .r_data  (intf.rdata),
    .r_empty (intf.r_empty)
  );

  // 4. Clock Generation (Async Frequencies)
  initial begin
    w_clk = 0;
    forever #5 w_clk = ~w_clk; // 100 MHz (Period 10ns)
  end

  initial begin
    r_clk = 0;
    forever #7 r_clk = ~r_clk; // ~71 MHz (Period 14ns)
  end

  // 5. Reset Generation
  initial begin
    rst_n = 0;
    repeat(10) @(posedge w_clk); // Hold reset for 10 cycles
    rst_n = 1;
  end

  // 6. UVM Startup
  initial begin
    // Pass Interface to UVM Config DB
    // "null" = Global Scope
    // "*"    = Accessible by all components
    // "vif"  = The Key name used in Drivers/Monitors
    uvm_config_db#(virtual fifo_if)::set(null, "*", "vif", intf);
    
    // Dump Waves (Standard for Debugging)
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
    
    // Run the Test
    run_test("fifo_base_test");
  end

endmodule