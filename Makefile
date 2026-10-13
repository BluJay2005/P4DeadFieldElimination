# --- P4-LLVM ASIC Metadata Optimizer Build Engine ---

# 1. System Variables (Using your verified path as the base default)
LLVM_PATH ?= /opt/homebrew/Cellar/llvm/23.1.3_1
CXX       = clang++
CXXFLAGS  = -shared -fPIC -std=c++17 -fno-rtti -I$(LLVM_PATH)/include
LDFLAGS   = -L$(LLVM_PATH)/lib -Wl,-undefined,dynamic_lookup

# 2. Output Target Artifacts
PLUGIN    = P4Optimizer.dylib
SRC       = P4DeadFieldElimination.cpp
TEST_IR   = packet.ll

# 3. Phony Targets
.PHONY: all build run clean help

all: build run

build: $(PLUGIN)

$(PLUGIN): $(SRC)
	@echo "Compiling P4-LLVM optimization pass into shared library..."
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(SRC) -o $(PLUGIN)
	@echo "Successfully built $(PLUGIN)!"

run: $(PLUGIN) $(TEST_IR)
	@echo "Executing static analysis pass over $(TEST_IR)..."
	@echo ""
	@$(LLVM_PATH)/bin/opt -load-pass-plugin=./$(PLUGIN) -passes="p4-dead-field-elim" -disable-output $(TEST_IR)
	@echo ""

clean:
	@echo "Cleaning up built artifacts..."
	rm -f $(PLUGIN)

help:
	@echo "Available commands:"
	@echo "  make build  - Compile the C++ LLVM optimizer plugin"
	@echo "  make run    - Run the optimizer pass against the test packet IR"
	@echo "  make all    - Build and run the pipeline sequentially (Default)"
	@echo "  make clean  - Remove compiled binaries"
