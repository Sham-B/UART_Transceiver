# UART Transceiver

A complete **UART [Universal Asynchronous Receiver/Transmitter]** implementation in Verilog, including the transmitter, receiver, and a loopback integration for end-to-end verification. Designed for a 100 MHz system clock with a configurable baud rate. Tested in AMD Vivado 2024.1.

## Overview

In asynchronous UART communication, data is sent as serial "frames" of bits without a shared clock signal. Each frame starts with a start bit (logic `0`), followed by a fixed number of data bits, and ends with a stop bit (logic `1`). The line idles at logic `1` when no data is being sent.

This design uses finite-state machines (FSMs) to generate and recognize these bits:

- The **`transmitter`** module drives the TX line low and high for each bit in the frame.
- The **`receiver`** module waits for a falling edge (start bit) on the RX line, then samples each bit at the midpoint of its bit period.

## Features

- **Frame format:** 1 start bit, 8 data bits (LSB first), 1 stop bit — no parity
- **Configurable baud rate** via `baud_rate` and `clk_freq` module parameters, from which `baud_div = clk_freq / baud_rate` is derived internally
- **Modular design:** standalone `transmitter` and `receiver` modules, plus a `uart_loopback` top-level module that ties the transmitter's `tx` output to the receiver's `rx` input
- **FSM-based design:** both modules use a 4-state FSM — `IDLE` → `START` → `DATA` → `STOP`
- **Fully verified:** self-checking testbenches for the transmitter, receiver, and full loopback path

## UART Frame Format

The line idles high (`1`). A low start bit signals the beginning of an 8-bit data byte (sent LSB first), followed by a single high stop bit that marks the end of the frame:

```
Idle(1) — Start(0) — D0 D1 D2 D3 D4 D5 D6 D7 (LSB first) — Stop(1) — Idle(1)
```

This start/stop framing is what allows UART to operate without a shared clock line — both sides simply need to agree on the baud rate.

## Repository Structure

```
UART_Transceiver/
├── rtl/                  # Verilog source modules
│   ├── transmitter.v
│   ├── receiver.v
│   └── uart_loopback.v
├── testbench/             # Verification testbenches
│   ├── tb_transmitter.v
│   ├── tb_receiver.v
│   └── tb_uart_loopback.v
├── waveforms/              # Simulation waveform captures
├── images/                 # Diagrams / documentation images
└── .gitignore
```

## Modules

### `transmitter`

Converts an 8-bit parallel input into a serial output.

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock (e.g., 100 MHz) |
| `rst` | input | Synchronous, active-high reset |
| `tx_start` | input | Pulse high to start a transmission |
| `data_in [7:0]` | input | 8-bit parallel data to send |
| `tx` | output (reg) | Serial TX output line |
| `busy` | output (wire) | High whenever the FSM is not in `IDLE` |
| `data_reg [7:0]` | output (reg) | Internal shift register holding the byte being sent (exposed for debug) |
| `baud_cnt [13:0]` | output (reg) | Internal baud-rate clock divider counter (exposed for debug) |
| `bit_cnt [2:0]` | output (reg) | Internal data-bit index counter (exposed for debug) |
| `state [1:0]` | output (reg) | Current FSM state (exposed for debug) |

**Parameters:** `baud_rate` (default `9600`), `clk_freq` (default `100_000_000`). `baud_div = clk_freq / baud_rate` is computed automatically.

**Operation:** In `IDLE`, the FSM waits for `tx_start` and latches `data_in` into `data_reg`. In `START`, it drives `tx` low for one `baud_div` period. In `DATA`, it shifts `data_reg` out onto `tx` one bit at a time (LSB first), holding each bit for one `baud_div` period until all 8 bits have been sent. In `STOP`, it drives `tx` high for one `baud_div` period before returning to `IDLE`.

### `receiver`

Monitors a serial input line and reconstructs the original 8-bit byte.

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst` | input | Synchronous, active-high reset |
| `rx` | input | Serial RX input line |
| `data_out [7:0]` | output (reg) | 8-bit received data, valid when `rx_done` pulses |
| `rx_done` | output (reg) | Pulses high for one clock cycle when a full byte has been received |
| `baud_cnt [13:0]` | output (reg) | Internal baud-rate clock divider counter (exposed for debug) |
| `bit_cnt [2:0]` | output (reg) | Internal data-bit index counter (exposed for debug) |
| `data_reg [7:0]` | output (reg) | Internal shift register being filled in with incoming bits (exposed for debug) |
| `state [1:0]` | output (reg) | Current FSM state (exposed for debug) |

**Parameters:** `baud_rate` (default `9600`), `clk_freq` (default `100_000_000`). `baud_div = clk_freq / baud_rate` is computed automatically.

**Operation:** In `IDLE`, the FSM waits for `rx` to fall low (start bit). In `START`, it waits half a `baud_div` period and re-checks that `rx` is still low, to confirm a valid start bit and align sampling to the middle of each subsequent bit; a false start returns the FSM to `IDLE`. In `DATA`, it samples `rx` every `baud_div` cycles, shifting each sampled bit into `data_reg` (LSB first) until all 8 bits are captured. In `STOP`, after one more `baud_div` period, it checks that `rx` is high (valid stop bit); if so, it latches `data_reg` onto `data_out` and pulses `rx_done` before returning to `IDLE`.

### `uart_loopback`

Top-level integration module that instantiates one `transmitter` and one `receiver`, connecting the transmitter's `tx` output directly to the receiver's `rx` input, enabling end-to-end verification without external hardware.

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst` | input | Synchronous, active-high reset |
| `start` | input | Pulse high to trigger a transmission |
| `tx_data [7:0]` | input | 8-bit byte to send |
| `rx_data [7:0]` | output | 8-bit byte recovered by the receiver |
| `rx_done` | output | Pulses high when `rx_data` is valid |

**Parameters:** `baud_rate` (default `9600`), `clk_freq` (default `100_000_000`) — passed down to both the internal `transmitter` and `receiver` instances.

## Testbenches

| Testbench | Purpose |
|---|---|
| `tb_transmitter` | Instantiates `transmitter` (with a fast `clk_freq(100)` / `baud_rate(10)` for quick simulation), releases reset, pulses `tx_start` with `data_in = 8'hA5`, and lets the design run to completion |
| `tb_receiver` | Instantiates `receiver` (same fast timing) and manually drives a bit sequence onto `rx` to emulate a UART frame, checking that the FSM samples and reassembles it correctly |
| `tb_uart_loopback` | Instantiates `uart_loopback`, resets it, sends `tx_data = 8'h55` via `start`, waits for the transfer to complete, and self-checks the result with `if (rx_data == 8'h55) $display("PASS"); else $display("FAIL");` |

> **Note:** All three testbenches use scaled-down `clk_freq` / `baud_rate` parameters (e.g., `clk_freq(100)`, `baud_rate(10)`) purely to keep simulation run times short. Use realistic values (e.g., `100_000_000` / `9600`) for synthesis and hardware deployment.

## Getting Started

### Simulation

1. Open the project in Vivado (or any Verilog simulator).
2. Run `tb_uart_loopback` for a full end-to-end test — it sends a byte through the transmitter, loops it back into the receiver, and prints `PASS` or `FAIL` based on the result.
3. Inspect the `tx` / `rx` waveforms (see `waveforms/`) to confirm correct framing and bit timing.

### Hardware (e.g., Basys 3 FPGA)

1. Instantiate `transmitter` and `receiver` (or the combined `uart_loopback`) and connect the TX/RX pins as needed.
2. For an on-board loopback test, wire the `tx` output pin directly to the `rx` input pin.
3. Drive `data_in` / `tx_data` (e.g., from switches) and pulse `tx_start` / `start`; observe `data_out` / `rx_data` on LEDs or another output interface.

### Setting the Baud Rate

Set the `baud_rate` and `clk_freq` parameters to match your target clock frequency and desired baud rate on both the `transmitter` and `receiver` instances so they agree on bit timing:

```
baud_div = clk_freq / baud_rate
```

Example: 100 MHz clock, 9600 baud → `baud_div ≈ 10417`

## Author
Sham-B
