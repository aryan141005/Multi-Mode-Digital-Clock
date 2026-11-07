# Multi-Mode Digital Clock

A multi-functional digital clock designed and simulated using **Verilog/SystemVerilog**. The project integrates multiple time-based functionalities into a single design with different operating modes.

## Features

- 🕒 **Digital Clock Mode**
- ⏱️ **Stopwatch Mode**
- ⏳ **Countdown Timer Mode**
- ⏰ **Alarm Functionality**
- 🔄 **24-Hour Time Rollover**
- 🔁 **Reset Functionality**

---

## Operating Modes

| Mode | Binary Value | Function |
|---|---:|---|
| Clock | `00` | Displays and updates the current time |
| Stopwatch | `01` | Counts elapsed time |
| Countdown Timer | `10` | Counts down from a preset time |

---

## Clock Mode

The clock operates using **hours, minutes, and seconds**.

### Supported functionality

- Seconds increment from `00` to `59`
- Minutes increment after every 60 seconds
- Hours increment after every 60 minutes
- 24-hour rollover is supported

### Verified Rollover

```text
23:59:59 → 00:00:00
```

---

## Stopwatch Mode

The stopwatch supports:

- Start operation
- Stop operation
- Reset operation
- Elapsed time counting

---

## Countdown Timer

The countdown timer:

- Loads a preset time
- Counts down toward `00:00:00`
- Triggers an alarm when the countdown reaches zero

Example preset used during simulation:

```text
00:00:15
```

---

## Alarm Functionality

The design supports a configurable clock alarm.

The alarm is configured using:

- Alarm hour
- Alarm minute
- Alarm enable control

An alarm trigger signal is generated when the configured alarm condition is reached.

Example alarm configuration used during simulation:

```text
01:14:00
```

---

## Project Structure

```text
Multi-Mode-Digital-Clock/
│
├── src/
│   └── digital_clock_plus.sv
│
├── tb/
│   └── digital_clock_plus_tb.sv
│
├── README.md
└── .gitignore
```

---

## Simulation and Verification

The design was verified using a SystemVerilog testbench.

The testbench covers:

- Reset verification
- Clock mode operation
- Minute and hour transitions
- Clock alarm triggering
- Stopwatch start, stop, and reset
- Countdown timer operation
- Timer alarm triggering
- 24-hour rollover verification

### Example Verification Result

```text
TEST 5: 24-HOUR ROLLOVER
Testing 23:59:59 -> 00:00:00

BEFORE ROLLOVER | TIME = 23:59:59
AFTER ROLLOVER  | TIME = 00:00:00

ALL TESTS COMPLETED
```

---

## Simulation

The project can be simulated using **Icarus Verilog**.

Compile and run:

```bash
iverilog -Wall -g2012 -o digital_clock_tb \
    src/digital_clock_plus.sv \
    tb/digital_clock_plus_tb.sv

vvp digital_clock_tb
```

---

## Waveform Generation

The testbench generates a VCD waveform file:

```text
digital_clock_plus_tb.vcd
```

The waveform can be viewed using tools such as **GTKWave**.

```bash
gtkwave digital_clock_plus_tb.vcd
```

---

## Technologies Used

- **Verilog/SystemVerilog**
- **Icarus Verilog**
- **GTKWave**

---

## Author

**Aryan Mishra**

---

## Future Improvements

- FPGA implementation
- Seven-segment display interface
- Button debouncing for hardware controls
- Additional time-setting functionality
- Enhanced alarm configuration

---

⭐ If you found this project interesting, feel free to star the repository!
