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
    


    localparam [2:0] IDLE = 3'b000,
    LOAD =3'b001,
    INITIAL = 3'b010, 
    SECADD1 = 3'b011,
    SECADD2 = 3'b100,
    FINISH = 3'b101;

    reg[2:0] cs;
    reg[2:0] ns;


    reg [4:0] round_nr;
    reg [k-2:0] round_OH_q;

    reg sec_and1;
    reg sec_and2;
    reg round_inc;

    //State machine
    always @(posedge clk_i) begin
        if(rst_i) begin
            cs <= IDLE;
            round_OH_q <= 1;
            round_nr <= 0;
        end else begin
            cs <= ns;
            round_OH_q <= (round_OH_q << round_inc);
            round_nr <= 5'(round_nr + 5'(round_inc));
        end
    end


    always @* begin
        ns = cs;
        if(cs == IDLE) begin
            ns = start_i ? LOAD : IDLE;
        end else if(cs == LOAD) begin 
            ns = INITIAL;
        end else if (ns == INITIAL) begin  
            ns = SECADD1;
        end else if (cs == SECADD1) begin 
            ns = SECADD2;
        end else if (cs == SECADD2) begin
            ns = (round_nr < k) ? SECADD1 : FINISH;
        end else if(cs == FINISH) begin
            ns = IDLE;
        end
    end

    assign sec_and1 = (cs == SECADD1);
    assign sec_and2 = (cs == SECADD2);
    assign round_inc = (cs == SECADD2);
    assign finish_o = (cs == FINISH);



    reg [k-1:0] R0_q, R1_q, A0_q, A1_q;
    reg [k-2:0] Rxy_q, Rxc_q, Ryc_q;
    reg [k-1:0] B0_q, B1_q, C0_q, C1_q;

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
    always @(posedge clk_i) begin
        if(rst_i) begin
            B0_q <= 0;
            B1_q <= 0;
            C0_q <= 0;
            C1_q <= 0;
        end
        else begin
            B0_q <= (cs == INITIAL) ? A0_q ^  R0_q : B0_q;
            B1_q <= (cs == INITIAL) ? R0_q : B1_q;
            C0_q <= (cs == INITIAL) ? A1_q ^  R1_q : C0_q;
            C1_q <= (cs == INITIAL) ? R1_q : C1_q;
        end 
    end






    SecAdd #(.k(k)) sec_add 
        (clk_i, rst_i, 
         B0_q, B1_q, 
         C0_q, C1_q, 
         Rxy_q, Rxc_q, Ryc_q, 
         sec_and1, sec_and2, round_OH_q, 
         B0_o, B1_o);

endmodule

