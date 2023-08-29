module SecAnd
(   
    input clk_i,
    input rst_i,

    input sec_and1_i,
    input sec_and2_i,

    input x0_i,
    input x1_i,
    input y0_i,
    input y1_i,
    input r01_i,
    output z1_o,
    output z2_o);

    reg r01_xor__x0_and_y1_q;
    reg r10_q;
    always @(posedge clk_i) begin
        if(rst_i) begin
            r01_xor__x0_and_y1_q <= 0;
            r10_q <= 0;
        end else begin
            
            if(sec_and1_i) begin
                r01_xor__x0_and_y1_q <= (r01_i ^ (x0_i & y1_i));
                r10_q <= 0;
            end 
            else if(sec_and2_i) begin
                r10_q <= r01_xor__x0_and_y1_q ^ (x1_i & y0_i);
            end
            else begin
                r10_q <= r10_q;
            end
        end
    end

    assign z1_o = (x0_i & y0_i) ^ r01_i;
    assign z2_o = (x1_i & y1_i) ^ r10_q;    
endmodule
