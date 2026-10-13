# P4-LLVM ASIC Metadata Optimizer

A custom LLVM optimization pass written in C++ that performs static analysis on lowered P4 network packet structures to eliminate dead hardware metadata fields. This tool mimics the processing pipelines utilized by hardware manufacturers to maximize high speed register efficiency on programmable ASIC network chips.

## Project Architecture

1. **Frontend Input (`packet.ll`):** A mockup in LLVM Intermediate Representation (IR) defining a packet layout containing an actively read field (`source_ip`) and an unreferenced field (`telemetry_tag`).

2. **Analysis Pass (`P4DeadFieldElimination.cpp`):** A custom C++ compiler pass using LLVM API type casting (`GetElementPtrInst`) to trace precisely which struct offsets are accessed by instructions.

3. **Hardware Mapping Optimization:** Generates an optimization report pinpointing dead infrastructure layout fields, allowing hardware allocators to reclaim register space.

## Prerequisites

This project targets macOS environments running Apple Silicon (arm64) and requires LLVM 23 installed via Homebrew.

Ensure your environment matches the expected toolchain path:
* **LLVM Installation Path:** `/opt/homebrew/Cellar/llvm/23.1.3_1`
* **Compiler:** `clang++` (supporting C++17 or newer)

## Installation and Build Automation

The repository includes a `setup.sh` script to verify paths and a `Makefile` to handle complex compilation flags.

### 1. Verify Environment
Execute the environment validation script to confirm library paths:
```bash
chmod +x setup.sh
./setup.sh
```

### 2. Build and Execute Pass
To compile the C++ source file into a macOS shared library (`.dylib`) and execute the static analysis pass over the target IR in a single step, run:
```bash
make
```

### 3. Granular Build Targets
You can invoke specific lifecycle components using the following Makefile targets:

| Command | Action Performed |
| :--- | :--- |
| `make build` | Compiles the C++ source into `P4Optimizer.dylib` with required LLVM flags. |
| `make run` | Runs the compiled pass plugin via the `opt` tool against `packet.ll`. |
| `make clean` | Removes compiled binary artifacts (`.dylib`) from the project directory. |
| `make help` | Displays all available build targets. |

## Expected Execution Output

Upon successful execution, the tool outputs an optimization log confirming field access detection:

```text
Analyzing Network Pipeline Function: process_packet
--- OPTIMIZATION REPORT FOR AMD ASIC --- 
» Field (Source IP): ACTIVE
» Field (Telemetry Tag): DEAD - STRIP IT
```

## Vocabulary and Concepts Applied

* **LLVM Intermediate Representation (IR):** A strongly typed, universal assembly language that enables target independent program optimization.
* **Static Analysis:** The process of evaluating source or intermediate code behavior without executing the underlying program binaries.
* **GetElementPtr (GEP):** The native LLVM instruction format used to calculate the effective memory addresses of structure fields and array elements.
