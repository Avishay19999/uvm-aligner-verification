# Architecture Overview

## Purpose

This project verifies an Aligner DUT using a UVM-based environment.

The DUT is configured through APB register accesses and processes data entering from the MD RX side. The expected output behavior is predicted by a reference model and compared against monitored MD TX traffic by the scoreboard.

---

## Block-Level Architecture

```text
                 +----------------------+
                 |        Test          |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 |  Virtual Sequence    |
                 +----------+-----------+
                            |
          +-----------------+------------------+
          |                                    |
          v                                    v
   +-------------+                      +-------------+
   |  APB Agent  |                      | MD RX Agent |
   +------+------+                      +------+------+
          |                                    |
          v                                    v
   Register Model /                       DUT RX Input
   DUT Registers                                |
                                                v
                                      +------------------+
                                      |   Aligner DUT    |
                                      +---------+--------+
                                                |
                                                v
                                         DUT TX Output
                                                |
                                                v
                                       +----------------+
                                       | MD TX Monitor  |
                                       +--------+-------+
                                                |
                                                v
                                       +----------------+
                                       |   Scoreboard   |
                                       +--------+-------+
                                                ^
                                                |
                                       +----------------+
                                       | Reference Model|
                                       +----------------+
```

---

## Main Layers

### Test Layer

The test layer selects the relevant scenario and starts a virtual sequence.

### Virtual Sequence Layer

The virtual sequence coordinates lower-level APB and MD sequences.

### APB Agent

Responsible for register-level bus activity:
- APB driver
- APB monitor
- APB coverage
- APB register adapter

### MD Agent

Responsible for stream-style data traffic:
- master/slave behavior
- monitor collection
- protocol/data coverage
- sequencer and sequence infrastructure

### Register Model

Models the DUT register map:
- `CTRL`
- `STATUS`
- `IRQEN`
- `IRQ`

### Reference Model

Predicts expected DUT output based on RX input and register configuration.

### Scoreboard

Compares expected model output with actual TX monitor output.

### Coverage

Collects APB, MD, and Aligner-level coverage.

---

## Debug Methodology

Suggested debug order:

1. Check the selected test and virtual sequence.
2. Check APB register configuration.
3. Check RX monitor transactions.
4. Check reference model predictions.
5. Check TX monitor transactions.
6. Check scoreboard mismatch details.
7. Check coverage to understand whether the scenario was exercised.

---

## Repository Scope

This repository contains the verification environment only.  
The DUT RTL files are intentionally not included because they were provided separately as part of course material.
