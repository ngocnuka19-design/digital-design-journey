// ============================================================================
// File:    alu.sv
// Project: Parameterized ALU
// Author:  duylk
// Description:
//   Parameterized combinational Arithmetic Logic Unit.
//
//   Preserves the original alu8 design philosophy (bit-slice with generate,
//   carry-chain, explicit full adder) while adding:
//     - Parameterized width (default 8)
//     - Full arithmetic (ADD, SUB) through a ripple-carry adder
//     - Barrel-shift operations (SLL, SRL, SRA)
//     - Comparison operations (SLT, SLTU)
//     - Pass-through (useful for datapaths)
//     - 4-bit condition flags: Zero, Carry, Overflow, Negative
//
//   Operation encoding uses alu_pkg::alu_op_t.
//
//   Interface:
//     a, b   — WIDTH-bit operands
//     op     — 4-bit operation selector (alu_pkg::alu_op_t)
//     result — WIDTH-bit result
//     flags  — {N, V, C, Z}  (flag indices in alu_pkg)
// ============================================================================

`timescale 1ns / 1ps

module alu
    import alu_pkg::*;
#(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  alu_op_t          op,
    output logic [WIDTH-1:0] result,
    output logic [3:0]       flags
);

    // Shift-amount width: number of bits needed to represent 0..WIDTH-1
    localparam int SHAMT_W = $clog2(WIDTH);

    // -----------------------------------------------------------------------
    // Adder / Subtractor (structural ripple-carry)
    // -----------------------------------------------------------------------
    logic [WIDTH-1:0] add_result;
    logic             add_cout;
    logic             add_sub;        // 1 for SUB, SLT, SLTU

    assign add_sub = (op == ALU_SUB) || (op == ALU_SLT) || (op == ALU_SLTU);

    ripple_carry_adder #(.WIDTH(WIDTH)) u_rca (
        .a    (a),
        .b    (b),
        .sub  (add_sub),
        .sum  (add_result),
        .cout (add_cout)
    );

    // -----------------------------------------------------------------------
    // Signed overflow detection  (for ADD / SUB)
    //   Overflow when both operands have the same sign but the result differs.
    //   For SUB the effective b is ~b, so we check against ~b's sign.
    // -----------------------------------------------------------------------
    logic signed_overflow;
    always_comb begin
        if (op == ALU_ADD)
            signed_overflow = (~(a[WIDTH-1] ^ b[WIDTH-1])) &
                              (a[WIDTH-1] ^ add_result[WIDTH-1]);
        else // SUB, SLT, SLTU
            signed_overflow = (a[WIDTH-1] ^ b[WIDTH-1]) &
                              (a[WIDTH-1] ^ add_result[WIDTH-1]);
    end

    // -----------------------------------------------------------------------
    // Shift amount (lower bits of b only)
    // -----------------------------------------------------------------------
    logic [SHAMT_W-1:0] shamt;
    assign shamt = b[SHAMT_W-1:0];

    // -----------------------------------------------------------------------
    // Signed-less-than result
    //   SLT: 1 if signed(a) < signed(b), which equals (N XOR V) after SUB.
    //   SLTU: 1 if unsigned(a) < unsigned(b), which equals ~Carry after SUB.
    // -----------------------------------------------------------------------
    logic slt_result;
    logic sltu_result;
    assign slt_result  = add_result[WIDTH-1] ^ signed_overflow;
    assign sltu_result = ~add_cout;

    // -----------------------------------------------------------------------
    // Result MUX
    // -----------------------------------------------------------------------
    always_comb begin
        case (op)
            ALU_ADD,
            ALU_SUB  : result = add_result;
            ALU_AND  : result = a & b;
            ALU_OR   : result = a | b;
            ALU_XOR  : result = a ^ b;
            ALU_NOT  : result = ~a;
            ALU_SLL  : result = a << shamt;
            ALU_SRL  : result = a >> shamt;
            ALU_SRA  : result = $unsigned($signed(a) >>> shamt);
            ALU_SLT  : result = {{(WIDTH-1){1'b0}}, slt_result};
            ALU_SLTU : result = {{(WIDTH-1){1'b0}}, sltu_result};
            ALU_PASS : result = a;
            default  : result = '0;
        endcase
    end

    // -----------------------------------------------------------------------
    // Flags:  {N, V, C, Z}
    //   - Carry and Overflow are meaningful only for ADD / SUB.
    //   - Zero and Negative are set for every operation.
    // -----------------------------------------------------------------------
    logic flag_z, flag_c, flag_v, flag_n;

    assign flag_z = (result == '0);
    assign flag_n = result[WIDTH-1];

    always_comb begin
        case (op)
            ALU_ADD,
            ALU_SUB  : begin
                flag_c = add_cout;
                flag_v = signed_overflow;
            end
            default  : begin
                flag_c = 1'b0;
                flag_v = 1'b0;
            end
        endcase
    end

    assign flags[FLAG_Z] = flag_z;
    assign flags[FLAG_C] = flag_c;
    assign flags[FLAG_V] = flag_v;
    assign flags[FLAG_N] = flag_n;

endmodule
