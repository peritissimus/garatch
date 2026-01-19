# Garatch Watch Face Makefile

# Variables
DEVICE = venusq2
PROJECT_FILE = monkey.jungle
OUTPUT = garatch.prg
DEV_KEY = developer_key.der

# Default target
.PHONY: all
all: build

# Build the watch face
.PHONY: build
build:
	@echo "Building watch face..."
	monkeyc -d $(DEVICE) -f $(PROJECT_FILE) -o $(OUTPUT) -y $(DEV_KEY) -g

# Run in simulator
.PHONY: run
run: build
	@echo "Running in simulator..."
	monkeydo $(OUTPUT) $(DEVICE)

# Start simulator (background)
.PHONY: simulator
simulator:
	@echo "Starting Connect IQ simulator..."
	connectiq &

# Build and run (most common workflow)
.PHONY: test
test: build
	@echo "Testing watch face..."
	monkeydo $(OUTPUT) $(DEVICE)

# Quick build and run
.PHONY: dev
dev: build run

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(OUTPUT)
	rm -f $(OUTPUT).debug.xml
	rm -rf bin/
	rm -rf gen/

# Full clean (including generated files)
.PHONY: clean-all
clean-all: clean
	@echo "Cleaning all generated files..."
	rm -rf .vscode/

# Show project info
.PHONY: info
info:
	@echo "Project: Garatch Watch Face"
	@echo "Device: $(DEVICE)"
	@echo "Output: $(OUTPUT)"
	@echo ""
	@echo "Available commands:"
	@echo "  make build      - Compile the watch face"
	@echo "  make run        - Build and run in simulator"
	@echo "  make simulator  - Start the simulator"
	@echo "  make test       - Build and test"
	@echo "  make dev        - Quick build and run"
	@echo "  make clean      - Remove build artifacts"
	@echo "  make clean-all  - Remove all generated files"
	@echo "  make info       - Show this help"

# Help target
.PHONY: help
help: info
