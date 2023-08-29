module cgv14
# (parameter k = 16)
(
    input clk_i,
    input rst_i,
    input start_i,

    input[k-1:0] A0_i,
    input[k-1:0] A1_i,

    input[k-1:0] R0_i,
    input[k-1:0] R1_i,
    
    input [k-2:0] Rxy_i,
    input [k-2:0] Rxc_i,
    input [k-2:0] Ryc_i,

    output finish_o,

    output[k-1:0] B0_o,
    output[k-1:0] B1_o);
    

    localparam [1:0] IDLE = 2'b00,
    LOAD = 2'b01,
    COMPUTE = 2'b10, 
    FINISH = 2'b11;

    reg [1:0] cs;
    reg [1:0] ns;


    //State machine
    always @(posedge clk_i) begin
        if(rst_i) begin
            cs <= IDLE;
        end else begin
            cs <= ns;
        end
    end

    always @* begin
        ns = cs;
        if(cs == IDLE) begin
            ns = start_i ? LOAD : IDLE;
        end else if(cs == LOAD) begin 
            ns = COMPUTE;
        end else if (cs == COMPUTE) begin  
            ns = FINISH;
        end else if (cs == FINISH) begin
            ns = IDLE;
        end
    end
    
    assign finish_o = (cs == FINISH);



    reg [k-1:0] R0_q, R1_q, A0_q, A1_q;
    reg [k-2:0] Rxy_q, Rxc_q, Ryc_q;

    //Load inputs
    always @(posedge clk_i) begin
        if(rst_i) begin
            R0_q <= 0;
            R1_q <= 0;
            Rxy_q <= 0;
            Rxc_q <= 0;
            Ryc_q <= 0;
            A0_q <= 0;
            A1_q <= 0;
        end
        else begin
            R0_q <= (cs == LOAD) ? R0_i : R0_q;
            R1_q <= (cs == LOAD) ? R1_i : R1_q;
            Rxy_q <= (cs == LOAD) ? Rxy_i : Rxy_q;
            Rxc_q <= (cs == LOAD) ? Rxc_i : Rxc_q;
            Ryc_q <= (cs == LOAD) ? Ryc_i : Ryc_q;
            A0_q <= (cs == LOAD) ? A0_i : A0_q;
            A1_q <= (cs == LOAD) ? A1_i : A1_q;
        end 
    end
    
    
    // Initial resharing
    reg [k-1:0] B0, B1, C0, C1;
    reg [k-1:0] Z0, Z1;
    
    assign B0 = A0_q ^  R0_q;
    assign B1 = R0_q;
    assign C0 = A1_q ^  R1_q;
    assign C1 = R1_q;
   

    // Secure addition
    SecAdd #(.k(k)) sec_add 
        (.x0_i(B0), .x1_i(B1), 
         .y0_i(C0), .y1_i(C1), 
         .Rxy_i(Rxy_q), .Rxc_i(Rxc_q), .Ryc_i(Ryc_q), 
         .z0_o(Z0), .z1_o(Z1));

    assign B0_o = Z0;
    assign B1_o = Z1;
endmodule

