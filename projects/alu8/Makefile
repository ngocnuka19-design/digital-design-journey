# ============================================================================
# Makefile — Parameterized ALU (Verilator)
# ============================================================================
#
# Targets:
#   make            — lint, build, and run simulation
#   make lint       — static lint only (no simulation)
#   make sim        — build and run simulation
#   make wave       — open waveform in GTKWave (after sim)
#   make clean      — remove all build artifacts
#
# Requirements:
#   - Verilator (>= 5.x recommended)
#   - Make (GNU Make or compatible)
#   - GTKWave (optional, for waveform viewing)
# ============================================================================

# ---- Paths -----------------------------------------------------------------
RTL_DIR   := rtl
TB_DIR    := tb
SIM_DIR   := sim
OBJ_DIR   := $(SIM_DIR)/obj_dir

# ---- Source lists -----------------------------------------------------------
PKG_SRC   := $(RTL_DIR)/alu_pkg.sv
RTL_SRC   := $(RTL_DIR)/full_adder.sv \
             $(RTL_DIR)/ripple_carry_adder.sv \
             $(RTL_DIR)/alu.sv
TB_SRC    := $(TB_DIR)/tb_alu.sv

ALL_SRC   := $(PKG_SRC) $(RTL_SRC) $(TB_SRC)

# ---- Verilator flags -------------------------------------------------------
VFLAGS    := --binary --timing -Wall -Wno-fatal
VTOP      := tb_alu

# ---- Default target --------------------------------------------------------
.PHONY: all lint sim wave clean

all: lint sim

# ---- Lint only -------------------------------------------------------------
lint:
	@echo "==== Lint ===="
	verilator --lint-only -Wall $(PKG_SRC) $(RTL_SRC) $(TB_SRC)
	@echo "Lint passed."

# ---- Build and run simulation ----------------------------------------------
sim: $(OBJ_DIR)/V$(VTOP)
	@echo "==== Running simulation ===="
	$(OBJ_DIR)/V$(VTOP)

$(OBJ_DIR)/V$(VTOP): $(ALL_SRC)
	@mkdir -p $(SIM_DIR)
	verilator $(VFLAGS) -o V$(VTOP) --Mdir $(OBJ_DIR) $(ALL_SRC)
	$(MAKE) -C $(OBJ_DIR) -f V$(VTOP).mk

# ---- Waveform viewer -------------------------------------------------------
wave:
	gtkwave $(SIM_DIR)/*.vcd &

# ---- Clean -----------------------------------------------------------------
clean:
	rm -rf $(OBJ_DIR)
	rm -f  $(SIM_DIR)/*.vcd $(SIM_DIR)/*.fst
