// ============================================================================
// File:    alu_pkg.sv
// Project: Parameterized ALU
// Author:  duylk
// Description:
//   Package defining ALU operation codes and flag bit indices.
//   Centralises all magic numbers so that RTL, testbench, and future
//   control units share a single source of truth.
// ============================================================================

`timescale 1ns / 1ps

package alu_pkg;

    // ---- Operation codes (directly used as the `op` input) -----------------
    typedef enum logic [3:0] {
        ALU_ADD  = 4'b0000,   // A + B            (unsigned / two's-complement)
        ALU_SUB  = 4'b0001,   // A - B
        ALU_AND  = 4'b0010,   // A & B
        ALU_OR   = 4'b0011,   // A | B
        ALU_XOR  = 4'b0100,   // A ^ B
        ALU_NOT  = 4'b0101,   // ~A
        ALU_SLL  = 4'b0110,   // A << B[clog2(W)-1:0]   logical shift left
        ALU_SRL  = 4'b0111,   // A >> B[clog2(W)-1:0]   logical shift right
        ALU_SRA  = 4'b1000,   // A >>> B[clog2(W)-1:0]  arithmetic shift right
        ALU_SLT  = 4'b1001,   // (signed)   A < B ? 1 : 0
        ALU_SLTU = 4'b1010,   // (unsigned) A < B ? 1 : 0
        ALU_PASS = 4'b1111    // Pass-through A  (useful in datapaths)
    } alu_op_t;

    // ---- Flag-bit indices inside the 4-bit `flags` bus ---------------------
    localparam int FLAG_Z = 0;    // Zero:            result == 0
    localparam int FLAG_C = 1;    // Carry / Borrow:  unsigned overflow
    localparam int FLAG_V = 2;    // Overflow:        signed overflow
    localparam int FLAG_N = 3;    // Negative:        result MSB (sign bit)

endpackage
