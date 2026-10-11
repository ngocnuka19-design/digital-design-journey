module alu8 (
    input [7:0] a, b,
    input [2:0] op,
    input OE,
    output [3:0] flag,
    output [7:0] out
);
    genvar i;
    wire [8:0] carry;
    assign carry [0] = 0;
    generate
        for (i = 0; i < 8 ;i = i + 1) begin: gen_alu
            alu1 inst (
                .a(a[i]), 
                .b(b[i]), 
                .op(op), 
                .cin(carry[i]), 
                .carry(carry[i+1]),
                .out(out[i])
            );
        end
    endgenerate
endmodule
// Bitwise logic sit in ALU1 because no carry
module alu1 (
    input a, b,
    input [2:0] op,
    input cin,
    output carry, 
    output reg out
);
    wire fadd_sum, sub_diff;
    always @(*) begin
        case (op)
            3'b010: out = a & b; //AND
            3'b011: out = a | b; //OR
            3'b100: out = a^b; //XOR
            3'b101: out = ~a; //NOT A
            default: out = 0;
        endcase
    end
    
endmodule
/* module fadd (
    input a, b, cin,
    output cout,  sum
);
    assign sum = a^b^c;
    assign cout = (a&b) | (a&cin) |(b&cin);
endmodule

module sub (
    input a, b, cin,
    output cout, diff
);
    assign diff = a^b^c;
    assign cout = (~a&b) | (~a&cin) |(~b&cin);
endmodule
*/
