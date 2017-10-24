
COMPONENT_OWNBUILDTARGET := true

STM32CUBEMX_FILE ?= $(shell ls $(PROJECT_PATH)/*.ioc)
DEVICE           ?= $(shell cat $(STM32CUBEMX_FILE) | grep PCC.PartNumber | awk -F= '{ print $$2 }')
FEATURES         += $(shell cat $(STM32CUBEMX_FILE) | grep Mcu\.IP[0-9]\*= | awk -F= '{ print $$2 }' | sed 's/[0-9]*$$//g')
export STM32CUBEMX_FILE DEVICE FEATURES

ifeq ($(DEVICE),STM32F051K8Tx)
DEVICE_FAMILY     = STM32F0xx
DEVICE_TYPE       = STM32F051x8
CPU               = -mthumb -mcpu=cortex-m0 -mfloat-abi=soft
RAM               ?= 8192
FLASH             ?= 65536
else ifeq ($(DEVICE),STM32L051K8Tx)
DEVICE_FAMILY     = STM32L0xx
DEVICE_TYPE       = STM32L051xx
CPU               = -mthumb -mcpu=cortex-m0 -mfloat-abi=soft
RAM               ?= 8192
FLASH             ?= 65536
else ifeq ($(DEVICE),STM32F072RBTx)
DEVICE_FAMILY     = STM32F0xx
DEVICE_TYPE       = STM32F072xB
CPU               = -mthumb -mcpu=cortex-m0
RAM               ?= 16384
FLASH             ?= 131072
else ifeq ($(DEVICE),STM32F103RBTx)
DEVICE_FAMILY     = STM32F1xx
DEVICE_TYPE       = STM32F103xB
CPU               = -mthumb -mcpu=cortex-m3
RAM               ?= 20480
FLASH             ?= 131072
else ifeq ($(DEVICE),STM32F103RETx)
DEVICE_FAMILY     = STM32F1xx
DEVICE_TYPE       = STM32F103xE
CPU               = -mthumb -mcpu=cortex-m3
RAM               ?= 65536
FLASH             ?= 524288
else ifeq ($(DEVICE),STM32F103CBTx)
DEVICE_FAMILY     = STM32F1xx
DEVICE_TYPE       = STM32F103xB
CPU               = -mthumb -mcpu=cortex-m3
RAM               ?= 20480
FLASH             ?= 131072
else
$(error Unhandled device $(DEVICE))
endif
export DEVICE_FAMILY DEVICE_TYPE CPU RAM FLASH

$(BUILD_DIR_BASE)/stm32cubemxgen $(BUILD_DIR_BASE)/stm32cubemx-pinout.csv: $(STM32CUBEMX_FILE)
	@mkdir -p $(BUILD_DIR_BASE)/stm32cubemx
	@cat $(COMPONENT_PATH)/stm32cubemx.script | envsubst > $(BUILD_DIR_BASE)/stm32cubemx/stm32cubemx.script
	@cp $(STM32CUBEMX_FILE) $(BUILD_DIR_BASE)/stm32cubemx/stm32cubemx.ioc
	cd $(BUILD_DIR_BASE)/stm32cubemx; $(STM32CUBEMX) -q $(BUILD_DIR_BASE)/stm32cubemx/stm32cubemx.script
	dos2unix $(BUILD_DIR_BASE)/stm32cubemx/Src/main.c
	patch -N $(BUILD_DIR_BASE)/stm32cubemx/Src/main.c < $(COMPONENT_PATH)/src.patch
	sed -i -- 's/FLASH_BASE[[:space:]]*[(][(]uint32_t[)]0x[0-9a-fA-F]*[)]/FLASH_BASE            ((uint32_t)$(LINK_FLASH_START))/g' $(BUILD_DIR_BASE)/stm32cubemx/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include/*
	sed -i -- 's/DATA_EEPROM_BASE[[:space:]]*[(][(]uint32_t[)]0x[0-9a-fA-F]*[)]/DATA_EEPROM_BASE      ((uint32_t)$(LINK_DATA_EEPROM_START))/g' $(BUILD_DIR_BASE)/stm32cubemx/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include/*
	touch $(BUILD_DIR_BASE)/stm32cubemxgen

.PHONY: build
build: $(COMPONENT_LIBRARY) $(BUILD_DIR_BASE)/stm32cubemxgen
	@echo "$(COMPONENT_SRCDIRS)"
	@mkdir -p $(COMPONENT_SRCDIRS)

# Build the archive. We remove the archive first, otherwise ar will get confused if we update
# an archive when multiple filenames have the same name (src1/test.o and src2/test.o)
$(COMPONENT_LIBRARY): $(COMPONENT_OBJS) $(COMPONENT_EMBED_OBJS)
	$(summary) AR $@
	rm -f $@
	$(AR) cru $@ $^
