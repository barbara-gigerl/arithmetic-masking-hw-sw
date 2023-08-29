
module SecAdd
# (parameter k = 16)
(   input clk_i,
    input rst_i,
    input [k-1:0] x0_i, 
    input [k-1:0] x1_i, 
    input [k-1:0] y0_i, 
    input [k-1:0] y1_i, 
    input [k-2:0] Rxy_i,
    input [k-2:0] Rxc_i,
    input [k-2:0] Ryc_i,
    input sec_and1_i,
    input sec_and2_i,
    input [k-2:0] round_OH,
    output [k-1:0] z0_o,
    output [k-1:0] z1_o);


    wire [k-1:0] c0, c1;

    genvar i;

    wire [k-2:0] xy0, xy1;
    wire [k-2:0] xc0, xc1;
    wire [k-2:0] yc0, yc1;

    generate
        for (i = 0; i < k-1; i = i + 1) begin

            SecAnd xy_and(clk_i, rst_i, 
                          sec_and1_i  & round_OH[i], 
                          sec_and2_i  & round_OH[i],
                          x0_i[i] , x1_i[i],
                          y0_i[i] , y1_i[i],
                          Rxy_i[i],
                          xy0[i], xy1[i]
                          );
            SecAnd xc_and(clk_i, rst_i, 
                          sec_and1_i & round_OH[i], 
                          sec_and2_i  & round_OH[i],
                          x0_i[i], x1_i[i],
                          c0[i], c1[i],
                          Rxc_i[i],
                          xc0[i] , xc1[i]
                          );
            SecAnd yc_and(clk_i, rst_i, 
                          sec_and1_i & round_OH[i], 
                          sec_and2_i & round_OH[i],
                          y0_i[i]  , y1_i[i] ,
                          c0[i] , c1[i] ,
                          Ryc_i[i] ,
                          yc0[i] , yc1[i]
                          );
        end
    endgenerate

    assign c0 = {xy0 ^ xc0 ^ yc0, 1'b0};
    assign c1 = {xy1 ^ xc1 ^ yc1, 1'b0};
    assign z0_o = x0_i ^ y0_i ^ c0; 
    assign z1_o = x1_i ^ y1_i ^ c1;  
    
endmodule


