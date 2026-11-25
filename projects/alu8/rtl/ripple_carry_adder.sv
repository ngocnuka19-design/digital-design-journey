// ============================================================================
// File:    ripple_carry_adder.sv
// Project: Parameterized ALU
// Author:  duylk
// Description:
//   Parameterized WIDTH-bit ripple-carry adder / subtractor.
//
//   When `sub` is deasserted the module computes A + B.
//   When `sub` is asserted  the module computes A - B  (two's-complement)
//   by inverting B and setting cin = 1  (A + ~B + 1).
//
//   Outputs:
//     sum  — WIDTH-bit result
//     cout — carry-out of the most-significant bit
//
//   This module is intentionally structural (chain of full_adder instances)
//   to preserve the learning value of ripple-carry propagation.
//   Replace with a carry-lookahead adder for performance.
// ============================================================================

`timescale 1ns / 1ps

module ripple_carry_adder #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             sub,     // 0 = add, 1 = subtract
    output logic [WIDTH-1:0] sum,
    output logic             cout
);

    // Internal carry chain: carry[0] is the initial carry-in,
    // carry[WIDTH] is the final carry-out.
    logic [WIDTH:0] carry;
    logic [WIDTH-1:0] b_eff;      // effective B (possibly inverted)

    // Two's-complement subtraction: A - B = A + ~B + 1
    assign b_eff    = b ^ {WIDTH{sub}};
    assign carry[0] = sub;

    // Structural ripple-carry chain
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_fa
            full_adder u_fa (
                .a    (a[i]),
                .b    (b_eff[i]),
                .cin  (carry[i]),
                .sum  (sum[i]),
                .cout (carry[i+1])
            );
        end
    endgenerate

    assign cout = carry[WIDTH];

endmodule
