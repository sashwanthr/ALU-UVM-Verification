# ALU UVM Verification

A complete **Universal Verification Methodology (UVM)** testbench for an 8-bit Arithmetic Logic Unit (ALU), simulated with **QuestaSim 2025.2**.

---

## Overview

| Property | Value |
|---|---|
| DUT | 8-bit ALU (Add / Subtract / AND) |
| Methodology | UVM 1.2 |
| Simulator | QuestaSim 2025.2 |
| Language | SystemVerilog |
| Test result | ✅ 10 transactions — 0 Errors, 0 Warnings |

---

## Supported Operations

| Opcode | Operation | Expression |
|--------|-----------|------------|
| `3'b000` | Addition | `result = A + B` |
| `3'b001` | Subtraction | `result = A - B` |
| `3'b010` | Bitwise AND | `result = A & B` |
| `3'bxxx` | Default | `result = 8'd0` |

---

## Repository Structure

```
alu_uvm_verification/
├── rtl/
│   ├── design.sv        # ALU DUT (combinational, 8-bit)
│   └── alu_if.sv        # SystemVerilog interface
├── tb/
│   └── testbench.sv     # Full UVM testbench (all layers)
├── sim/
│   ├── run_questa.sh    # QuestaSim shell script
│   └── qrun_sample.log  # Sample passing simulation log
├── docs/
│   └── (architecture diagrams — optional)
├── Makefile
├── .gitignore
└── README.md
```

---

## UVM Architecture

```
uvm_test  (alu_test)
  └── uvm_env  (alu_env)
        ├── uvm_agent  (alu_agent)
        │     ├── uvm_sequencer  ← alu_sequence feeds txns
        │     ├── alu_driver     ← drives vif signals
        │     └── alu_monitor    ← captures vif → analysis port
        └── alu_scoreboard       ← checks expected vs actual
```

### Component Descriptions

| Component | Role |
|---|---|
| `alu_seq_item` | Randomised transaction: `A`, `B`, `opcode`, `result` |
| `alu_sequence` | Generates 10 randomised transactions |
| `alu_driver` | Applies transaction to DUT via virtual interface |
| `alu_monitor` | Samples DUT outputs and writes to analysis port |
| `alu_scoreboard` | Computes expected result; logs PASS / FAIL |
| `alu_agent` | Bundles driver + monitor + sequencer |
| `alu_env` | Connects agent's monitor to scoreboard |
| `alu_test` | Top-level test; starts sequence on agent's sequencer |

---

## Quick Start

### Prerequisites

- QuestaSim 2025.x (or compatible)
- UVM 1.2 (bundled with QuestaSim)

### Run with Makefile

```bash
git clone https://github.com/<your-username>/alu_uvm_verification.git
cd alu_uvm_verification
make sim
```

### Run manually

```bash
cd sim
chmod +x run_questa.sh
./run_questa.sh
```

### Run with qrun directly

```bash
qrun -batch -access=rw+/. -uvmhome uvm-1.2 \
  -timescale 1ns/1ns -mfcu \
  rtl/design.sv tb/testbench.sv \
  '-voptargs=+acc=npr' \
  -do "run -all; exit"
```

---

## Sample Output

```
UVM_INFO @ 6000:   [SCOREBOARD] PASS A=57  B=233 opcode=1 expected=80  actual=80
UVM_INFO @ 26000:  [SCOREBOARD] PASS A=90  B=85  opcode=0 expected=175 actual=175
UVM_INFO @ 46000:  [SCOREBOARD] PASS A=97  B=253 opcode=2 expected=97  actual=97
...
--- UVM Report Summary ---
UVM_INFO    : 24
UVM_WARNING :  0
UVM_ERROR   :  0
UVM_FATAL   :  0
```

All 10 transactions pass with **0 errors**.

---

## Waveform Viewing

The simulation generates `dump.vcd`. Open it with any VCD-compatible viewer:

```bash
# GTKWave (free)
gtkwave dump.vcd

# QuestaSim EPWave (built-in)
# File → Open → dump.vcd
```

---

## Extending the Testbench

| Goal | How |
|---|---|
| Add OR / XOR / NOT | Extend `alu_seq_item` opcode constraint and `alu_scoreboard` case |
| More transactions | Change `repeat(10)` in `alu_sequence::body()` |
| Directed tests | Add a new `uvm_sequence` subclass with fixed values |
| Coverage | Add a `uvm_covergroup` in the monitor or scoreboard |
| Functional coverage | Use `coverpoint` on opcode, A, B bins |

---

## License

MIT — free to use, modify, and distribute.
