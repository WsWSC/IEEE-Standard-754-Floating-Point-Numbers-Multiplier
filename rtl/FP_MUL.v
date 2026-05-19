//------------------------------------------------------//
// Digital IC Design 2024
// Final Project: FP_MUL
//------------------------------------------------------//
`timescale 1ns/10ps

module FP_MUL(CLK, RESET, ENABLE, DATA_IN, DATA_OUT, READY);

/////////////////////////////////////////////////////////////////////
// I/O ports                                                       //
/////////////////////////////////////////////////////////////////////
input         CLK;       // Clock
input         RESET;     // Active-high synchronous reset
input         ENABLE;    // Input valid
input   [7:0] DATA_IN;   // Serial input byte
output reg [7:0] DATA_OUT;  // Serial output byte
output reg       READY;     // Output valid

/////////////////////////////////////////////////////////////////////
// Declarations                                                    //
/////////////////////////////////////////////////////////////////////
// Parameters
localparam a_input_done = 5'd8;
localparam b_input_done = 5'd16;
localparam ope_done     = 6'd38;

// Registers and wires
integer i;

reg [4:0] counter;       // Input byte counter
reg [5:0] count;         // Operation counter
reg [7:0] A [7:0];       // Input buffer A
reg [7:0] B [7:0];       // Input buffer B
reg [63:0] total_A;
reg [63:0] total_B;

reg sign;                // Result sign
reg [10:0] exp;          // Result exponent

wire [104:0] frac_partial_A;
wire [51:0] frac_round_next;
wire [51:0] frac_output;

reg [105:0] frac;        // Mantissa product
reg [104:0] temp1;
reg [104:0] temp2;
reg [104:0] temp3;

/////////////////////////////////////////////////////////////////////
// Input Receive                                                   //
/////////////////////////////////////////////////////////////////////
// Counter control
always @(posedge CLK) begin
    if (RESET) begin
        counter <= 0;
        count <= 0;
    end else if (count == ope_done) begin
        counter <= 0;
        count <= 0;
    end else if (counter == b_input_done) begin
        counter <= counter;
        count <= count + 1;
    end else if (ENABLE) begin
        counter <= counter + 1;
        count <= 0;
    end
end

// Input byte buffer
always @(posedge CLK) begin
    if (RESET) begin
        for (i = 0; i < 8; i = i + 1) begin
            A[i] <= 0;
            B[i] <= 0;
        end
    end else if (ENABLE && counter < a_input_done) begin
        A[counter] <= DATA_IN;
    end else if (ENABLE && counter >= a_input_done && counter < b_input_done) begin
        B[counter-a_input_done] <= DATA_IN;
    end
end

// Combine input bytes
always @(posedge CLK) begin
    if (RESET) begin
        total_A <= 64'b0;
        total_B <= 64'b0;
    end else if (counter == a_input_done) begin
        total_A <= {A[7], A[6], A[5], A[4], A[3], A[2], A[1], A[0]};
    end else if (counter == b_input_done) begin
        total_B <= {B[7], B[6], B[5], B[4], B[3], B[2], B[1], B[0]};
    end
end

/////////////////////////////////////////////////////////////////////
// Operation                                                       //
/////////////////////////////////////////////////////////////////////
// Sign calculation
always @(posedge CLK) begin
    if (RESET) begin
        sign <= 1'b0;
    end else if (total_A[63] == total_B[63]) begin
        sign <= 1'b0;
    end else begin
        sign <= 1'b1;
    end
end

// Exponent calculation
always @(posedge CLK) begin
    if (RESET) begin
        exp <= 0;
    end else if (count == 1) begin
        exp <= (total_A[62:52] + total_B[62:52]) + 11'b100_0000_0010;
    end else if (count == 30 && frac[105] == 0) begin
        exp <= exp + 11'b111_1111_1111;
    end
end

assign frac_partial_A = {1'b1, total_A[51:0]};
assign frac_round_next = frac[104:53] + frac[52];
assign frac_output = (count == 31) ? frac_round_next : frac[104:53];

// Mantissa multiplication
always @(posedge CLK) begin
    if (RESET) begin
        frac <= 0;
        temp1 <= 0;
        temp2 <= 0;
        temp3 <= 0;
    end else if (count == 2) begin
        if (total_B[0] == 1) begin
            temp1 <= frac_partial_A;
        end
        if (total_B[1] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 1);
        end
    end else if (count == 3) begin
        if (total_B[2] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 2);
        end
        if (total_B[3] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 3);
        end
    end else if (count == 4) begin
        if (total_B[4] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 4);
        end
        if (total_B[5] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 5);
        end
    end else if (count == 5) begin
        if (total_B[6] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 6);
        end
        if (total_B[7] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 7);
        end
    end else if (count == 6) begin
        if (total_B[8] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 8);
        end
        if (total_B[9] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 9);
        end
    end else if (count == 7) begin
        if (total_B[10] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 10);
        end
        if (total_B[11] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 11);
        end
    end else if (count == 8) begin
        if (total_B[12] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 12);
        end
        if (total_B[13] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 13);
        end
    end else if (count == 9) begin
        if (total_B[14] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 14);
        end
        if (total_B[15] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 15);
        end
    end else if (count == 10) begin
        if (total_B[16] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 16);
        end
        if (total_B[17] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 17);
        end
    end else if (count == 11) begin
        if (total_B[18] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 18);
        end
        if (total_B[19] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 19);
        end
    end else if (count == 12) begin
        if (total_B[20] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 20);
        end
        if (total_B[21] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 21);
        end
    end else if (count == 13) begin
        if (total_B[22] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 22);
        end
        if (total_B[23] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 23);
        end
    end else if (count == 14) begin
        if (total_B[24] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 24);
        end
        if (total_B[25] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 25);
        end
    end else if (count == 15) begin
        if (total_B[26] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 26);
        end
        if (total_B[27] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 27);
        end
    end else if (count == 16) begin
        if (total_B[28] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 28);
        end
        if (total_B[29] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 29);
        end
    end else if (count == 17) begin
        if (total_B[30] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 30);
        end
        if (total_B[31] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 31);
        end
    end else if (count == 18) begin
        if (total_B[32] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 32);
        end
        if (total_B[33] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 33);
        end
    end else if (count == 19) begin
        if (total_B[34] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 34);
        end
        if (total_B[35] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 35);
        end
    end else if (count == 20) begin
        if (total_B[36] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 36);
        end
        if (total_B[37] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 37);
        end
    end else if (count == 21) begin
        if (total_B[38] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 38);
        end
        if (total_B[39] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 39);
        end
    end else if (count == 22) begin
        if (total_B[40] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 40);
        end
        if (total_B[41] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 41);
        end
    end else if (count == 23) begin
        if (total_B[42] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 42);
        end
        if (total_B[43] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 43);
        end
    end else if (count == 24) begin
        if (total_B[44] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 44);
        end
        if (total_B[45] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 45);
        end
    end else if (count == 25) begin
        if (total_B[46] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 46);
        end
        if (total_B[47] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 47);
        end
    end else if (count == 26) begin
        if (total_B[48] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 48);
        end
        if (total_B[49] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 49);
        end
    end else if (count == 27) begin
        if (total_B[50] == 1) begin
            temp1 <= temp1 + (frac_partial_A << 50);
        end
        if (total_B[51] == 1) begin
            temp2 <= temp2 + (frac_partial_A << 51);
        end
    end else if (count == 28) begin
        temp3 <= (frac_partial_A << 52);
        frac <= temp1 + temp2;
    end else if (count == 29) begin
        frac <= frac + temp3;
    end else if (count == 30 && frac[105] == 0) begin
        frac <= frac << 1;
    end else if (count == 31) begin
        frac[104:53] <= frac[104:53] + frac[52];
    end else if (count == 38) begin
        frac <= 0;
        temp1 <= 0;
        temp2 <= 0;
        temp3 <= 0;
    end
end

/////////////////////////////////////////////////////////////////////
// Output                                                          //
/////////////////////////////////////////////////////////////////////
// READY signal
always @(posedge CLK) begin
    if (RESET) begin
        READY <= 0;
    end else if (count >= 31 && count <= 38) begin
        READY <= 1;
    end else begin
        READY <= 0;
    end
end

// Output byte sequence
always @(posedge CLK) begin
    if (RESET) begin
        DATA_OUT <= 8'b0;
    end else if (count == 31) begin
        DATA_OUT <= frac_output[7:0];
    end else if (count == 32) begin
        DATA_OUT <= frac_output[15:8];
    end else if (count == 33) begin
        DATA_OUT <= frac_output[23:16];
    end else if (count == 34) begin
        DATA_OUT <= frac_output[31:24];
    end else if (count == 35) begin
        DATA_OUT <= frac_output[39:32];
    end else if (count == 36) begin
        DATA_OUT <= frac_output[47:40];
    end else if (count == 37) begin
        DATA_OUT <= {exp[3:0], frac_output[51:48]};
    end else if (count == 38) begin
        DATA_OUT <= {sign, exp[10:4]};
    end
end

endmodule
