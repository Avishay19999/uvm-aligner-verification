# UVM Environment Architecture – Aligner DUT

## Purpose

This UVM verification environment validates an **Aligner DUT**, which receives data on the RX side, processes it according to register configuration (alignment, split, drop), and produces output on the TX side.

The environment generates stimulus, monitors actual DUT behavior, predicts expected results, compares them, and collects coverage.

---

## Block-Level Architecture

```text id="xq6eqb"
                 +----------------------+
                 |        TEST          |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 |  VIRTUAL SEQUENCE    |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 | VIRTUAL SEQUENCER    |
                 +----------+-----------+
                            |
        +-------------------+-------------------+
        |                                       |
        v                                       v
 +------------------+                  +------------------+
 | APB / REG SEQ    |                  |   MD RX SEQ      |
 +--------+---------+                  +--------+---------+
          |                                       |
          v                                       v
 +------------------+                  +------------------+
 |    APB AGENT     |                  |   MD RX AGENT    |
 +--------+---------+                  +--------+---------+
          |                                       |
          v                                       |---- observed RX ----+
 +---------------------------+                     |                    |
 | REGISTER MODEL / DUT REGS |                     v                    v
 +-------------+-------------+              +-------------+   +------------------+
               |                            | DUT RX INPUT|   | REFERENCE MODEL  |
               |                            +------+------+   | RX FIFO / MODEL  |
               |                                   |          | TX FIFO          |
               v                                   v          +--------+---------+
        +----------------------+         +------------------+           |
        |     ALIGNER DUT      |<--------+   config/control |           |
        +----------+-----------+                                expected TX
                   |                                              |
                   v                                              v
          +----------------------+                      +------------------+
          |    DUT TX OUTPUT     |                      |    SCOREBOARD    |
          +----------+-----------+                      +--------+---------+
                     |                                          ^
                     v                                          |
          +----------------------+                     actual TX |
          |   MD TX MONITOR      |------------------------------+
          +----------------------+
```

---

## Key Components

* **Test / Virtual Sequence**
  Defines full test scenarios and controls stimulus flow.

* **Virtual Sequencer**
  Coordinates multiple sequencers (APB, RX) for synchronized operation.

* **APB Agent & Register Model**
  Configures DUT registers (alignment size, enable, status, counters).

* **MD RX Agent**
  Drives input data into the DUT and monitors actual RX transactions.

* **Aligner DUT**
  Processes input data (alignment, split, drop) based on configuration.

* **MD TX Monitor**
  Captures actual DUT output (TX side).

* **Reference Model**
  Predicts expected DUT behavior using observed RX data and internal logic (FIFO-based).

* **Scoreboard**
  Compares expected TX vs actual TX results.

---

## Coverage

Coverage is collected from:

* APB monitor activity
* MD RX monitor activity
* MD TX monitor activity
* reset / drop / status-related scenarios

---

## Notes

* No strict 1:1 mapping between RX and TX (split / drop / alignment).
* Reference Model uses FIFO/queues to handle streaming behavior.
* Scoreboard compares streams, not single transactions.
* Coverage is independent of the DUT data path.
