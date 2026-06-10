# Droidspaces v6 - droidspaces-socketd build system
# SPDX-License-Identifier: GPL-3.0-or-later

ROOT_DIR := ../..
SRC_DIR  := .
OUT_DIR  := $(ROOT_DIR)/output
OBJ_DIR  := $(OUT_DIR)/.obj/socketd

BINARY_NAME := droidspaces-socketd
TARGET      := $(OUT_DIR)/$(BINARY_NAME)

CXX ?= g++

# Verbose control - V=1 shows full commands, V=0 keeps output tidy
V ?= 0

# Static link control - off by default
STATIC ?= 0

ifeq ($(V),1)
  Q       =
  msg_cxx =
  msg_ld  =
else
  Q       = @
  msg_cxx = @printf "  CXX     %s\n" $<
  msg_ld  = @printf "  CXXLD   %s\n" $@
endif

CXXFLAGS ?= -Wall -Wextra -Wpedantic -Werror \
            -O2 -std=c++17 \
            -I$(SRC_DIR) -I$(ROOT_DIR)/src/include

LDFLAGS ?=
LDLIBS   ?=

ifeq ($(STATIC),1)
  LDFLAGS += -static
endif

SRCS := \
	main.cpp \
	backend_client.cpp \
	container_list.cpp \
	container_inspect.cpp \
	snapshot_lists.cpp \
	event_log.cpp \
	api_server.cpp

OBJS := $(SRCS:%.cpp=$(OBJ_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

.PHONY: all clean help format

all: $(TARGET)

help:
	@echo "droidspaces-socketd build system"
	@echo ""
	@echo "Targets:"
	@echo "  make        - Build $(BINARY_NAME)"
	@echo "  make clean  - Remove socketd build artifacts"
	@echo "  make format - Run clang-format on all .cpp/.h files"
	@echo ""
	@echo "Options:"
	@echo "  V=1         - Show full compiler commands"
	@echo "  CXX=...     - Override the C++ compiler"
	@echo "  STATIC=1    - Link droidspaces-socketd statically"

$(OUT_DIR):
	$(Q)mkdir -p $(OUT_DIR)

$(OBJ_DIR):
	$(Q)mkdir -p $(OBJ_DIR)

$(TARGET): $(OBJS) | $(OUT_DIR)
	$(msg_ld)
	$(Q)$(CXX) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

$(OBJ_DIR)/%.o: %.cpp | $(OBJ_DIR)
	$(msg_cxx)
	$(Q)$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

format:
	@command -v clang-format >/dev/null 2>&1 || { echo "Error: clang-format not found"; exit 1; }
	@find $(SRC_DIR) -name '*.cpp' -o -name '*.h' | xargs clang-format -i
	@echo "[+] Formatted all source files"

clean:
	$(Q)rm -rf $(OBJ_DIR)
	$(Q)rm -f $(TARGET)

-include $(DEPS)
