# IEEE Standard 754 Floating Point Numbers Multiplier

IEEE 754 Double Precision Floating Point Multiplier implemented in Verilog HDL.

This project implements a 64-bit floating point multiplier based on the IEEE 754 standard, including RTL design, synthesis, APR flow, gate-level simulation, and post-layout verification.


# Table of Contents

- [Repository Layout](#repository-layout)
- [Architecture](#architecture)
- [Multi-Cycle Architecture](#multi-cycle-architecture)
- [System Organization](#system-organization)
- [Core Architecture](#core-architecture)
- [Implementation Status](#implementation-status)
- [Implemented](#implemented)
- [Not Implemented](#not-implemented)
- [Simulation & Verification](#simulation--verification)
- [Test Result Summary](#test-result-summary)
- [Detailed Log](#detailed-log)
- [Reference](#reference)


# Repository Layout

```text
├── RTL/
├── Testbench/
├── Netlist/
├── Synthesis/
├── APR/
├── Simulation/
└── README.md
```


# Architecture

## Floating Point Multiplier Architecture

```text
Input Buffer
     ↓
Sign Processing
     ↓
Exponent Calculation
     ↓
Mantissa Shift-Add Multiplication
     ↓
Normalization & Rounding
     ↓
Output Buffer
```



# Multi-Cycle Architecture

The design adopts a counter-based multi-cycle architecture.

The operation is divided into:

- Input stage
- Computation stage
- Output stage

This architecture reduces combinational delay and improves timing closure.



# System Organization

## IEEE 754 Double Precision Format

| Field | Bits |
|------|------|
| Sign | 1 |
| Exponent | 11 |
| Fraction | 52 |

Bias value:

```text
Bias = 1023
```

Supported special cases:

- Zero
- Infinity
- NaN
- Normal numbers

# Core Architecture

## Sign Processing

The sign bit is generated using XOR operation.

```verilog
sign = A.sign ^ B.sign;
```

## Exponent Calculation

Exponent calculation includes exponent addition and bias correction.

```verilog
exp = A.exp + B.exp - Bias;
```

## Mantissa Multiplication

The mantissa multiplication is implemented using a shift-add architecture.

Instead of using a large combinational multiplier, the multiplication is distributed across multiple clock cycles to reduce critical path delay.

Features:

- Multi-cycle shift-add operation
- Reduced hardware complexity
- Improved synthesis timing
- Easier timing closure

## Interface

### Input Ports

| Signal | Description |
|------|------|
| CLK | System clock |
| RESET | Synchronous active-high reset |
| ENABLE | Enable signal |
| DATA_IN[7:0] | Serial input data |

### Output Ports

| Signal | Description |
|------|------|
| DATA_OUT[7:0] | Serial output data |
| READY | Output valid signal |

# Implementation Status

# Implemented

- IEEE 754 double precision multiplication
- Sign processing
- Exponent calculation
- Mantissa shift-add multiplication
- Multi-cycle architecture
- RTL simulation
- Gate-level simulation
- Timing constraint setup
- Synthesis flow
- Low-power optimization
- APR flow
- Post-layout simulation
- DRC verification
- LVS verification

# Not Implemented

- Floating point addition
- Floating point division
- Pipelined architecture
- Exception handling optimization
- IEEE 754 rounding mode selection
- Denormal number optimization

# Simulation & Verification

## RTL Simulation

Functional verification includes:

- IEEE 754 floating point multiplication
- Waveform verification
- Special case handling
- Multi-cycle operation validation

## Gate-Level Simulation

Gate-level simulation was performed after synthesis to verify:

- Functional correctness
- Timing correctness
- Netlist equivalence

## Post-Layout Simulation

Post-layout simulation verified:

- Functional correctness after APR
- Timing correctness after layout

# Test Result Summary

## Timing Constraint

Target frequency:

```text
2.0 GHz
```

## Low Power Optimization Comparison

| Configuration | Power | Area | Timing Slack |
|------|------|------|------|
| Without Low-Power Synthesis | 9.70237e-03 | 2854.155 | 500 ps |
| With Low-Power Synthesis | 1.19986e-03 | 2709.780 | 490 ps |

## Verification Result

| Verification | Status |
|------|------|
| RTL Simulation | PASS |
| Gate-Level Simulation | PASS |
| Post-Layout Simulation | PASS |
| DRC | PASS |
| LVS | PASS |

# Detailed Log

## Synthesis

Generated reports include:

- Timing report
- Area report
- Power report

## APR Flow

Completed physical implementation flow:

- Floorplanning
- Placement
- Clock Tree Synthesis (CTS)
- Routing

## Physical Verification

Completed:

- DRC (Design Rule Check)
- LVS (Layout Versus Schematic)

# Reference

- IEEE 754 Floating Point Standard
- Floating Point Multiplier Architecture
- Open-source IEEE754 floating point multiplier references

# Author

Wu Shan-Cheng  
National Taipei University  
Computer Science & Information Engineering