# =============================================================
# Makefile — ALU UVM Verification
# =============================================================
# Targets:
#   make sim      — compile + run simulation (QuestaSim)
#   make clean    — remove generated files
#   make help     — show this help
# =============================================================

RTL_DIR  := rtl
TB_DIR   := tb
SIM_DIR  := sim

DESIGN   := $(RTL_DIR)/design.sv
TB       := $(TB_DIR)/testbench.sv

.PHONY: sim clean help

sim:
	@echo "==> Running ALU UVM simulation with QuestaSim..."
	cd $(SIM_DIR) && bash run_questa.sh

clean:
	@echo "==> Cleaning generated files..."
	rm -rf qrun.out qrun.log dump.vcd transcript modelsim.ini vsim.wlf *.log

help:
	@echo ""
	@echo "ALU UVM Verification Makefile"
	@echo "------------------------------"
	@echo "  make sim    — Run QuestaSim simulation"
	@echo "  make clean  — Remove build artifacts"
	@echo "  make help   — Show this message"
	@echo ""
