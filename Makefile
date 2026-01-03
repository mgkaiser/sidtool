PRERELEASE_VERSION ?= "01"

ifdef RELEASE_VERSION
	VERSION_DEFINE="-DRELEASE_VERSION=$(RELEASE_VERSION)"
else
	ifdef PRERELEASE_VERSION
		VERSION_DEFINE="-DPRERELEASE_VERSION=$(PRERELEASE_VERSION)"
	endif
endif

CC		   = cc65
AS		   = ca65
LD		   = ld65

# global includes
ASFLAGS	 += -I inc
ASFLAGS	 += $(VERSION_DEFINE)
ASFLAGS	 += -g
ASFLAGS	 += --cpu 6502
ASFLAGS	 += --relax-checks

BUILD_DIR=build/c64
#EMU_DIR1=/mnt/c/x16emu_win64-r49/drive
C64U_ADDRESS=192.168.0.39
CFG_DIR=$(BUILD_DIR)/cfg

MAIN_ROOT = sidtest

# Define sources for the main program and overlays
MAIN_SOURCES = 	src/main.s \
				src/print.s \
				src/math.s \
				src/help.s 

# Define output binaries
MAIN_BIN = $(BUILD_DIR)/$(MAIN_ROOT).prg

# Define object files
MAIN_OBJS = $(addprefix $(BUILD_DIR)/, $(MAIN_SOURCES:.s=.o))

# Define configuration templates and generated configs
MAIN_CFG_TPL = cfg/$(MAIN_ROOT).cfgtpl

MAIN_CFG = $(CFG_DIR)/$(MAIN_ROOT).cfg

# Default target
all: $(MAIN_BIN)

# Install target	

test: all
	@echo "Running $(MAIN_BIN) on C64U ..."
	curl -X POST http://$(C64U_ADDRESS)/v1/runners:load_prg -H "Content-Type: application/json" -H "X-Password: $(C64U_Password)" -d '{"path": "$(MAIN_BIN)"}'

# Clean target
clean:
	rm -rf $(BUILD_DIR)
	#rm -rf $(EMU_DIR1)/$(MAIN_BIN)	

# Generate configuration files
$(CFG_DIR)/%.cfg: cfg/%.cfgtpl
	@mkdir -p $$(dirname $@)
	$(CC) -E $< -o $@
	cat $@ | sed "s!@BUILD_DIR@!$(BUILD_DIR)!" > $@.tmp
	mv $@.tmp $@	

# Compile assembly files
$(BUILD_DIR)/%.o: %.s
	@mkdir -p $$(dirname $@)
	$(AS) $(ASFLAGS) -l $(BUILD_DIR)/$*.lst $< -o $@

# Link main program
$(MAIN_BIN): $(MAIN_OBJS) $(MAIN_CFG) 
	@mkdir -p $$(dirname $@)
	$(LD) -C $(MAIN_CFG) $(MAIN_OBJS) -o $@ -m $(BUILD_DIR)/$(MAIN_ROOT).map -Ln $(BUILD_DIR)/$(MAIN_ROOT).sym 