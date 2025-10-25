# AXI-x-APB-Bridge
This repository contains a high-performance AXI-to-APB bridge design with a UVM-based verification environment. The bridge enables seamless communication between high-speed AXI masters and APB peripherals, supporting reliable and parallel data transfers.
Features:

AXI-to-APB Interface: Converts AXI transactions to APB protocol with correct timing and handshaking.

High-Speed AXI Transmission: Maintains AXI-level throughput while interfacing with APB peripherals.

Buffer Implementation: Ensures smooth data flow and prevents bottlenecks during high-speed transfers.

Independent Multi-Channel Operation: Supports multiple APB channels operating concurrently.

UVM Testbench: Includes driver, monitor, scoreboard, assertions, and functional coverage to verify protocol correctness and reliability.

Purpose:
Demonstrates hands-on experience in RTL design and verification, protocol bridging, and high-speed digital system implementation suitable for ASIC/FPGA design projects.
