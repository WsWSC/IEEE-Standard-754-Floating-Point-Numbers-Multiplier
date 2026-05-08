//------------------------------------------------------//
//- Digital IC Design 2024                              //
//-                                                     //
//- Final Project: FP_MUL                               //
//------------------------------------------------------//
`timescale 1ns/10ps

module FP_MUL(CLK, RESET, ENABLE, DATA_IN, DATA_OUT, READY );

// I/O Ports
input         CLK; //clock signal
input         RESET; //sync. RESET=1
input         ENABLE; //input data sequence when ENABLE =1
input   [7:0] DATA_IN; //input data sequence
output  [7:0] DATA_OUT; //ouput data sequence

output reg READY; //output data is READY when READY=1


/////////////////////////////////////////////////////////////////////
// declarations                                                    //
/////////////////////////////////////////////////////////////////////
integer  i;

//- input ----------------------------------------------//
reg [4:0] counter;                  //計算input state 需要的clk 數。
reg [5:0] count;                    //計算operation state 的clk 數
reg [5:0] A [7:0];
reg [5:0] B [7:0];                  //暫存每次input 進的8 bit
reg [63:0] total_A, total_B;        //8 bit input * 8 cycle = 64 bit 的IEEE 754 倍精度浮點數

//- ope ------------------------------------------------//
reg sign;                           //sign bit
reg [10:0] exp;                      //exponent

wire [104:0] frac_partial_A;        //暫存total_A[51:0] 的fraction 部分
reg [105:0] frac;                   //fraction
reg [104:0] temp1, temp2, temp3;    //暫存fraction 運算結果


/////////////////////////////////////////////////////////////////////
// state initial                                                   //
/////////////////////////////////////////////////////////////////////
//counter
always @(posedge CLK or posedge RESET) 
begin
    if (RESET) begin
        counter <= 0;
        count <= 0;
    end else if (count == ope_done) begin
        counter <= 0;
        count <= 0;
    end else if (counter == b_input_done) begin
        counter <= counter;
        count <= count + 1;
    end else begin
        counter <= counter + 1; 
        count <= 0;
    end
end


/////////////////////////////////////////////////////////////////////
// state input                                                     //
/////////////////////////////////////////////////////////////////////
//input A/B
always @(posedge CLK or posedge RESET) begin 
    if (RESET) begin
        for (i = 0; i < 8; i = i + 1) begin
            A[i] <= 0;
            B[i] <= 0;
        end
    end else if (ENABLE) begin
        A[counter-1] <= DATA_IN;
        B[counter-9] <= DATA_IN;
    end
end

//store A/B into total
always @(posedge CLK or posedge RESET) begin
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
// state ope                                                       //
/////////////////////////////////////////////////////////////////////
//sign bit
always @(posedge CLK or posedge RESET) begin
    if (RESET)
        sign <= 1'b0;
    else if (total_A[63] == total_B[63])
        sign <= 1'b0;
    else
        sign <= 1'b1;

end

//exp
always @(posedge CLK or posedge RESET) begin
    if (RESET)
        exp <= 0;
    else if (count == 1)
        exp <= (total_A[62:52] + total_B[62:52]) + 11'b100_0000_0010;
    else if (count == 30 && frac[105] == 0)
        exp <= exp + 11'b111_1111_1111;

end

assign frac_partial_A = {1'b1, total_A[51:0]};

//generator the frac number of OUTPUT
always@(posedge CLK or posedge RESET)
begin
	if (RESET) begin	
        frac  <= 0;
        temp1 <= 0;
        temp2 <= 0;
        temp3 <= 0;
	end	else if ( count == 2 ) begin
		if (total_B[0] == 1)	temp1 <= frac_partial_A;		
		if (total_B[1] == 1)	temp2 <= temp2 + (frac_partial_A << 1);
	end	else if ( count == 3 ) begin
		if (total_B[2] == 1)	temp1 <= temp1 + (frac_partial_A << 2);
		if (total_B[3] == 1)	temp2 <= temp2 + (frac_partial_A << 3);
	end	else if ( count == 4 ) begin
		if (total_B[4] == 1) 	temp1 <= temp1 + (frac_partial_A << 4);
		if (total_B[5] == 1)	temp2 <= temp2 + (frac_partial_A << 5);
	end else if ( count == 5 ) begin
		if (total_B[6] == 1)	temp1 <= temp1 + (frac_partial_A << 6);
		if (total_B[7] == 1)	temp2 <= temp2 + (frac_partial_A << 7);
	end else if ( count == 6 ) begin
		if (total_B[8] == 1) 	temp1 <= temp1 + (frac_partial_A << 8);
		if (total_B[9] == 1)	temp2 <= temp2 + (frac_partial_A << 9);
	end else if ( count == 7 ) begin
		if (total_B[10] == 1)	temp1 <= temp1 + (frac_partial_A << 10);
		if (total_B[11] == 1)	temp2 <= temp2 + (frac_partial_A << 11);
	end	else if ( count == 8 ) begin
		if (total_B[12] == 1) 	temp1 <= temp1 + (frac_partial_A << 12);
		if (total_B[13] == 1)	temp2 <= temp2 + (frac_partial_A << 13);
	end else if ( count == 9 ) begin
		if (total_B[14] == 1)	temp1 <= temp1 + (frac_partial_A << 14);
		if (total_B[15] == 1)	temp2 <= temp2 + (frac_partial_A << 15);
	end	else if ( count == 10 )	begin
		if (total_B[16] == 1) 	temp1 <= temp1 + (frac_partial_A << 16);	
		if (total_B[17] == 1)	temp2 <= temp2 + (frac_partial_A << 17);
	end	else if ( count == 11 )	begin
		if (total_B[18] == 1)	temp1 <= temp1 + (frac_partial_A << 18);
		if (total_B[19] == 1)	temp2 <= temp2 + (frac_partial_A << 19);
	end	else if ( count == 12 )	begin
		if (total_B[20] == 1)	temp1 <= temp1 + (frac_partial_A << 20);
		if (total_B[21] == 1)	temp2 <= temp2 + (frac_partial_A << 21);
	end	else if ( count == 13 )	begin
		if (total_B[22] == 1)	temp1 <= temp1 + (frac_partial_A << 22);
		if (total_B[23] == 1)	temp2 <= temp2 + (frac_partial_A << 23);
	end	else if ( count == 14 )	begin
		if (total_B[24] == 1) 	temp1 <= temp1 + (frac_partial_A << 24);	
		if (total_B[25] == 1)	temp2 <= temp2 + (frac_partial_A << 25);
	end	else if ( count == 15 )	begin
		if (total_B[26] == 1)	temp1 <= temp1 + (frac_partial_A << 26);
		if (total_B[27] == 1)	temp2 <= temp2 + (frac_partial_A << 27);
	end	else if ( count == 16 )	begin
		if (total_B[28] == 1)	temp1 <= temp1 + (frac_partial_A << 28);
		if (total_B[29] == 1)	temp2 <= temp2 + (frac_partial_A << 29);
	end	else if ( count == 17 )	begin
		if (total_B[30] == 1)	temp1 <= temp1 + (frac_partial_A << 30);
		if (total_B[31] == 1)	temp2 <= temp2 + (frac_partial_A << 31);
	end	else if ( count == 18 )	begin
		if (total_B[32] == 1) 	temp1 <= temp1 + (frac_partial_A << 32);
		if (total_B[33] == 1)	temp2 <= temp2 + (frac_partial_A << 33);
	end	else if ( count == 19 )	begin
		if (total_B[34] == 1)	temp1 <= temp1 + (frac_partial_A << 34);
		if (total_B[35] == 1)	temp2 <= temp2 + (frac_partial_A << 35);
	end	else if ( count == 20 )	begin
		if (total_B[36] == 1)	temp1 <= temp1 + (frac_partial_A << 36);
		if (total_B[37] == 1)	temp2 <= temp2 + (frac_partial_A << 37);
	end	else if ( count == 21 )	begin
		if (total_B[38] == 1)	temp1 <= temp1 + (frac_partial_A << 38);
		if (total_B[39] == 1)	temp2 <= temp2 + (frac_partial_A << 39);
	end	else if ( count == 22 )	begin
		if (total_B[40] == 1) 	temp1 <= temp1 + (frac_partial_A << 40);
		if (total_B[41] == 1)	temp2 <= temp2 + (frac_partial_A << 41);
	end	else if ( count == 23 )	begin
		if (total_B[42] == 1)	temp1 <= temp1 + (frac_partial_A << 42);
		if (total_B[43] == 1)	temp2 <= temp2 + (frac_partial_A << 43);
	end	else if ( count == 24 )	begin
		if (total_B[44] == 1) 	temp1 <= temp1 + (frac_partial_A << 44);
		if (total_B[45] == 1)	temp2 <= temp2 + (frac_partial_A << 45);
	end	else if ( count == 25 )	begin
		if (total_B[46] == 1)	temp1 <= temp1 + (frac_partial_A << 46);
		if (total_B[47] == 1)	temp2 <= temp2 + (frac_partial_A << 47);
	end	else if ( count == 26 )	begin
		if (total_B[48] == 1) 	temp1 <= temp1 + (frac_partial_A << 48);
		if (total_B[49] == 1)	temp2 <= temp2 + (frac_partial_A << 49);
	end	else if ( count == 27 )	begin
		if (total_B[50] == 1)	temp1 <= temp1 + (frac_partial_A << 50);
		if (total_B[51] == 1)	temp2 <= temp2 + (frac_partial_A << 51);
	end	
    else if ( count == 28 )	begin
		temp3 <= (frac_partial_A << 52);
		frac  <= temp1 + temp2;
	end
	else if ( count == 29 )	begin
		frac <= frac + temp3;
	end
	else if ( count == 30 && (frac[105] == 0) )	begin
	    frac <= frac << 1;
	end
	else if ( count == 31)
	    frac[104:53] <= frac[104:53] + frac[52];
	else if ( count == 38) begin	
        frac <= 0;
        temp1 <= 0;
        temp2 <= 0;
        temp3 <= 0;
	end
end	


/////////////////////////////////////////////////////////////////////
// state output                                                    //
/////////////////////////////////////////////////////////////////////
//READY
always@(posedge CLK or posedge RESET) begin
	if (RESET)
	    READY <= 0;
	else if (count >= 31 && count <=38)
	    READY <= 1;
	else
	    READY <= 0;
end

//output
always@(posedge CLK or posedge RESET) begin
	if (RESET) begin
	    DATA_OUT <= 8'b0;
	end	
    else if (count == 31) begin
	    DATA_OUT <= {sign, exp[10:4]};
	end	
    else if (count == 32) begin
	    DATA_OUT <= {exp[3:0], frac[104:101]};
	end	
    else if (count == 33) begin
	    DATA_OUT <= frac[100:93];
	end	
    else if (count == 34) begin
	    DATA_OUT <= frac[92:85];
	end	
    else if (count == 35) begin	
	    DATA_OUT <= frac[84:77];
	end	
    else if (count == 36) begin
	    DATA_OUT <= frac[76:69];
	end	
    else if (count == 37) begin
	    DATA_OUT <= frac[68:61];
	end	
    else if (count == 38) begin	
	    DATA_OUT <= frac[60:53];
	end

end



endmodule