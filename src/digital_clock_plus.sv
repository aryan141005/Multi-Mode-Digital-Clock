`timescale 1ns/1ps

module digital_clock_plus(
    input clk_1hz,
    input reset,

    input [1:0] mode,

    // Stopwatch controls
    input sw_start,
    input sw_stop,
    input sw_reset,

    // Timer controls
    input tm_start,
    input tm_reset,

    // Alarm controls
    input alarm_enable,

    input [3:0] alarm_hr_ones,
    input [3:0] alarm_hr_tens,
    input [3:0] alarm_min_ones,
    input [3:0] alarm_min_tens,

    // Timer preset inputs
    input [3:0] tm_hr_ones,
    input [3:0] tm_hr_tens,
    input [3:0] tm_min_ones,
    input [3:0] tm_min_tens,
    input [3:0] tm_sec_ones,
    input [3:0] tm_sec_tens,

    // Outputs
    output reg alarm_trigger,

    output reg [3:0] d_ones,
    output reg [3:0] d_tens,

    output reg [3:0] m_ones,
    output reg [3:0] m_tens,

    output reg [3:0] h_ones,
    output reg [3:0] h_tens
);


    // =========================================================
    // Internal Clock Registers
    // =========================================================

    reg [3:0] s_ones;
    reg [3:0] s_tens;

    reg [3:0] m1_ones;
    reg [3:0] m1_tens;

    reg [3:0] h1_ones;
    reg [3:0] h1_tens;


    // =========================================================
    // Stopwatch Registers
    // =========================================================

    reg [3:0] sw_s_ones;
    reg [3:0] sw_s_tens;

    reg sw_started;


    // =========================================================
    // Timer Registers
    // =========================================================

    reg [3:0] tm_s_ones;
    reg [3:0] tm_s_tens;

    reg [3:0] tm_m_ones;
    reg [3:0] tm_m_tens;

    reg [3:0] tm_h_ones;
    reg [3:0] tm_h_tens;

    reg timer_done;


    // =========================================================
    // Alarm Registers
    // =========================================================

    reg clock_alarm_trigger;
    reg timer_alarm_trigger;


    // =========================================================
    // Main Sequential Logic
    // =========================================================

    always @(posedge clk_1hz or posedge reset) begin

        if (reset) begin

            // Clock reset
            s_ones  <= 0;
            s_tens  <= 0;

            m1_ones <= 0;
            m1_tens <= 0;

            h1_ones <= 0;
            h1_tens <= 0;


            // Stopwatch reset
            sw_s_ones <= 0;
            sw_s_tens <= 0;
            sw_started <= 0;


            // Timer reset
            tm_s_ones <= 0;
            tm_s_tens <= 0;

            tm_m_ones <= 0;
            tm_m_tens <= 0;

            tm_h_ones <= 0;
            tm_h_tens <= 0;

            timer_done <= 0;


            // Alarm reset
            clock_alarm_trigger <= 0;
            timer_alarm_trigger <= 0;

        end

        else begin

            case (mode)


                // =================================================
                // CLOCK MODE
                // =================================================

                2'b00: begin

                    // ---------------------------------------------
                    // Seconds
                    // ---------------------------------------------

                    if (s_ones == 9) begin

                        s_ones <= 0;

                        if (s_tens == 5) begin

                            s_tens <= 0;


                            // -------------------------------------
                            // Minutes
                            // -------------------------------------

                            if (m1_ones == 9) begin

                                m1_ones <= 0;

                                if (m1_tens == 5) begin

                                    m1_tens <= 0;


                                    // ---------------------------------
                                    // Hours
                                    // ---------------------------------

                                    // 23:59:59 -> 00:00:00
                                    if (h1_tens == 2 &&
                                        h1_ones == 3) begin

                                        h1_tens <= 0;
                                        h1_ones <= 0;

                                    end

                                    // 09 -> 10 or 19 -> 20
                                    else if (h1_ones == 9) begin

                                        h1_ones <= 0;
                                        h1_tens <= h1_tens + 1;

                                    end

                                    // Normal hour increment
                                    else begin

                                        h1_ones <= h1_ones + 1;

                                    end

                                end

                                else begin

                                    m1_tens <= m1_tens + 1;

                                end

                            end

                            else begin

                                m1_ones <= m1_ones + 1;

                            end

                        end

                        else begin

                            s_tens <= s_tens + 1;

                        end

                    end

                    else begin

                        s_ones <= s_ones + 1;

                    end


                    // ---------------------------------------------
                    // Clock Alarm
                    // Trigger at configured hour and minute
                    // when seconds = 00.
                    // ---------------------------------------------

                    if (alarm_enable &&

                        h1_tens == alarm_hr_tens &&
                        h1_ones == alarm_hr_ones &&

                        m1_tens == alarm_min_tens &&
                        m1_ones == alarm_min_ones &&

                        s_tens == 0 &&
                        s_ones == 0) begin

                        clock_alarm_trigger <= 1;

                    end

                    else if (clock_alarm_trigger &&
                             s_tens == 0 &&
                             s_ones == 1) begin

                        clock_alarm_trigger <= 0;

                    end

                end


                // =================================================
                // STOPWATCH MODE
                // =================================================

                2'b01: begin

                    if (sw_reset) begin

                        sw_s_ones <= 0;
                        sw_s_tens <= 0;

                        sw_started <= 0;

                    end

                    else if (sw_start && !sw_stop) begin

                        // First start command
                        if (!sw_started) begin

                            sw_started <= 1;

                            sw_s_ones <= 0;
                            sw_s_tens <= 0;

                        end

                        // Continue counting
                        else begin

                            if (sw_s_ones == 9) begin

                                sw_s_ones <= 0;

                                if (sw_s_tens == 5) begin

                                    sw_s_tens <= 0;

                                end

                                else begin

                                    sw_s_tens <= sw_s_tens + 1;

                                end

                            end

                            else begin

                                sw_s_ones <= sw_s_ones + 1;

                            end

                        end

                    end

                    // Otherwise, stopwatch holds its value

                end


                // =================================================
                // TIMER MODE
                // =================================================

                2'b10: begin

                    // ---------------------------------------------
                    // Load Timer Preset
                    // ---------------------------------------------

                    if (tm_reset) begin

                        tm_s_ones <= tm_sec_ones;
                        tm_s_tens <= tm_sec_tens;

                        tm_m_ones <= tm_min_ones;
                        tm_m_tens <= tm_min_tens;

                        tm_h_ones <= tm_hr_ones;
                        tm_h_tens <= tm_hr_tens;

                        timer_done <= 0;

                        timer_alarm_trigger <= 0;

                    end


                    // ---------------------------------------------
                    // Countdown
                    // ---------------------------------------------

                    else if (tm_start && !timer_done) begin

                        if (tm_s_ones > 0) begin

                            tm_s_ones <= tm_s_ones - 1;

                        end

                        else if (tm_s_tens > 0) begin

                            tm_s_tens <= tm_s_tens - 1;
                            tm_s_ones <= 9;

                        end

                        else if (tm_m_ones > 0) begin

                            tm_m_ones <= tm_m_ones - 1;

                            tm_s_tens <= 5;
                            tm_s_ones <= 9;

                        end

                        else if (tm_m_tens > 0) begin

                            tm_m_tens <= tm_m_tens - 1;

                            tm_m_ones <= 9;

                            tm_s_tens <= 5;
                            tm_s_ones <= 9;

                        end

                        else if (tm_h_ones > 0) begin

                            tm_h_ones <= tm_h_ones - 1;

                            tm_m_tens <= 5;
                            tm_m_ones <= 9;

                            tm_s_tens <= 5;
                            tm_s_ones <= 9;

                        end

                        else if (tm_h_tens > 0) begin

                            tm_h_tens <= tm_h_tens - 1;

                            tm_h_ones <= 9;

                            tm_m_tens <= 5;
                            tm_m_ones <= 9;

                            tm_s_tens <= 5;
                            tm_s_ones <= 9;

                        end

                        else begin

                            // Countdown complete
                            timer_done <= 1;

                            timer_alarm_trigger <= 1;

                        end

                    end

                end


                default: begin
                    // Hold all internal states
                end


            endcase

        end

    end


    // =========================================================
    // Final Alarm Output
    // =========================================================

    always @(*) begin

        alarm_trigger =
            clock_alarm_trigger |
            timer_alarm_trigger;

    end


    // =========================================================
    // Output Multiplexer
    // =========================================================

    always @(*) begin

        case (mode)


            // Clock Display
            2'b00: begin

                d_ones = s_ones;
                d_tens = s_tens;

                m_ones = m1_ones;
                m_tens = m1_tens;

                h_ones = h1_ones;
                h_tens = h1_tens;

            end


            // Stopwatch Display
            2'b01: begin

                d_ones = sw_s_ones;
                d_tens = sw_s_tens;

                m_ones = 0;
                m_tens = 0;

                h_ones = 0;
                h_tens = 0;

            end


            // Timer Display
            2'b10: begin

                d_ones = tm_s_ones;
                d_tens = tm_s_tens;

                m_ones = tm_m_ones;
                m_tens = tm_m_tens;

                h_ones = tm_h_ones;
                h_tens = tm_h_tens;

            end


            // Default
            default: begin

                d_ones = 0;
                d_tens = 0;

                m_ones = 0;
                m_tens = 0;

                h_ones = 0;
                h_tens = 0;

            end


        endcase

    end


endmodule
