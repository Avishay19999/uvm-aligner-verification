# UVM Environment Architecture – Aligner DUT

## Overview

The verification environment is built to validate an **Aligner DUT**, which receives data on the RX side, processes it according to configuration registers, and produces aligned/split/filtered output on the TX side.

The environment generates stimulus, monitors actual DUT behavior, predicts expected results using a reference model, and compares them using a scoreboard, while collecting functional coverage.

---

## High-Level Flow

```text
Test
  |
  v
Virtual Sequence
  |
  v
Virtual Sequencer
  |------------------------------|
  |                              |
  v                              v
APB / Register Sequence      MD RX Sequence
  |                              |
  v                              v
APB Agent                    MD RX Agent
  |                              |
  v                              |---- observed RX items ----|
Register Model / DUT Regs        |                         |
  |                              v                         v
  |                         DUT RX Input            Reference Model
  |                              |              RX FIFO / Model / TX FIFO
  |                              v                         |
  +-----------------------> Aligner DUT                    |
       config/status             |                         |
                                 v                         v
                           DUT TX Output          Expected TX items
                                 |                         |
                                 v                         |
                            MD TX Monitor                 |
                                 |                         |
                                 v                         v
                              Scoreboard <-----------------
                         actual TX vs expected TX

Coverage samples:
- APB monitor transactions
- MD RX monitor transactions
- MD TX monitor transactions
- reset / drop / status-related scenarios
```

---

## Main Components

### Test

Top-level control of the simulation.
Responsible for:

* Building the environment
* Configuring parameters
* Running Virtual Sequences

---

### Virtual Sequence & Virtual Sequencer

The **Virtual Sequence** defines full test scenarios:

* Register configuration
* RX stimulus
* Timing / delay behavior
* Error injection

The **Virtual Sequencer** provides access to:

* APB sequencer
* RX sequencer
* Other control channels

---

### APB Agent & Register Model

Handles DUT configuration via registers.

* APB Driver writes to DUT registers
* Register Model (RAL) mirrors DUT state
* Controls behavior such as:

  * alignment size
  * enable flags
  * status / IRQ / counters

---

### MD RX Agent (Input Path)

Responsible for injecting data into the DUT.

Flow:

* Sequence generates transactions
* Driver converts them into signals
* DUT receives RX input

The RX Monitor captures **what actually entered the DUT**.

---

### DUT (Aligner)

Processes incoming data:

* Alignment
* Split
* Drop (illegal/invalid cases)
* Status / counters / IRQ updates

---

### MD TX Monitor (Output Path)

Captures actual DUT output.

Important:

* Does not assume correctness
* Only records real DUT behavior

---

### Reference Model

Predicts expected DUT behavior.

Input:

* Observed RX transactions (from RX monitor)
* Register configuration

Internal behavior:

* RX FIFO / queues
* Alignment / split / drop logic
* TX expected generation

Output:

* Expected TX items/events

---

### Scoreboard

Compares:

* Actual TX output (from TX monitor)
* Expected TX output (from Reference Model)

Handles:

* Non 1:1 input/output mapping
* Out-of-order / delayed outputs

Reports:

* Match → PASS
* Mismatch → ERROR

---

### Coverage

Measures verification completeness.

Collected from:

* APB activity
* RX traffic
* TX behavior
* Reset / drop / status scenarios

---

## Key Concepts

### Stream-Based Verification

No strict 1:1 mapping between input and output:

* One input may produce multiple outputs (split)
* Multiple inputs may combine
* Some inputs may be dropped

---

### FIFO / Queue Usage

Used to:

* Handle latency
* Track expected vs actual streams
* Maintain ordering

---

### Reset Awareness

Environment handles reset by:

* Stopping drivers safely
* Clearing model/scoreboard queues
* Ignoring invalid data during reset

---

### Error / Drop Handling

Illegal inputs should:

* Not produce TX output
* Increment drop counters
* Be validated by scoreboard

---

## Summary

This UVM environment verifies the full data lifecycle:

Stimulus → DUT processing → Monitoring → Prediction → Comparison → Coverage

It ensures correctness across:

* Functional behavior
* Error handling
* Timing / streaming behavior
* Configuration-dependent logic
