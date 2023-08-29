
module SecAnd
(   
    input x0_i,
    input x1_i,
    input y0_i,
    input y1_i,
    input r01_i,
    output z0_o,
    output z1_o);

    reg r10 = (r01_i ^ (x0_i & y1_i)) ^ (x1_i & y0_i);
    assign z0_o = (x0_i & y0_i) ^ r01_i;
    assign z1_o = (x1_i & y1_i) ^ r10;
    
endmodule
