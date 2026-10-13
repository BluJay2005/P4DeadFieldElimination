#!/bin/bash

# --- Environment Verification Script ---
echo "Checking system configuration for P4-LLVM Compiler Pass..."

# 1. Check for Homebrew LLVM path
EXPECTED_PATH="/opt/homebrew/Cellar/llvm/23.1.3_1"

if [ -d "$EXPECTED_PATH" ]; then
    echo "Verified: LLVM 23 installation discovered at $EXPECTED_PATH"
else
    echo "Error: LLVM 23 directory not found at $EXPECTED_PATH"
    echo "Please run: brew install llvm"
    exit 1
fi

# 2. Provide user instructions
echo "Ready to build. To compile and execute the pass immediately, run:"
echo "make"
