`timescale 1ns/1ps

module digital_clock_plus_tb;

    // =========================================================
    // Testbench Signals
    // =========================================================

    reg clk_1hz;
    reg reset;

    reg [1:0] mode;

    // Stopwatch controls
    reg sw_start;
    reg sw_stop;
    reg sw_reset;

    // Timer controls
    reg tm_start;
    reg tm_reset;

    // Alarm controls
    reg alarm_enable;

    reg [3:0] alarm_hr_ones;
    reg [3:0] alarm_hr_tens;
    reg [3:0] alarm_min_ones;
    reg [3:0] alarm_min_tens;

    // Timer preset inputs
    reg [3:0] tm_hr_ones;
    reg [3:0] tm_hr_tens;
    reg [3:0] tm_min_ones;
    reg [3:0] tm_min_tens;
    reg [3:0] tm_sec_ones;
    reg [3:0] tm_sec_tens;

    // Outputs
    wire alarm_trigger;

    wire [3:0] d_ones;
    wire [3:0] d_tens;

    wire [3:0] m_ones;
    wire [3:0] m_tens;

    wire [3:0] h_ones;
    wire [3:0] h_tens;


    // =========================================================
    // DUT Instantiation
    // =========================================================

    digital_clock_plus uut (

        .clk_1hz(clk_1hz),
        .reset(reset),

        .mode(mode),

        .sw_start(sw_start),
        .sw_stop(sw_stop),
        .sw_reset(sw_reset),

        .tm_start(tm_start),
        .tm_reset(tm_reset),

        .alarm_enable(alarm_enable),

        .alarm_hr_ones(alarm_hr_ones),
        .alarm_hr_tens(alarm_hr_tens),

        .alarm_min_ones(alarm_min_ones),
        .alarm_min_tens(alarm_min_tens),

        .tm_hr_ones(tm_hr_ones),
        .tm_hr_tens(tm_hr_tens),

        .tm_min_ones(tm_min_ones),
        .tm_min_tens(tm_min_tens),

        .tm_sec_ones(tm_sec_ones),
        .tm_sec_tens(tm_sec_tens),

        .alarm_trigger(alarm_trigger),

        .d_ones(d_ones),
        .d_tens(d_tens),

        .m_ones(m_ones),
        .m_tens(m_tens),

        .h_ones(h_ones),
        .h_tens(h_tens)
    );


    // =========================================================
    // Simulation Clock
    // =========================================================
    // 10 ns clock period.
    // Each positive edge represents one logical 1-second tick
    // for accelerated simulation.

    always #5 clk_1hz = ~clk_1hz;


    // =========================================================
    // Display Task
    // =========================================================

    task display_status;

        input [8*16:1] test_name;

        begin
            $display(
                "TIME = %0t | %s | MODE = %b | TIME = %0d%0d:%0d%0d:%0d%0d | ALARM = %b",
                $time,
                test_name,
                mode,
                h_tens, h_ones,
                m_tens, m_ones,
                d_tens, d_ones,
                alarm_trigger
            );
        end

    endtask


    // =========================================================
    // Main Test Sequence
    // =========================================================

    integer i;

    initial begin

        // -----------------------------------------------------
        // Initial Values
        // -----------------------------------------------------

        clk_1hz = 0;
        reset = 0;

        mode = 2'b00;

        sw_start = 0;
        sw_stop  = 0;
        sw_reset = 0;

        tm_start = 0;
        tm_reset = 0;

        alarm_enable = 1;

        // Alarm configuration: 01:14:00
        alarm_hr_tens  = 4'd0;
        alarm_hr_ones  = 4'd1;

        alarm_min_tens = 4'd1;
        alarm_min_ones = 4'd4;

        // Timer preset: 00:00:15
        tm_hr_tens  = 4'd0;
        tm_hr_ones  = 4'd0;

        tm_min_tens = 4'd0;
        tm_min_ones = 4'd0;

        tm_sec_tens = 4'd1;
        tm_sec_ones = 4'd5;


        // -----------------------------------------------------
        // VCD Waveform Generation
        // -----------------------------------------------------

        $dumpfile("digital_clock_plus_tb.vcd");
        $dumpvars(0, digital_clock_plus_tb);


        // =====================================================
        // TEST 1: RESET
        // =====================================================

        $display("\n========================================");
        $display("TEST 1: RESET");
        $display("========================================");

        reset = 1;
        #10;

        reset = 0;
        #10;

        display_status("RESET TEST");


        // =====================================================
        // TEST 2: CLOCK MODE
        // =====================================================

        $display("\n========================================");
        $display("TEST 2: CLOCK MODE");
        $display("========================================");

        mode = 2'b00;

        // Run until approximately 01:15:00
        for (i = 0; i < 4500; i = i + 1) begin

            @(posedge clk_1hz);

            // Print every minute
            if (d_tens == 0 && d_ones == 0) begin
                display_status("CLOCK MODE");
            end

            // Check clock alarm
            if (alarm_trigger) begin
                $display(
                    "*** CLOCK ALARM TRIGGERED at %0d%0d:%0d%0d:%0d%0d ***",
                    h_tens, h_ones,
                    m_tens, m_ones,
                    d_tens, d_ones
                );
            end

        end


        // =====================================================
        // TEST 3: STOPWATCH MODE
        // =====================================================

        $display("\n========================================");
        $display("TEST 3: STOPWATCH MODE");
        $display("========================================");

        mode = 2'b01;

        // Reset stopwatch
        sw_reset = 1;

        @(posedge clk_1hz);

        sw_reset = 0;

        // Start stopwatch
        sw_start = 1;
        sw_stop  = 0;

        for (i = 0; i < 20; i = i + 1) begin

            @(posedge clk_1hz);

            display_status("STOPWATCH");

        end

        // Stop stopwatch
        sw_start = 0;
        sw_stop  = 1;

        @(posedge clk_1hz);

        display_status("STOPWATCH STOPPED");


        // =====================================================
        // TEST 4: COUNTDOWN TIMER
        // =====================================================

        $display("\n========================================");
        $display("TEST 4: COUNTDOWN TIMER");
        $display("========================================");

        mode = 2'b10;

        // Load timer preset
        tm_reset = 1;

        @(posedge clk_1hz);

        tm_reset = 0;

        // Start countdown
        tm_start = 1;

        for (i = 0; i < 17; i = i + 1) begin

            @(posedge clk_1hz);

            display_status("COUNTDOWN TIMER");

            if (alarm_trigger) begin
                $display("*** TIMER ALARM TRIGGERED ***");
            end

        end

        // Stop timer
        tm_start = 0;


        // =====================================================
        // Clear timer alarm before rollover test
        // =====================================================

        reset = 1;
        #10;

        reset = 0;
        #10;


        // =====================================================
        // TEST 5: 24-HOUR ROLLOVER
        // =====================================================

        $display("\n========================================");
        $display("TEST 5: 24-HOUR ROLLOVER");
        $display("Testing 23:59:59 -> 00:00:00");
        $display("========================================");

        // Disable alarm for this test
        alarm_enable = 0;

        // Ensure timer is stopped
        tm_start = 0;

        // Select clock mode
        mode = 2'b00;

        // Allow mode/output MUX to settle
        #2;


        // -----------------------------------------------------
        // Directly initialize internal DUT registers
        // for focused rollover verification.
        //
        // This is acceptable for simulation verification.
        // -----------------------------------------------------

        uut.h1_tens = 4'd2;
        uut.h1_ones = 4'd3;

        uut.m1_tens = 4'd5;
        uut.m1_ones = 4'd9;

        uut.s_tens = 4'd5;
        uut.s_ones = 4'd9;


        // Allow outputs to settle
        #1;

        display_status("BEFORE ROLLOVER");


        // Wait for next logical second
        @(posedge clk_1hz);

        // Allow non-blocking assignments to update
        #1;

        display_status("AFTER ROLLOVER");


        // =====================================================
        // End Simulation
        // =====================================================

        $display("\n========================================");
        $display("ALL TESTS COMPLETED");
        $display("========================================\n");

        #20;

        $finish;

    end


endmodule
