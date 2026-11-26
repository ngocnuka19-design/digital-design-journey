`default_nettype none
module top_module(
    input a,
    input b,
    input c,
    input d,
    output out,
    output out_n   );
    
    wire mid;
    assign mid = (a&b) | (c&d);
    assign out = mid;
    assign out_n = ~mid;

endmodule
