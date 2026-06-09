# IEEE Standard 754 Floating Point Multiplier

IEEE 754 double precision floating point multiplier implemented in synthesizable
Verilog HDL.

The public repository focuses on the RTL design, RTL testbench, and documented
results. Course documents, proprietary EDA setup files, generated netlists, and
process-dependent implementation files are intentionally not included.


# Table of Contents

* [Repository Layout](#repository-layout)
* [Architecture](#architecture)
  * [Floating Point Multiplier Architecture](#floating-point-multiplier-architecture)
  * [System Organization](#system-organization)
  * [I/O Interface](#io-interface)
* [Core Design](#core-design)
  * [IEEE 754 Double Precision Format](#ieee-754-double-precision-format)
  * [Design Assumption](#design-assumption)
  * [Sign Processing](#sign-processing)
  * [Exponent Calculation](#exponent-calculation)
  * [Mantissa Multiplication](#mantissa-multiplication)
  * [Output Range Handling](#output-range-handling)
* [Verification & Result](#verification--result)
  * [RTL Simulation](#rtl-simulation)
  * [Randomized Testbench](#randomized-testbench)
  * [Gate-Level Simulation](#gate-level-simulation)
  * [Timing Constraint](#timing-constraint)
  * [Power Rail Analysis](#power-rail-analysis)
* [Result Summary](#result-summary)


# Repository Layout

```text
IEEE-754_FP_Multiplier/
├── rtl/
│   └── FP_MUL.v
├── tb/
│   └── tb_FP_MUL.v
├── img/
├── README.md
└── LICENSE
```


# Architecture

## Floating Point Multiplier Architecture

![Architecture](img/FP_MUL_architecture.png)

The design uses a counter-based multi-cycle datapath. Operands are received
through an 8-bit serial input interface, processed internally as 64-bit IEEE 754
double precision values, and returned through an 8-bit serial output interface.

| Stage | Description |
| --- | --- |
| Input | Receive operand A and operand B byte by byte |
| Operation | Process sign, exponent, mantissa multiplication, normalization, and rounding |
| Output | Send the 64-bit result byte by byte |


## System Organization

Main blocks:

* Serial input and output interface
* Input byte buffer
* Sign and exponent logic
* Shift-add mantissa multiplier
* Normalization, rounding, and range handling


## I/O Interface

Top module:

```verilog
module FP_MUL(CLK, RESET, ENABLE, DATA_IN, DATA_OUT, READY);
```

| Port | Direction | Width | Description |
| --- | --- | --- | --- |
| `CLK` | Input | 1 | Clock |
| `RESET` | Input | 1 | Active-high synchronous reset |
| `ENABLE` | Input | 1 | Input byte valid |
| `DATA_IN` | Input | 8 | Input byte |
| `DATA_OUT` | Output | 8 | Output byte |
| `READY` | Output | 1 | Output byte valid |

Both input operands and output result are transferred lower byte first.


# Core Design

## IEEE 754 Double Precision Format

| Field | Bits |
| --- | --- |
| Sign | 1 |
| Exponent | 11 |
| Fraction | 52 |

Bias:

```text
1023
```


## Design Assumption

The RTL assumes both input operands are legal finite normal double precision
numbers. NaN, infinity, zero, and subnormal inputs are not decoded as separate
input classes.

Output range handling is implemented for multiplication results:

| Condition | Output |
| --- | --- |
| Normal range | Normal IEEE 754 result |
| Overflow | Signed infinity |
| Underflow | Signed zero |


## Sign Processing

The result sign is derived from the two input sign bits.

```verilog
sign <= total_A[63] ^ total_B[63];
```


## Exponent Calculation

The exponent path performs exponent addition, bias correction, normalization
adjustment, and range checking.


## Mantissa Multiplication

The mantissa product is calculated with multi-cycle shift-add accumulation
instead of one large combinational multiplier.


## Output Range Handling

Before output, the final exponent is checked for overflow and underflow. Normal
results are rounded and serialized to `DATA_OUT`.


# Verification & Result

## RTL Simulation

![RTL Simulation](img/RTL_simulation.png)

Run RTL simulation with Icarus Verilog:

```powershell
iverilog -g2012 -Wall -o tb\tb_FP_MUL.vvp rtl\FP_MUL.v tb\tb_FP_MUL.v
vvp tb\tb_FP_MUL.vvp
```


## Randomized Testbench

The testbench is located at:

```text
tb/tb_FP_MUL.v
```

Coverage includes directed normal tests, legal-input overflow/underflow cases,
randomized normal-number tests, `READY` pulse checking, and byte-order checking.

Plusargs:

```powershell
vvp tb\tb_FP_MUL.vvp +SEED=1234 +RANDOM_COUNT=1000
```

Latest RTL result:

```text
Directed normal tests: PASS
Output range tests with legal inputs: PASS
Random normal tests: 100 passed, 0 failed
Summary: 108 passed, 0 failed
```


## Gate-Level Simulation

![Gate-Level Simulation](img/Netlist_simulation.png)

Gate-level simulation was completed in the original project flow. The generated
netlist and process-dependent setup files are not included in this public repo.


## Timing Constraint

Original implementation target:

```text
Target Clock Period : 0.4 ns
Target Frequency    : 2.5 GHz
```


## Power Rail Analysis

![Power Analysis](img/CHIP_power_analysis.png)

Power rail analysis was completed in the original APR flow. Tool databases,
reports, and process-dependent files are not included.


# Result Summary

| Item | Status |
| --- | --- |
| RTL syntax check | PASS |
| RTL directed tests | PASS |
| RTL output range tests | PASS |
| RTL randomized tests | PASS |
| Gate-level simulation | Completed in original flow |
| APR / power rail analysis | Completed in original flow |
