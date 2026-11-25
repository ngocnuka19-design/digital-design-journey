// ============================================================================
// File:    full_adder.sv
// Project: Parameterized ALU
// Author:  duylk
// Description:
//   Structural 1-bit full adder.
//   Kept as a standalone module so it can be studied, tested, and
//   swapped (e.g. for a carry-lookahead cell) independently.
//
//   Truth table:
//     a  b  cin | sum  cout
//     0  0  0   |  0    0
//     0  0  1   |  1    0
//     0  1  0   |  1    0
//     0  1  1   |  0    1
//     1  0  0   |  1    0
//     1  0  1   |  0    1
//     1  1  0   |  0    1
//     1  1  1   |  1    1
// ============================================================================

`timescale 1ns / 1ps

module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);

endmodule
