#!/usr/bin/env bash
# =============================================================
# run_questa.sh — Compile & simulate ALU UVM TB with QuestaSim
# =============================================================
# Usage:
#   chmod +x sim/run_questa.sh
#   cd sim && ./run_questa.sh
# =============================================================

set -e

SIM_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SIM_DIR")"

RTL_DIR="$ROOT_DIR/rtl"
TB_DIR="$ROOT_DIR/tb"

echo "============================================"
echo "  ALU UVM Verification — QuestaSim Flow"
echo "============================================"

qrun -batch \
  -access=rw+/. \
  -uvmhome uvm-1.2 \
  -timescale 1ns/1ns \
  -mfcu \
  "$RTL_DIR/design.sv" \
  "$TB_DIR/testbench.sv" \
  '-voptargs=+acc=npr' \
  -do "run -all; exit"

echo ""
echo "Simulation complete. Check qrun.log for results."
echo "Waveform: dump.vcd"
