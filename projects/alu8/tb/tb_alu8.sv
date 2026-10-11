`timescale 1ns/1ps

module tb_alu8;

    reg [7:0] a, b;
    reg [2:0] op;
    reg OE;

    wire [3:0] flag;
    wire [7:0] out;

    alu8 dut (
        .a(a),
        .b(b),
        .op(op),
        .OE(OE),
        .flag(flag),
        .out(out)
    );

    task automatic check(
        input [2:0] test_op,
        input [7:0] expected
    );
        begin
            op = test_op;
            #1;

            if (out !== expected)
                $fatal(1,
                    "FAIL: op=%b, out=%h, expected=%h",
                    op, out, expected);
            else
                $display(
                    "PASS: op=%b, out=%h",
                    op, out);
        end
    endtask

    initial begin
        a = 8'hA5;
        b = 8'h3C;
        OE = 1'b1;

        check(3'b010, 8'h24); // AND
        check(3'b011, 8'hBD); // OR
        check(3'b100, 8'h99); // XOR
        check(3'b101, 8'h5A); // NOT A

        $display("All logic tests passed.");
        $finish;
    end

endmodule