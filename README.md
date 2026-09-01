# Single-Stage Pipeline Register

SystemVerilog implementation and verification of a single-stage pipeline
register using a standard valid/ready handshake.

## Overview

The design implements a one-entry elastic buffer between an input and
output interface.

The module:

- Accepts input data when `in_valid && in_ready` is asserted.
- Presents stored data when `out_valid` is asserted.
- Supports output backpressure using `out_ready`.
- Holds valid data stable while the downstream interface is not ready.
- Supports simultaneous output consumption and input acceptance without
  introducing a bubble.
- Resets to an empty state.
- Is fully synthesizable.

## Interface

| Signal | Direction | Description |
|--------|-----------|-------------|
| `in_clk` | Input | Clock |
| `in_rst_n` | Input | Active-low asynchronous reset |
| `in_valid` | Input | Indicates valid input data |
| `in_ready` | Output | Indicates the buffer can accept input |
| `in_data` | Input | Input data |
| `out_valid` | Output | Indicates valid output data |
| `out_ready` | Input | Indicates downstream is ready |
| `out_data` | Output | Output data |

## Design Behavior

The buffer contains two pieces of state:

- `data_reg` stores the input data.
- `valid_reg` indicates whether the buffer contains valid data.

The input is accepted when:

`in_valid && in_ready`

The output is consumed when:

`out_valid && out_ready`

The input ready signal is generated as:

`in_ready = ~valid_reg || out_ready`

This allows a new input to replace the current output in the same
clock cycle when the current output is being consumed.

## Verification

The testbench includes directed and randomized tests covering:

- Reset behavior
- Basic data transfer
- Backpressure
- Data stability while stalled
- Simultaneous input/output transfer
- Input acceptance with an empty buffer
- Attempted write while the buffer is full and blocked
- Read attempt while the buffer is empty
- Continuous traffic
- Randomized backpressure

A SystemVerilog queue-based scoreboard is used to verify that accepted
input transactions emerge at the output without data loss, duplication,
or reordering.

The testbench was also validated using intentional DUT fault injection
to confirm that the scoreboard detects incorrect output data.

The design was also successfully synthesized using Vivado 2024.1 for
the Xilinx Artix-7 `xc7a100tcsg324-1` device with zero synthesis errors.

## Files

- `rtl/SSPR.sv` - Synthesizable RTL
- `tb/SSPR_TB.sv` - SystemVerilog testbench
