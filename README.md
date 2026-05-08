# IEEE Standard 754 Floating Point Multiplier

IEEE 754 double precision floating point multiplier implemented in Verilog HDL.

This project implements a 64-bit floating point multiplier using a counter-based multi-cycle sequential architecture with shift-add mantissa multiplication.

Supported flow:

* RTL simulation
* Gate-level simulation
* Synthesis
* APR implementation
* Post-layout verification
* IR drop / power rail analysis



# Table of Contents

* [Repository Layout](#repository-layout)

* [Architecture](#architecture)

  * [Floating Point Multiplier Architecture](#floating-point-multiplier-architecture)
  * [System Organization](#system-organization)

* [Core Design](#core-design)

  * [IEEE 754 Double Precision Format](#ieee-754-double-precision-format)
  * [Sign Processing](#sign-processing)
  * [Exponent Calculation](#exponent-calculation)
  * [Mantissa Multiplication](#mantissa-multiplication)

* [Verification & Result](#verification--result)

  * [RTL Simulation](#rtl-simulation)
  * [Gate-Level Simulation](#gate-level-simulation)
  * [Timing Constraint](#timing-constraint)
  * [Power Rail Analysis](#power-rail-analysis)

* [Result Summary](#result-summary)

* [Reference](#reference)



# Repository Layout

```text
IEEE-754-Floating-Point-Multiplier/
├── rtl/
│   └── FP_MUL.v                # Floating point multiplier RTL
│
├── img/
│   ├── FP_MUL_architecture.png
│   ├── RTL_simulation.png
│   ├── Netlist_simulation.png
│   └── CHIP_power_analysis.png
│
├── README.md
└── LICENSE
```



# Architecture

## Floating Point Multiplier Architecture

![Architecture](img/FP_MUL_architecture.png)

The design adopts a counter-based multi-cycle datapath architecture.

| Cycle   | Operation                           |
| ------- | ----------------------------------- |
| 0 – 15  | Serial input transmission           |
| 16      | Sign & exponent processing          |
| 17 – 42 | Mantissa shift-add multiplication   |
| 43 – 46 | Partial sum combine & normalization |
| 47 – 53 | Serial output transmission          |


## System Organization

Main components:

* Serial input interface
* Input buffering
* Sign processing
* Exponent calculation
* Shift-add mantissa multiplication
* Normalization
* Serial output interface



# Core Design

## IEEE 754 Double Precision Format

| Field    | Bits |
| -------- | ---- |
| Sign     | 1    |
| Exponent | 11   |
| Fraction | 52   |

Bias value:

```text
Bias = 1023
```

Handled cases:

* Normal number
* Zero
* Infinity
* NaN


## Sign Processing

The sign bit is generated using XOR operation.

```verilog
sign <= total_A[63] ^ total_B[63];
```


## Exponent Calculation

Exponent calculation includes exponent addition and bias correction.

```verilog
exp <= (total_A[62:52] + total_B[62:52]) + 11'b100_0000_0010;
```


## Mantissa Multiplication

Shift-add accumulation across multiple clock cycles:

```verilog
temp1 <= temp1 + (frac_partial_A << n);
temp2 <= temp2 + (frac_partial_A << n);
```

The sequential implementation helps reduce combinational complexity and shorten critical path delay.

Features:

* Multi-cycle shift-add operation
* Reduced hardware complexity
* Improved synthesis timing
* Easier timing closure



# Verification & Result

## RTL Simulation

![RTL Simulation](img/RTL_simulation.png)

RTL simulation passed functional verification.


## Gate-Level Simulation

![Gate-Level Simulation](img/Netlist_simulation.png)

Gate-level simulation passed post-synthesis verification.


## Timing Constraint

```text
Target Clock Period : 0.4 ns
Target Frequency    : 2.5 GHz
```

The design was synthesized using SDC timing constraints.


## Power Rail Analysis

![Power Analysis](img/CHIP_power_analysis.png)

IR drop and power rail analysis were performed after APR implementation.



# Result Summary

| Verification            | Status  |
| ----------------------- | ------- |
| RTL Simulation          | PASS    |
| Gate-Level Simulation   | PASS    |
| Functional Verification | PASS    |
| IR Drop Check           | PASS    |
| DRC                     | PASS    |
| LVS                     | MATCHED |

