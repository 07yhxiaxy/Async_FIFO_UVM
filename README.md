# Asynchronous FIFO Design & UVM Verification

![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-blue)
![UVM](https://img.shields.io/badge/Verification-UVM-green)
![Status](https://img.shields.io/badge/Status-Pending-brightgreen)

## 📌 Project Overview
This repository contains a synthesizable **Asynchronous FIFO** (First-In, First-Out) memory design and a complete **UVM (Universal Verification Methodology)** testbench.

The design handles **Clock Domain Crossing (CDC)** using Gray code synchronization for read/write pointers. The verification environment is structured to verify data integrity, full/empty flag generation, and corner cases using constrained random stimulus and functional coverage.

## 🏗️ Design Architecture
* **Depth:** Paremeterized, default to 16 words
* **Width:** Paremeterized, default to 8 bits
* **Synchronization:** 2-stage D-Flip-Flop synchronizers with Gray-to-Binary conversion.
* **Memory:** Dual-port RAM inference.

> **[Insert Block Diagram Image Here]**
> *(Pending: Use Draw.io or Visio to draw the FIFO w/ pointers and synchronizers)*

## 🧪 Verification Environment (UVM)
The testbench follows a modular UVM architecture with separated Write and Read agents.

### Key Components:
* **Agents:**
    * `write_agent`: Drives `w_en` and random `w_data`. Monitors the Write Interface.
    * `read_agent`: Drives `r_en` with random delays. Monitors the Read Interface.
* **Scoreboard:** Implements a TLM-based Golden Model (Queue) to check data integrity (Data In == Data Out).
* **Assertions (SVA):**
    * `ASSERT_FULL_NO_WRITE`: Ensures no data is written when FIFO is full.
    * `ASSERT_EMPTY_NO_READ`: Ensures no data is read when FIFO is empty.
    * `ASSERT_GRAY_ENCODING`: Checks that pointers only change by 1 bit at a time.
* **Functional Coverage:**
    * `covergroup_flags`: Cross coverage of Full/Empty flags with Read/Write enables.
    * `covergroup_pointers`: Ensures all pointer values are visited.

## 📂 Directory Structure
```text
Async_FIFO_UVM/
├── docs/          # Spec and Verification Plan
├── rtl/           # Synthesizable SystemVerilog (FIFO, Gray Syncs)
├── dv/            # UVM Agents, Env, Tests, Sequences
├── scripts/       # Makefiles and Run Scripts
└── sim/           # Simulation artifacts (logs, waves)
