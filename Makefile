# ---------------------------------------------------------------------------
# Compiler dir_env define
# ---------------------------------------------------------------------------
 
TOP_DIR 	:= $(shell pwd)
BUILD_DIR 	:= $(TOP_DIR)/build
TOOLS_DIR 	:= $(TOP_DIR)/tools
COMP_DIR 	:= $(TOP_DIR)/components
ENGINE_DIR 	:= $(TOP_DIR)/engine
PROG_DIR    := $(TOP_DIR)/entry
TEST_DIR    := $(TOP_DIR)/test
UTILS_DIR   := $(TOP_DIR)/utils
BIN_DIR 	:= $(BUILD_DIR)/bin
LIBS_DIR 	:= $(BUILD_DIR)/libs
UI_DIR 		:= $(TOP_DIR)/ui
# Attempt to create a output target directory.
$(shell [ -d ${BUILD_DIR} ] || mkdir -p ${BUILD_DIR} && mkdir -p ${LIBS_DIR} && mkdir -p ${BIN_DIR})

include $(TOOLS_DIR)/config.mk

export TOP_DIR LIBS_DIR TOOLS_DIR COMP_DIR ENGINE_DIR UTILS_DIR

# ---------------------------------------------------------------------------
# OBJS include the necessary directories and the source files 
# ---------------------------------------------------------------------------
SUB_DIRS = adapter $(COMP_DIR)/linkkit $(COMP_DIR)/ulog $(COMP_DIR)/das $(COMP_DIR)/http $(COMP_DIR)/und $(COMP_DIR)/ota $(ENGINE_DIR)/duktape_engine main services $(UTILS_DIR)/cJSON $(UTILS_DIR)/mbedtls 

LDFLAGS := -L$(LIBS_DIR) -lmain -ljsengine -lhttp -lulog -lservices -lota -llinkkit -ldas -lund

INCLUDES := \
		internal \
		adapter/include \
		components/linkkit \
		components/linkkit/infra \
		components/ulog \
		components/ota/include \
		components/ota/ota_agent/tools \
		utils/mbedtls/include \
		adapter/platform/linux

LDFLAGS += -ladapter -lmbedtls -lcjson -lpthread -lrt -lm

$(foreach inc, $(INCLUDES), $(eval ALL_INCS += -I$(inc)))

ALL_OBJS = $(addprefix $(LIBS_DIR)/, $(SUB_DIRS))

PROG_TARGET := amp

ADDON = $(m)
export CCFLAGS 
export ADDON

.PHONY: all clean $(SUB_DIRS) prog libjs

prog: all $(PROG_TARGET)

libjs:
	cd libjs && npm run build
	cd ..

all: $(BIN_DIR)/lib

$(BIN_DIR)/lib: $(ALL_OBJS)
	$(ECHO) Build haas amp start...
	$(ECHO) Done!!!

$(ALL_OBJS): $(SUB_DIRS)
$(SUB_DIRS):
	$(MAKE) -C $@

$(PROG_TARGET): $(ALL_OBJS)
	$(ECHO) Linkking...
	$(CC) $(ALL_INCS) -o $(BIN_DIR)/$@ $(PROG_DIR)/amp_entry.c  $(UI_FILES) $(LDFLAGS)

clean:
	$(RM) $(shell find ./ -name "*.[o|d|a]")
	$(RM) $(LIBS_DIR)
	$(RM) $(BIN_DIR)/amp
	$(ECHO) clean Done... 