# UVM Aligner Verification — Logs Manifest

This document describes the curated simulation logs used as reference examples for the UVM Aligner Verification project and for a future AI-based UVM log triage/debug tool.

The purpose of this log set is to teach the AI how to understand different UVM log patterns: PASS runs, expected error/drop behavior, APB/register access, infrastructure failures, and functional scoreboard mismatches.

---

## Log Set Overview

| # | File | Status | Category |
|---|------|--------|----------|
| 01 | `01_random_pass_split_scoreboard_coverage_seed_1584539207.log` | PASS | Random data path, split, scoreboard, coverage |
| 02 | `02_rx_err_drop_pass_cnt_drop_coverage_seed_-1744703579.log` | PASS | RX error/drop, CNT_DROP, RX scoreboard |
| 03 | `03_reg_access_pass_apb_mapped_unmapped_coverage_seed_-278275300.log` | PASS | APB mapped/unmapped register access |
| 04 | `04_fail_no_vif_config_db_instance_path_seed_397003325.log` | FAIL | UVM config_db / virtual interface failure |
| 05 | `05_fail_scoreboard_tx_data_mismatch_seed_-546431789.log` | FAIL | Scoreboard TX data mismatch |

---

## 01 — Random PASS: Split + Scoreboard + Coverage

**Test:** `algn_test_random`  
**Seed:** `1584539207`  
**Status:** PASS  
**Expected AI classification:** `RANDOM_PASS_WITH_SPLIT_AND_SCOREBOARD`

### What it demonstrates

- APB configuration of the Aligner DUT
- RX MD traffic entering the DUT
- Reference model RX decisions
- Split behavior using `CTRL.SIZE` and `CTRL.OFFSET`
- TX expected output from the reference model
- TX actual output from the monitor
- Scoreboard RX match
- Scoreboard TX data/offset match
- Functional coverage summary

### Main signature

```text
APB_MONITOR
-> MODEL_RX_DECISION
-> MODEL_SPLIT
-> SCOREBOARD_EXPECTED_TX
-> SCOREBOARD_ACTUAL_TX
-> SCOREBOARD_MATCH_TX_DATA_OFFSET
-> COVERAGE
```

### Expected AI interpretation

This is a clean passing data-path run. The DUT receives RX traffic, the reference model predicts the expected aligned/split TX output, the TX monitor observes the actual output, and the scoreboard confirms that TX data/offset match.

---

## 02 — RX Error / Drop PASS

**Test:** `algn_test_random_rx_err`  
**Seed:** `-1744703579`  
**Status:** PASS  
**Expected AI classification:** `RX_ERR_DROP_PASS`

### What it demonstrates

- RX transactions expected to produce `MD_ERR`
- Reference model classifies RX items as `expected_response=MD_ERR`
- `CNT_DROP` increments
- RX monitor observes actual `MD_ERR`
- Scoreboard confirms expected RX response equals actual RX response
- Coverage summary is printed

### Main signature

```text
MODEL_RX_DECISION expected_response=MD_ERR
-> CNT_DROP
-> SCOREBOARD_EXPECTED_RX
-> SCOREBOARD_ACTUAL_RX
-> SCOREBOARD_MATCH_RX
```

### Expected AI interpretation

This is not a failure. The test intentionally creates RX error/drop cases. The expected behavior is `MD_ERR`, the DUT returns `MD_ERR`, the scoreboard confirms it, and `CNT_DROP` increments.

---

## 03 — Register Access PASS

**Test:** `algn_test_reg_access`  
**Seed:** `-278275300`  
**Status:** PASS  
**Expected AI classification:** `REG_ACCESS_PASS_MAPPED_UNMAPPED_APB`

### What it demonstrates

- APB read/write transactions
- Legal mapped register accesses
- Illegal/unmapped register accesses
- `APB_OKAY` for valid accesses
- `APB_ERR` for unmapped accesses
- APB address, data, direction, and response visibility
- APB coverage summary

### Main signature

```text
APB_MONITOR
-> APB_READ / APB_WRITE
-> mapped address:   APB_OKAY
-> unmapped address: APB_ERR
-> APB coverage
```

### Expected AI interpretation

This is a clean APB/register-access test. `APB_ERR` is expected for unmapped addresses and should not be classified as a test failure.

---

## 04 — FAIL: NO_VIF / config_db Error

**Test:** `algn_test_random`  
**Seed:** `397003325`  
**Status:** FAIL  
**Expected AI classification:** `NO_VIF_CONFIG_DB_FAILURE`

### What it demonstrates

- UVM infrastructure/configuration failure
- Failure occurs at time 0
- APB agent cannot retrieve virtual interface
- Report ID: `[NO_VIF]`
- Failure is not related to DUT functionality

### Main signature

```text
UVM_FATAL
-> [NO_VIF]
-> Could not get from the database the virtual interface using name "vif"
-> uvm_test_top.env.apb_agent_h
```

### Expected AI interpretation

This is a UVM testbench/configuration issue, not a DUT bug. The likely cause is a mismatch between the `uvm_config_db::set` path and the actual APB agent instance path.

### Recommended debug direction

Check:

- `uvm_config_db::set(...)` path in `testbench.sv`
- APB agent instance name in `algn_env.sv`
- Virtual interface name `"vif"`
- UVM hierarchy path printed in the fatal message

---

## 05 — FAIL: Scoreboard TX Data Mismatch

**Test:** `algn_test_random`  
**Seed:** `-546431789`  
**Status:** FAIL  
**Expected AI classification:** `SCOREBOARD_TX_DATA_MISMATCH`

### What it demonstrates

- Simulation reaches the data path
- Reference model generates expected TX item
- TX monitor observes actual TX item
- Scoreboard compares expected vs. actual TX data
- Scoreboard detects mismatch
- Simulation stops after one `UVM_ERROR`

### Main signature

```text
SCOREBOARD_EXPECTED_TX
-> SCOREBOARD_ACTUAL_TX
-> UVM_ERROR [DUT_ERROR_TX_DATA]
-> expected data != received data
```

### Failure evidence

| Field | Value |
|---|---|
| Expected TX data | `'h05` |
| Received TX data | `'h04` |
| Error ID | `DUT_ERROR_TX_DATA` |
| Severity | `UVM_ERROR` |
| UVM_FATAL | 0 |

### Expected AI interpretation

This is a functional verification failure. The scoreboard detected a TX data mismatch after the simulation reached the DUT data path.

### Recommended debug direction

Check:

- Reference model expected TX generation
- DUT align/split behavior
- `CTRL.SIZE`
- `CTRL.OFFSET`
- TX monitor observation
- Scoreboard comparison logic

---

## AI Learning Goal

This log set should help the AI distinguish between:

**Clean PASS**
- `UVM_ERROR : 0`
- `UVM_FATAL : 0`
- Scoreboard match
- Coverage printed

**Expected RX error/drop behavior**
- `MODEL_RX_DECISION expected_response=MD_ERR`
- `CNT_DROP` increments
- `SCOREBOARD_MATCH_RX`
- Still PASS

**Legal vs. illegal APB access**
- Mapped register access → `APB_OKAY`
- Unmapped register access → `APB_ERR`
- Still PASS if expected by the test

**Infrastructure failure**
- `UVM_FATAL`
- `NO_VIF`
- `config_db` / virtual interface issue
- Failure at time 0

**Functional failure**
- `UVM_ERROR`
- Scoreboard mismatch
- Expected != actual
- Simulation reaches data path before failing

---

## Recommended Folder Structure

```
docs/
  logs/
    logs_manifest.md
    pass/
      01_random_pass_split_scoreboard_coverage_seed_1584539207.log
      02_rx_err_drop_pass_cnt_drop_coverage_seed_-1744703579.log
      03_reg_access_pass_apb_mapped_unmapped_coverage_seed_-278275300.log
    fail/
      04_fail_no_vif_config_db_instance_path_seed_397003325.log
      05_fail_scoreboard_tx_data_mismatch_seed_-546431789.log
```

---

## Final Note

This is a small curated reference set, not a full industrial regression database.

Its purpose is to provide clear, labeled, high-signal examples for:

- Project explanation
- Portfolio evidence
- AI log triage MVP development
- Future log parsing and classification tests