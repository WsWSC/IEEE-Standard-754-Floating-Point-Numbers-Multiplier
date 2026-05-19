`timescale 1ns/10ps

module tb_FP_MUL;

reg CLK;
reg RESET;
reg ENABLE;
reg [7:0] DATA_IN;

wire [7:0] DATA_OUT;
wire READY;

integer ready_count;
integer pass_count;
integer fail_count;
integer random_count;
integer seed;
reg print_pass;

FP_MUL dut (
    .CLK(CLK),
    .RESET(RESET),
    .ENABLE(ENABLE),
    .DATA_IN(DATA_IN),
    .DATA_OUT(DATA_OUT),
    .READY(READY)
);

always #5 CLK = ~CLK;

function is_nan;
    input [63:0] value;
begin
    is_nan = (value[62:52] == 11'h7ff) && (value[51:0] != 52'h0);
end
endfunction

function is_inf;
    input [63:0] value;
begin
    is_inf = (value[62:52] == 11'h7ff) && (value[51:0] == 52'h0);
end
endfunction

function [63:0] ieee_expected_mul;
    input [63:0] operand_a;
    input [63:0] operand_b;
    real real_a;
    real real_b;
    real real_z;
begin
    real_a = $bitstoreal(operand_a);
    real_b = $bitstoreal(operand_b);
    real_z = real_a * real_b;
    ieee_expected_mul = $realtobits(real_z);
end
endfunction

function [63:0] random_normal_operand;
    reg sign;
    reg [10:0] exp;
    reg [51:0] frac;
    reg [63:0] rand_bits;
begin
    sign = $random(seed) & 1;

    // Keep exponent near 1.0 to avoid overflow and underflow in random tests.
    exp = 11'd990 + ($unsigned($random(seed)) % 11'd67);
    rand_bits = {$random(seed), $random(seed)};
    frac = rand_bits[51:0];

    random_normal_operand = {sign, exp, frac};
end
endfunction

task apply_reset;
begin
    RESET = 1'b1;
    ENABLE = 1'b0;
    DATA_IN = 8'h00;
    repeat (2) @(posedge CLK);
    RESET = 1'b0;
    @(posedge CLK);
end
endtask

task send_byte;
    input [7:0] data;
begin
    DATA_IN = data;
    ENABLE = 1'b1;
    @(posedge CLK);
end
endtask

task send_operand_pair;
    input [63:0] operand_a;
    input [63:0] operand_b;
    integer byte_idx;
begin
    for (byte_idx = 0; byte_idx < 8; byte_idx = byte_idx + 1) begin
        send_byte(operand_a[byte_idx*8 +: 8]);
    end

    for (byte_idx = 0; byte_idx < 8; byte_idx = byte_idx + 1) begin
        send_byte(operand_b[byte_idx*8 +: 8]);
    end

    ENABLE = 1'b0;
    DATA_IN = 8'h00;
end
endtask

task wait_result;
    output [63:0] result;
begin
    result = 64'h0;
    ready_count = 0;

    while (READY !== 1'b1) begin
        @(posedge CLK);
    end

    while (READY === 1'b1) begin
        result[ready_count*8 +: 8] = DATA_OUT;
        ready_count = ready_count + 1;
        @(posedge CLK);
    end
end
endtask

task check_case;
    input [63:0] operand_a;
    input [63:0] operand_b;
    input [63:0] expected;
    input [8*40-1:0] case_name;
    reg [63:0] actual;
    reg pass;
begin
    apply_reset();
    send_operand_pair(operand_a, operand_b);
    wait_result(actual);

    pass = 1'b0;
    if (ready_count != 8) begin
        $display("[FAIL] %0s READY cycles = %0d, expected 8",
                 case_name, ready_count);
    end else if (is_nan(expected)) begin
        pass = is_nan(actual);
        if (!pass) begin
            $display("[FAIL] %0s actual = %h, expected = NaN",
                     case_name, actual);
        end
    end else begin
        pass = (actual === expected);
        if (!pass) begin
            $display("[FAIL] %0s A = %h, B = %h, actual = %h, expected = %h",
                     case_name, operand_a, operand_b, actual, expected);
        end
    end

    if (pass) begin
        if (print_pass) begin
            $display("[PASS] %0s result = %h", case_name, actual);
        end
        pass_count = pass_count + 1;
    end else begin
        fail_count = fail_count + 1;
    end
end
endtask

task check_auto_case;
    input [63:0] operand_a;
    input [63:0] operand_b;
    input [8*40-1:0] case_name;
begin
    check_case(operand_a, operand_b, ieee_expected_mul(operand_a, operand_b),
               case_name);
end
endtask

task run_directed_tests;
begin
    $display("=== Directed normal tests ===");
    print_pass = 1'b1;
    check_auto_case(64'h3ff0_0000_0000_0000, 64'h3ff0_0000_0000_0000,
                    "1.0 * 1.0");
    check_auto_case(64'h3ff8_0000_0000_0000, 64'h4000_0000_0000_0000,
                    "1.5 * 2.0");
    check_auto_case(64'h3ff4_0000_0000_0000, 64'h3ff8_0000_0000_0000,
                    "1.25 * 1.5");
    check_auto_case(64'hc004_0000_0000_0000, 64'h4010_0000_0000_0000,
                    "-2.5 * 4.0");
end
endtask

task run_output_range_tests;
begin
    $display("=== Output range tests with legal inputs ===");
    print_pass = 1'b1;
    check_auto_case(64'h7fef_ffff_ffff_ffff, 64'h4000_0000_0000_0000,
                    "max normal * 2.0");
    check_auto_case(64'hffef_ffff_ffff_ffff, 64'h4000_0000_0000_0000,
                    "-max normal * 2.0");
    check_auto_case(64'h0010_0000_0000_0000, 64'h0010_0000_0000_0000,
                    "min normal * min normal");
    check_auto_case(64'h0010_0000_0000_0000, 64'h8010_0000_0000_0000,
                    "min normal * -min normal");
end
endtask

task run_random_tests;
    reg [63:0] operand_a;
    reg [63:0] operand_b;
    reg [8*40-1:0] case_name;
    integer rand_idx;
    integer pass_before;
    integer fail_before;
begin
    $display("=== Random normal tests: count = %0d, seed = %0d ===",
             random_count, seed);

    print_pass = 1'b0;
    pass_before = pass_count;
    fail_before = fail_count;

    for (rand_idx = 0; rand_idx < random_count; rand_idx = rand_idx + 1) begin
        operand_a = random_normal_operand();
        operand_b = random_normal_operand();
        $sformat(case_name, "random normal %0d", rand_idx);
        check_auto_case(operand_a, operand_b, case_name);
    end

    $display("Random summary: %0d passed, %0d failed",
             pass_count - pass_before, fail_count - fail_before);
end
endtask

initial begin
    CLK = 1'b0;
    RESET = 1'b0;
    ENABLE = 1'b0;
    DATA_IN = 8'h00;
    pass_count = 0;
    fail_count = 0;
    random_count = 100;
    seed = 32'h2024_0605;
    print_pass = 1'b1;

    if ($value$plusargs("SEED=%d", seed)) begin
        $display("Using SEED = %0d", seed);
    end

    if ($value$plusargs("RANDOM_COUNT=%d", random_count)) begin
        $display("Using RANDOM_COUNT = %0d", random_count);
    end

    run_directed_tests();
    run_output_range_tests();
    run_random_tests();

    $display("Summary: %0d passed, %0d failed", pass_count, fail_count);

    if (fail_count != 0) begin
        $fatal(1);
    end

    $finish;
end

endmodule
