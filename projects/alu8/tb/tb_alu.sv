// ============================================================================
// File:    tb_alu.sv
// Project: Parameterized ALU
// Author:  duylk
// Description:
//   Comprehensive self-checking testbench for the parameterized ALU.
//
//   Test strategy:
//     1. Directed tests — hand-picked vectors for every opcode with
//        known-correct golden values, including boundary / corner cases.
//     2. Flag verification — arithmetic tests (ADD/SUB) check all four
//        flags explicitly. Bitwise/shift/compare tests only check Z and N
//        because C and V are defined as 0 for non-arithmetic ops.
//     3. Parameterized — mirrors the DUT WIDTH parameter.
//
//   Pass / fail reporting uses $display and $fatal so Verilator works.
// ============================================================================

`timescale 1ns / 1ps

module tb_alu
    import alu_pkg::*;
;

    // -----------------------------------------------------------------------
    // Parameters — must match the DUT
    // -----------------------------------------------------------------------
    localparam int WIDTH = 8;

    // -----------------------------------------------------------------------
    // DUT signals
    // -----------------------------------------------------------------------
    logic [WIDTH-1:0] a, b;
    alu_op_t          op;
    logic [WIDTH-1:0] result;
    logic [3:0]       flags;

    // -----------------------------------------------------------------------
    // DUT instantiation
    // -----------------------------------------------------------------------
    alu #(.WIDTH(WIDTH)) dut (
        .a      (a),
        .b      (b),
        .op     (op),
        .result (result),
        .flags  (flags)
    );

    // -----------------------------------------------------------------------
    // Convenience: extract individual flags
    // -----------------------------------------------------------------------
    wire flag_z = flags[FLAG_Z];
    wire flag_c = flags[FLAG_C];
    wire flag_v = flags[FLAG_V];
    wire flag_n = flags[FLAG_N];

    // -----------------------------------------------------------------------
    // Statistics
    // -----------------------------------------------------------------------
    int pass_count = 0;
    int fail_count = 0;

    // -----------------------------------------------------------------------
    // Check tasks
    // -----------------------------------------------------------------------

    // Full check: result + all four flags (use for ADD/SUB)
    task automatic check_full(
        input string      label,
        input alu_op_t    test_op,
        input [WIDTH-1:0] test_a,
        input [WIDTH-1:0] test_b,
        input [WIDTH-1:0] exp_result,
        input logic       exp_z,
        input logic       exp_c,
        input logic       exp_v,
        input logic       exp_n
    );
        logic ok;
        begin
            a  = test_a;
            b  = test_b;
            op = test_op;
            #1;
            ok = 1;
            if (result !== exp_result) begin
                $display("FAIL [%s]: result=%h expected=%h", label, result, exp_result);
                ok = 0;
            end
            if (flag_z !== exp_z) begin
                $display("FAIL [%s]: Z=%b expected %b", label, flag_z, exp_z);
                ok = 0;
            end
            if (flag_c !== exp_c) begin
                $display("FAIL [%s]: C=%b expected %b", label, flag_c, exp_c);
                ok = 0;
            end
            if (flag_v !== exp_v) begin
                $display("FAIL [%s]: V=%b expected %b", label, flag_v, exp_v);
                ok = 0;
            end
            if (flag_n !== exp_n) begin
                $display("FAIL [%s]: N=%b expected %b", label, flag_n, exp_n);
                ok = 0;
            end
            if (ok) begin
                $display("PASS [%s]: a=%h b=%h op=%s  result=%h  Z=%b C=%b V=%b N=%b",
                         label, test_a, test_b, test_op.name(), result,
                         flag_z, flag_c, flag_v, flag_n);
                pass_count++;
            end else begin
                fail_count++;
            end
        end
    endtask

    // Result-only check (use for bitwise, shift, compare, pass ops)
    task automatic check_result(
        input string      label,
        input alu_op_t    test_op,
        input [WIDTH-1:0] test_a,
        input [WIDTH-1:0] test_b,
        input [WIDTH-1:0] exp_result
    );
        begin
            a  = test_a;
            b  = test_b;
            op = test_op;
            #1;
            if (result !== exp_result) begin
                $display("FAIL [%s]: a=%h b=%h op=%s  result=%h  expected=%h",
                         label, test_a, test_b, test_op.name(), result, exp_result);
                fail_count++;
            end else begin
                $display("PASS [%s]: a=%h b=%h op=%s  result=%h  Z=%b N=%b",
                         label, test_a, test_b, test_op.name(), result,
                         flag_z, flag_n);
                pass_count++;
            end
        end
    endtask

    // -----------------------------------------------------------------------
    // Test sequences
    // -----------------------------------------------------------------------
    initial begin
        $display("============================================================");
        $display(" ALU Testbench — WIDTH = %0d", WIDTH);
        $display("============================================================");

        // ==== ARITHMETIC — ADD  (check all flags) ==========================
        $display("\n--- ADD ---");
        //                      label          op       a       b       exp   Z  C  V  N
        check_full("add_basic",    ALU_ADD, 8'h0A, 8'h05, 8'h0F, 0, 0, 0, 0);
        check_full("add_zero",     ALU_ADD, 8'h00, 8'h00, 8'h00, 1, 0, 0, 0);
        check_full("add_carry",    ALU_ADD, 8'hFF, 8'h01, 8'h00, 1, 1, 0, 0);
        check_full("add_overflow", ALU_ADD, 8'h7F, 8'h01, 8'h80, 0, 0, 1, 1);
        check_full("add_neg+neg",  ALU_ADD, 8'h80, 8'h80, 8'h00, 1, 1, 1, 0);
        check_full("add_neg+pos",  ALU_ADD, 8'hFF, 8'hFF, 8'hFE, 0, 1, 0, 1);

        // ==== ARITHMETIC — SUB  (check all flags) ==========================
        $display("\n--- SUB ---");
        check_full("sub_basic",    ALU_SUB, 8'h0A, 8'h05, 8'h05, 0, 1, 0, 0);
        check_full("sub_zero",     ALU_SUB, 8'h42, 8'h42, 8'h00, 1, 1, 0, 0);
        check_full("sub_borrow",   ALU_SUB, 8'h00, 8'h01, 8'hFF, 0, 0, 0, 1);
        check_full("sub_overflow", ALU_SUB, 8'h80, 8'h01, 8'h7F, 0, 1, 1, 0);
        check_full("sub_neg",      ALU_SUB, 8'hFF, 8'hFE, 8'h01, 0, 1, 0, 0);

        // ==== BITWISE  (result only) ========================================
        $display("\n--- AND ---");
        check_result("and_basic",     ALU_AND, 8'hA5, 8'h3C, 8'h24);
        check_result("and_all_ones",  ALU_AND, 8'hFF, 8'hFF, 8'hFF);
        check_result("and_clear",     ALU_AND, 8'hFF, 8'h00, 8'h00);

        $display("\n--- OR ---");
        check_result("or_basic",      ALU_OR,  8'hA5, 8'h3C, 8'hBD);
        check_result("or_identity",   ALU_OR,  8'h00, 8'h00, 8'h00);
        check_result("or_all_ones",   ALU_OR,  8'hF0, 8'h0F, 8'hFF);

        $display("\n--- XOR ---");
        check_result("xor_basic",     ALU_XOR, 8'hA5, 8'h3C, 8'h99);
        check_result("xor_self",      ALU_XOR, 8'hAA, 8'hAA, 8'h00);
        check_result("xor_invert",    ALU_XOR, 8'hA5, 8'hFF, 8'h5A);

        $display("\n--- NOT ---");
        check_result("not_basic",     ALU_NOT, 8'hA5, 8'h00, 8'h5A);
        check_result("not_zero",      ALU_NOT, 8'h00, 8'h00, 8'hFF);
        check_result("not_ones",      ALU_NOT, 8'hFF, 8'h00, 8'h00);

        // ==== SHIFTS  (result only) =========================================
        $display("\n--- SLL ---");
        check_result("sll_1",         ALU_SLL, 8'h01, 8'h01, 8'h02);
        check_result("sll_4",         ALU_SLL, 8'h0F, 8'h04, 8'hF0);
        check_result("sll_7",         ALU_SLL, 8'h01, 8'h07, 8'h80);
        check_result("sll_0",         ALU_SLL, 8'hAB, 8'h00, 8'hAB);

        $display("\n--- SRL ---");
        check_result("srl_1",         ALU_SRL, 8'h80, 8'h01, 8'h40);
        check_result("srl_4",         ALU_SRL, 8'hF0, 8'h04, 8'h0F);
        check_result("srl_7",         ALU_SRL, 8'h80, 8'h07, 8'h01);

        $display("\n--- SRA ---");
        check_result("sra_pos",       ALU_SRA, 8'h40, 8'h01, 8'h20);
        check_result("sra_neg",       ALU_SRA, 8'h80, 8'h01, 8'hC0);
        check_result("sra_neg_4",     ALU_SRA, 8'hF0, 8'h04, 8'hFF);

        // ==== COMPARISONS  (result only) ====================================
        $display("\n--- SLT (signed) ---");
        check_result("slt_less",      ALU_SLT,  8'hFF, 8'h01, 8'h01);  // -1 < 1
        check_result("slt_greater",   ALU_SLT,  8'h01, 8'hFF, 8'h00);  //  1 > -1
        check_result("slt_equal",     ALU_SLT,  8'h42, 8'h42, 8'h00);
        check_result("slt_boundary",  ALU_SLT,  8'h80, 8'h7F, 8'h01);  // -128 < 127

        $display("\n--- SLTU (unsigned) ---");
        check_result("sltu_less",     ALU_SLTU, 8'h01, 8'hFF, 8'h01);  //   1 < 255
        check_result("sltu_greater",  ALU_SLTU, 8'hFF, 8'h01, 8'h00);  // 255 > 1
        check_result("sltu_equal",    ALU_SLTU, 8'h42, 8'h42, 8'h00);

        // ==== PASS-THROUGH ==================================================
        $display("\n--- PASS ---");
        check_result("pass_a",        ALU_PASS, 8'hDE, 8'hAD, 8'hDE);
        check_result("pass_zero",     ALU_PASS, 8'h00, 8'hFF, 8'h00);

        // ==== SUMMARY =======================================================
        $display("\n============================================================");
        $display(" RESULTS:  %0d passed,  %0d failed", pass_count, fail_count);
        $display("============================================================");

        if (fail_count > 0)
            $fatal(1, "TESTBENCH FAILED — see failures above.");
        else
            $display("ALL TESTS PASSED.");

        $finish;
    end

endmodule
