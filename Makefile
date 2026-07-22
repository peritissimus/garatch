# Garatch Monorepo Makefile
# Supports multiple watch faces

# Default face and device
FACE ?= garatch-blueprint
DEVICE ?= venusq2
DEV_KEY ?= developer_key.der

# Paths
FACE_DIR = faces/$(FACE)
PROJECT_FILE = $(FACE_DIR)/monkey.jungle
OUTPUT = bin/$(FACE).prg

# Default target
.PHONY: all
all: build

# Build a specific watch face
.PHONY: build
build:
	@echo "Building $(FACE) for $(DEVICE)..."
	@mkdir -p bin
	monkeyc -d $(DEVICE) -f $(PROJECT_FILE) -o $(OUTPUT) -y $(DEV_KEY) -g
	@echo "Output: $(OUTPUT)"

# Run in simulator
.PHONY: run
run: build
	@echo "Running $(FACE) in simulator..."
	monkeydo $(OUTPUT) $(DEVICE)

# Start simulator
.PHONY: simulator
simulator:
	@echo "Starting Connect IQ simulator..."
	connectiq &

# Capture a PNG of the face from the running simulator window.
#
# Garmin's SDK has no headless screenshot (the simulator's "Save Screenshot"
# only opens a save dialog), so this grabs the sim window with macOS
# screencapture. Needs the sim running with the face loaded (make simulator,
# then make run in another terminal) and a one-time "Screen Recording"
# permission for your terminal (System Settings > Privacy & Security).
#
#   make screenshot                       # click the sim window to capture
#   make screenshot WINDOW_ID=<id>        # non-interactive (see: make sim-window)
SHOT ?= bin/$(FACE).png
WINDOW_ID ?=
.PHONY: screenshot
screenshot:
ifeq ($(WINDOW_ID),)
	@echo "Click the simulator's watch window to capture -> $(SHOT)"
	@screencapture -o -x -w "$(SHOT)"
else
	@screencapture -o -x -l$(WINDOW_ID) "$(SHOT)"
endif
	@echo "Saved $(SHOT)"
	@sips -g pixelWidth -g pixelHeight "$(SHOT)" 2>/dev/null | awk '/pixelWidth|pixelHeight/{print "  "$$1" "$$2}'

# Print the simulator's on-screen window id (for screenshot WINDOW_ID=...).
.PHONY: sim-window
sim-window:
	@osascript -e 'tell application "System Events" to tell (first process whose name contains "simulator") to get id of window 1' 2>/dev/null \
		|| echo "Could not read window id (needs Accessibility permission for your terminal)."

# Build and run
.PHONY: test
test: build run

# List available faces
.PHONY: list
list:
	@echo "Available watch faces:"
	@ls -1 faces/

# Build all faces
.PHONY: build-all
build-all:
	@for face in $$(ls faces/); do \
		echo "Building $$face..."; \
		$(MAKE) build FACE=$$face; \
	done

# Clean build artifacts for one face
.PHONY: clean
clean:
	@echo "Cleaning $(FACE)..."
	rm -f bin/$(FACE).prg
	rm -f bin/$(FACE).prg.debug.xml

# Clean all build artifacts
.PHONY: clean-all
clean-all:
	@echo "Cleaning all build artifacts..."
	rm -rf bin/
	rm -rf gen/

# Create a new watch face from template
.PHONY: new
new:
ifndef NAME
	$(error NAME is required. Usage: make new NAME=my-new-face)
endif
	@echo "Creating new watch face: $(NAME)"
	@mkdir -p faces/$(NAME)/source faces/$(NAME)/resources/drawables faces/$(NAME)/resources/layouts faces/$(NAME)/resources/strings faces/$(NAME)/resources/settings
	@cp faces/garatch-blueprint/manifest.xml faces/$(NAME)/
	@cp faces/garatch-blueprint/monkey.jungle faces/$(NAME)/
	@echo "New face created at faces/$(NAME)/"
	@echo "Don't forget to update the app ID in manifest.xml!"

# Show project info
.PHONY: info
info:
	@echo "Garatch Monorepo"
	@echo "================"
	@echo ""
	@echo "Current face: $(FACE)"
	@echo "Device: $(DEVICE)"
	@echo "Output: $(OUTPUT)"
	@echo ""
	@echo "Commands:"
	@echo "  make build              - Build current face"
	@echo "  make build FACE=name    - Build specific face"
	@echo "  make run                - Build and run in simulator"
	@echo "  make list               - List available faces"
	@echo "  make build-all          - Build all faces"
	@echo "  make new NAME=name      - Create new face from template"
	@echo "  make clean              - Clean current face"
	@echo "  make clean-all          - Clean all artifacts"
	@echo ""
	@echo "Examples:"
	@echo "  make build FACE=garatch-blueprint DEVICE=venusq2"
	@echo "  make new NAME=garatch-minimal"

# Watch for changes
.PHONY: watch
watch:
	@echo "Watching $(FACE) for changes..."
	@which fswatch > /dev/null || (echo "Error: fswatch not installed. Run: brew install fswatch" && exit 1)
	@fswatch -o $(FACE_DIR)/source/ $(FACE_DIR)/resources/ shared/source/ | xargs -n1 -I{} sh -c 'clear && make run FACE=$(FACE)'

.PHONY: help
help: info
