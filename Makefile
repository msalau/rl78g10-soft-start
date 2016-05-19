PROJECT_ELF=soft-start.elf
PROJECT_MOT=$(PROJECT_ELF:.elf=.mot)
PROJECT_MAP=$(PROJECT_ELF:.elf=.map)
PROJECT_LST=$(PROJECT_ELF:.elf=.lst)

# Find latest installed GNURL78 toolchain. If your toolchain is already in PATH, just comment next line.
TOOL_PATH:=$(shell find /usr/share -maxdepth 1 -type d -iname "gnurl78*" | sort | tail -n 1)/bin

PREFIX:=$(TOOL_PATH)/rl78-elf

LD = $(PREFIX)-gcc
CC = $(PREFIX)-gcc
AS = $(PREFIX)-gcc
OBJCOPY = $(PREFIX)-objcopy
OBJDUMP = $(PREFIX)-objdump
SIZE = $(PREFIX)-size

PROJECT_LNK := rl78-R5F10Y16ASP.ld

CFLAGS  := -g -mcpu=g13 -mmul=g13 -Wall -Wextra -Wno-main -ffunction-sections -fdata-sections
LDFLAGS := -Wl,--gc-sections -Wl,-Map=$(PROJECT_MAP) -T $(PROJECT_LNK) -nostartfiles -nostdlib

OBJS	= main.o crt0.o

.PHONY: all

all: $(PROJECT_MOT) $(PROJECT_LST)
	$(SIZE) $(PROJECT_ELF)

rom: $(PROJECT_MOT)

$(PROJECT_MOT): $(PROJECT_ELF)
	$(OBJCOPY) -O srec $^ $@

$(PROJECT_LST): $(PROJECT_ELF)
	$(OBJDUMP) -DS $^ > $@

$(PROJECT_ELF): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

flash: $(PROJECT_MOT)
	rl78g10flash -vvwr -m1 /dev/ttyUSB0 $^ 2k

clean:
	-rm -f $(OBJS) $(PROJECT_ELF) $(PROJECT_MOT) $(PROJECT_MAP) $(PROJECT_LST)
