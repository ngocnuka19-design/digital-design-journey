# Parameterized ALU

A fully functional, parameterized combinational ALU in SystemVerilog.

## Architecture

```
         ┌──────────────────────────────────────────┐
         │              alu (top)                    │
         │                                           │
  a ───► │  ┌──────────────────────┐                 │
         │  │  ripple_carry_adder  │── add_result ─► │
  b ───► │  │   (full_adder × W)   │── add_cout ──► │
         │  └──────────────────────┘                 │ ──► result
 op ───► │                                           │
         │  ┌──────────┐                             │ ──► flags
         │  │ Bitwise  │  AND, OR, XOR, NOT ───────► │      {N, V, C, Z}
         │  ├──────────┤                             │
         │  │ Shifts   │  SLL, SRL, SRA ───────────► │
         │  ├──────────┤                             │
         │  │ Compare  │  SLT, SLTU ───────────────► │
         │  ├──────────┤                             │
         │  │ Pass     │  A pass-through ──────────► │
         │  └──────────┘                             │
         └──────────────────────────────────────────┘
```

## Operation Table

| Op Code | Mnemonic | Description                     |
|---------|----------|---------------------------------|
| `0000`  | ADD      | A + B                           |
| `0001`  | SUB      | A − B                           |
| `0010`  | AND      | A & B                           |
| `0011`  | OR       | A \| B                          |
| `0100`  | XOR      | A ^ B                           |
| `0101`  | NOT      | ~A                              |
| `0110`  | SLL      | A << B (logical shift left)     |
| `0111`  | SRL      | A >> B (logical shift right)    |
| `1000`  | SRA      | A >>> B (arithmetic shift right)|
| `1001`  | SLT      | Signed:   A < B ? 1 : 0         |
| `1010`  | SLTU     | Unsigned: A < B ? 1 : 0         |
| `1111`  | PASS     | Pass-through A                  |

## Flags

| Bit | Name     | Description                               |
|-----|----------|-------------------------------------------|
| 0   | Zero (Z) | Result is zero                            |
| 1   | Carry (C)| Unsigned carry-out / borrow (ADD/SUB only)|
| 2   | Overflow (V) | Signed overflow (ADD/SUB only)        |
| 3   | Negative (N) | MSB of result (sign bit)              |

## File Structure

```
projects/alu8/
├── rtl/
│   ├── alu_pkg.sv            # Op-code enum and flag indices
│   ├── full_adder.sv         # 1-bit structural full adder
│   ├── ripple_carry_adder.sv # Parameterized ripple-carry adder/subtractor
│   └── alu.sv                # Top-level parameterized ALU
├── tb/
│   ├── tb_alu.sv             # New comprehensive self-checking testbench
│   └── tb_alu8.sv            # Original testbench (preserved)
├── sim/                      # Simulation artifacts (gitignored)
├── Makefile                  # Build, lint, simulate, clean
└── README.md
```

## Design Decisions

- **Structural adder** — Uses a generate-loop of `full_adder` instances to build the ripple-carry chain, preserving the learning value of your original bit-slice design.
- **Subtraction via two's-complement** — `A - B = A + ~B + 1`. The same adder hardware does both ADD and SUB.
- **Parameterized width** — All modules use `parameter int WIDTH = 8`. Change it once to get a 4-, 16-, or 32-bit ALU.
- **Package for opcodes** — `alu_pkg` centralises op-codes and flag indices so RTL and testbench always agree.
- **RISC-V alignment** — The operations (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU) match the RISC-V base integer instruction set, making this ALU directly usable in a future CPU project.

## Quick Start

```bash
# Lint only
make lint

# Build and run all tests
make sim

# Full flow (lint + sim)
make
```

## Requirements

- **Verilator** ≥ 5.x (simulation and lint)
- **GNU Make**
- **GTKWave** (optional, for waveform viewing)

## Evolution from Original ALU8

This project evolved from a simpler 8-bit ALU (`alu8.sv`) that supported only bitwise operations. The original files are preserved in the repository for reference. Key improvements:

1. Arithmetic operations (ADD/SUB) — were commented-out stubs, now fully functional
2. Condition flags (Z, C, V, N) — were undriven, now correctly computed
3. Shift operations — not present before, now implemented
4. Comparison operations — not present before, now implemented (SLT, SLTU)
5. Parameterized width — was hardcoded to 8 bits
6. Testbench — expanded from 4 tests (one input vector) to 40+ directed tests with flag checking
