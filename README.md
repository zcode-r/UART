# UART Communication System in Verilog

## Overview

This project implements a complete UART (Universal Asynchronous Receiver Transmitter) communication system in Verilog HDL.

The design consists of:

* Baud Rate Generator
* UART Transmitter (TX)
* UART Receiver (RX)
* Top-Level UART Integration Module
* Loopback Testbench

The transmitter and receiver communicate through an internal loopback connection, allowing transmitted data to be received and verified within the same design.

---

## Features

* UART Transmitter (8-bit data frame)
* UART Receiver with 16x oversampling
* Configurable baud rate generator
* FSM-based TX and RX architecture
* Start bit detection
* Stop bit generation and validation
* Internal loopback testing
* Fully synthesizable Verilog design
* Simulation support using GTKWave/VCD dumps

---

## Project Structure

```text
uart_project/
│
├── uart_top.v
├── baud_generator.v
├── uart_tx.v
├── uart_rx.v
├── uart_system_tb.v
│
├── dump.vcd
└── README.md
```

---

## Module Description

### 1. Baud Generator

Generates a baud tick used by both the transmitter and receiver.

Parameters:

* `master_clk`
* `baud`

The baud generator creates a tick at 16× the desired baud rate to support receiver oversampling.

---

### 2. UART Transmitter (TX)

The transmitter sends data serially using the following frame format:

```text
Idle | Start Bit | 8 Data Bits | Stop Bit
  1  |     0     |    LSB First |    1
```

#### TX FSM States

* IDLE
* START
* DATA
* END

Functions:

* Loads input data into a shift register
* Sends bits serially
* Generates `tx_done` after transmission completes

---

### 3. UART Receiver (RX)

The receiver reconstructs serial data back into an 8-bit parallel word.

#### RX FSM States

* IDLE
* START
* DATA
* END

Functions:

* Detects start bit
* Samples incoming bits using 16× oversampling
* Stores received bits in a shift register
* Generates `rx_done` after reception completes

---

### 4. UART Top Module

Integrates:

* Baud Generator
* UART TX
* UART RX

A loopback wire connects:

```text
TX ---> RX
```

allowing transmitted data to be immediately received and verified.

---

## Simulation Flow

1. Apply reset.
2. Load transmit data.
3. Assert `tx_start`.
4. Transmitter sends serial frame.
5. Receiver detects start bit.
6. Receiver samples incoming bits.
7. Received data is reconstructed.
8. `rx_done` is asserted.
9. Testbench compares transmitted and received data.

---

## Testbench

The testbench performs:

* System reset
* Data transmission
* Reception monitoring
* Automatic verification
* VCD waveform generation

Example test vector:

```text
TX Data : 0x5A
RX Data : 0x5A
Result  : PASS
```

---

## UART Frame Format

```text
| Start | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | Stop |
|   0   |    8-bit Data (LSB First)     |  1   |
```

---

## Example Simulation Output

```text
UART LOOPBACK TEST STARTED

Transmitting : 0x5A

RX_DONE asserted

TEST PASSED

Expected : 0x5A
Received : 0x5A
```

---

## Tools Used

* Verilog HDL
* Icarus Verilog
* GTKWave

---
