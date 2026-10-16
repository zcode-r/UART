# ⚡ Synchronous UART Controller (SystemVerilog)

A modular **Universal Asynchronous Receiver-Transmitter (UART)** controller implemented in SystemVerilog. This project features a configurable 16× oversampling baud rate generator, an FSM-driven transmitter, a center-sampling receiver, and a self-checking loopback testbench verified using Icarus Verilog and GTKWave.

## 📌 Project Architecture

```text
UART/
├── rtl/
│   ├── baud_generator.sv
│   ├── uart_tx.sv
│   ├── uart_rx.sv
│   └── uart_top.sv
├── tb/
│   └── uart_tb.sv
├── images/
│   └── uart_waveform.png
└── README.md
```

## 🚀 Features

- **Configurable Baud Generator:** Generates 16× oversampling ticks based on the system clock frequency and target baud rate.
- **UART Transmitter:** Implements a finite state machine (FSM) to transmit 8-bit data, LSB first, with one start bit and one stop bit.
- **UART Receiver:** Uses 16× oversampling and center-aligned sampling to receive serial data.
- **Loopback Communication:** Connects the transmitter output to the receiver input for end-to-end verification.
- **Self-Checking Testbench:** Automatically compares transmitted and received bytes and reports test results.
- **Waveform Verification:** Supports signal inspection using GTKWave.

## 🧠 UART Architecture

### 1. Baud Rate Generator

Generates timing ticks for the transmitter and receiver using the configured system clock frequency and baud rate.

Example configuration:

- System clock frequency: 50 MHz
- Target baud rate: 9600 baud
- Oversampling factor: 16×

### 2. UART Transmitter (`uart_tx.sv`)

The transmitter serializes parallel data into a UART frame.

**FSM states:**

1. **IDLE:** Keeps the TX line HIGH and waits for a transmission request.
2. **START:** Transmits the start bit by driving the TX line LOW.
3. **DATA:** Transmits 8 data bits, starting with the least significant bit (LSB).
4. **END:** Transmits the stop bit by driving the TX line HIGH and signals completion.

### 3. UART Receiver (`uart_rx.sv`)

The receiver detects the start bit and reconstructs the original parallel data from the incoming serial stream.

**FSM states:**

1. **IDLE:** Monitors the RX line for a falling edge.
2. **START:** Validates the start bit using oversampling ticks.
3. **DATA:** Samples the incoming data bits at the appropriate bit intervals.
4. **END:** Processes the stop bit and signals successful reception.

### 4. Top Module (`uart_top.sv`)

Connects the baud generator, transmitter, and receiver to create a complete UART loopback system.

### 5. Testbench (`uart_tb.sv`)

A self-checking testbench drives the transmitter, monitors the receiver, and compares the received data against the transmitted data.

## 📊 Simulation and Verification

The design can be simulated using **Icarus Verilog** and its waveforms inspected using **GTKWave**.

### Test Cases

The testbench verifies the transmission and reception of the following data bytes:

| Test Case | Transmitted Data | Expected Received Data |
|---|---|---|
| 1 | `0xA5` | `0xA5` |
| 2 | `0x3C` | `0x3C` |
| 3 | `0xFF` | `0xFF` |

### Expected Testbench Output

```text
================ STARTING UART LOOPBACK TEST ================

[SIM] Transmitting Byte: 8'ha5 (165)
>>> [RESULT] SUCCESS! Sent: 8'ha5 | Received: 8'ha5 <<<

---------------------------------------------------------

[SIM] Transmitting Byte: 8'h3c (60)
>>> [RESULT] SUCCESS! Sent: 8'h3c | Received: 8'h3c <<<

---------------------------------------------------------

[SIM] Transmitting Byte: 8'hff (255)
>>> [RESULT] SUCCESS! Sent: 8'hff | Received: 8'hff <<<

================ ALL TESTS COMPLETED ================
```

> **Note:** The output above represents the expected results. Actual output depends on the testbench implementation and simulation results.

### GTKWave Waveform

The waveform can be viewed in GTKWave to inspect the UART transmission and reception signals.

Save your waveform screenshot as:

`images/uart_waveform.png`

<img width="811" height="101" alt="Screenshot 2026-10-16 232551" src="https://github.com/user-attachments/assets/932d9f69-8266-4329-ad67-5e4359397aa1" />


## 🛠️ Tools and Technologies

- **SystemVerilog** — RTL design
- **Icarus Verilog** — Compilation and simulation
- **GTKWave** — Waveform visualization
- **Linux / WSL2** — Development environment
- **Git and GitHub** — Version control and project hosting

## ⚙️ How to Run the Project

### Prerequisites

Install Icarus Verilog and GTKWave on Ubuntu or WSL2:

```bash
sudo apt update
sudo apt install iverilog gtkwave
```

### 1. Navigate to the Project Directory

```bash
cd UART
```

### 2. Compile the Design

```bash
iverilog -g2012 -o uart_sim.out \
rtl/baud_generator.sv \
rtl/uart_tx.sv \
rtl/uart_rx.sv \
rtl/uart_top.sv \
tb/uart_tb.sv
```

### 3. Run the Simulation

```bash
vvp uart_sim.out
```

### 4. View the Waveform

If the testbench generates `dump.vcd`, open it using:

```bash
gtkwave dump.vcd
```

**Note:** Ensure that your testbench contains the appropriate `$dumpfile` and `$dumpvars` statements to generate the VCD waveform file.

## 📚 Concepts Demonstrated

- UART serial communication
- Finite state machines (FSMs)
- Baud rate generation
- Clock enables and timing counters
- Serial-to-parallel and parallel-to-serial conversion
- Oversampling and center-aligned sampling
- Self-checking testbenches
- RTL simulation and waveform debugging

## 🔮 Future Improvements

- Configurable data width and baud rate
- Parity-bit generation and checking
- Support for different frame formats
- Error detection for framing and invalid start bits
- More extensive randomized and corner-case testing
- FPGA synthesis and hardware validation

## 📜 License

This project is intended for educational and learning purposes. Add an appropriate open-source license, such as the MIT License, if you intend to distribute it under that license.

---

**Developed as a digital design project using SystemVerilog.**
