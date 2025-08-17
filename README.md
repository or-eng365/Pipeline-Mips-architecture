# Pipeline-Mips-architecture
In this lab we designed Pipline MIPS architecture based on the theory that learned in class



# MIPS Processor Design

This repository contains the VHDL source code for a pipelined MIPS processor. The design is modular, with different components of the processor implemented in separate VHDL files.

## Project Structure

The main directories are:

*   **DUT (Device Under Test):** Contains the core VHDL source files for the MIPS processor.
*   **TB (Testbench):** Contains the VHDL testbench (`tb_sc_mips.vhd`) for simulating and verifying the MIPS processor.

## DUT (Device Under Test) Modules

The `DUT` directory includes the following VHDL modules:

*   **`MIPS.vhd`**: This is the top-level entity of the MIPS processor. It instantiates and connects all the other pipeline stages and components of the processor.
*   **`IFETCH.vhd`**: The Instruction Fetch (IF) stage. Responsible for fetching the next instruction from the instruction memory based on the Program Counter (PC).
*   **`IDECODE.vhd`**: The Instruction Decode (ID) stage. This module decodes the fetched instruction, reads operands from the register file, and handles sign extension of immediate values. It also manages the Writeback (WB) stage, writing results back to the register file.
*   **`EXECUTE.vhd`**: The Execute (EX) stage. Performs arithmetic and logical operations as specified by the instruction, using an Arithmetic Logic Unit (ALU). It also calculates branch target addresses.
*   **`DMEMORY.vhd`**: The Data Memory (MEM) stage. Handles memory access instructions like Load Word (LW) and Store Word (SW). It reads from or writes to the data memory.
*   **`CONTROL.VHD`**: The Control Unit. Generates all necessary control signals for the datapath based on the instruction's opcode and function code. These signals dictate the operation of other modules in each pipeline stage.
*   **`HAZARD.VHD`**: The Hazard Detection Unit. Implements logic to detect and manage data hazards and control hazards in the pipeline, typically by stalling or flushing the pipeline.
*   **`FORWARD.vhd`**: The Forwarding Unit. Manages data forwarding paths to resolve data hazards by providing results from later pipeline stages to earlier stages that need them, avoiding unnecessary stalls.
*   **`PLL.vhd`**: Phase-Locked Loop. This module is typically used for generating and stabilizing clock signals, especially when targeting FPGA hardware.
*   **`Shifter.vhd`**: A dedicated hardware module for performing shift operations (e.g., SLL, SRL).

### Package Files in DUT

The `DUT` directory also contains several package files:

*   **`aux_package.vhd`**: This package file contains component declarations for all the VHDL entities defined in the `DUT` directory. This allows them to be instantiated in other VHDL files (like the top-level `MIPS.vhd`).
*   **`cond_comilation_package.vhd`** : This package defines constants that are used for conditional compilation. This allows the design to be configured for different environments or targets, such as different simulation tools (e.g., ModelSim) or hardware (e.g., specific FPGA memory blocks like M9K or M4K) by changing constant values.
*   **`const_package.vhd`**: This package defines various constants used throughout the MIPS processor design, most notably the opcodes and function codes for different MIPS instructions. This centralizes these definitions for consistency.

## Library

The `Library` directory contains various subdirectories (EX1, EX2, etc., and test1, test2, etc.) with:
*   Sample C (`.c`) and MIPS assembly (`.asm`) files.
*   Corresponding compiled `ITCM.hex` (Instruction Memory) and `DTCM.hex` (Data Memory) files, which can be loaded into the processor's memories for execution.

## TB (Testbench)

The `TB` directory houses:
*   **`tb_sc_mips.vhd`**: The primary testbench file used to simulate the MIPS processor. It likely instantiates the top-level `MIPS` entity, provides clock and reset signals, loads a program into the instruction memory, and observes the processor's outputs to verify its correctness.
