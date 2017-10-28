
STM32CUBEMX_GEN_DIR      := $(BUILD_DIR_BASE)/stm32cubemxgen
STM32CUBEMX_GEN_FILE     := $(STM32CUBEMX_GEN_DIR)/stm32cubemxgen

LINK_FLASH_START = $(CONFIG_LINK_FLASH_START)
LINK_RAM_START = $(CONFIG_LINK_RAM_START)
LINK_DATA_EEPROM_START = $(CONFIG_LINK_DATA_EEPROM_START)
export LINK_FLASH_START LINK_RAM_START LINK_DATA_EEPROM_START

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

define COMPONENT_ADDITIONAL_VARS
DEVICE_FAMILY = $(DEVICE_FAMILY)
DEVICE_TYPE = $(DEVICE_TYPE)
CPU = $(CPU)
RAM = $(RAM)
FLASH = $(FLASH)
endef

STARTUP_FILE   ?= $(shell echo $(DEVICE_TYPE) | tr A-Z a-z)
DEVICE_FAMILYL = $(shell echo $(DEVICE_FAMILY) | tr A-Z a-z)
LDSCRIPT       = $(STM32CUBEMX_GEN_DIR)/FLASH.ld

CMSIS_OPT      = -D$(DEVICE_FAMILY) -D$(DEVICE_TYPE) $(USE_FULL_ASSERT) -DUSE_HAL_DRIVER

LINK_FLASH_LENGTH = $(FLASH)
LINK_RAM_LENGTH   = $(RAM)
LINK_END_OF_RAM   = $(shell printf "0x%x" $$(echo "scale=1; $$(printf '%d' 0x20000000)+8192" | bc -l))
export LINK_FLASH_LENGTH LINK_RAM_LENGTH LINK_END_OF_RAM

SRCS = \
	Src/main.c \
	Src/$(DEVICE_FAMILYL)_hal_msp.c \
	Src/$(DEVICE_FAMILYL)_it.c \
	Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Source/Templates/system_$(DEVICE_FAMILYL).c \
	Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Source/Templates/gcc/startup_$(STARTUP_FILE).s \
	Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal.c \
	Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_rcc.c \
	Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_rcc_ex.c \
	Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_gpio.c \
	Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_dma.c \
	Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_cortex.c

# Add features source files
ifneq (,$(findstring ADC,$(FEATURES)))
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_adc.c
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_adc_ex.c
endif

ifneq (,$(findstring SPI,$(FEATURES)))
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_spi.c
endif

ifneq (,$(findstring USART,$(FEATURES)))
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_uart.c
endif

ifneq (,$(findstring IWDG,$(FEATURES)))
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_iwdg.c
endif

ifneq (,$(findstring TIM,$(FEATURES)))
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_tim.c
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_tim_ex.c
endif

ifneq (,$(findstring I2C,$(FEATURES)))
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_i2c.c
endif

ifneq (,$(findstring FLASH,$(FEATURES)))
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_flash.c
endif

ifneq (,$(findstring FLASHEX,$(FEATURES)))
	SRCS += Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_flash_ex.c
endif

COMPONENT_GENERATED_SRCDIRS := \
	Drivers \
	Drivers/$(DEVICE_FAMILY)_HAL_Driver \
	Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src \
	Src \
	Drivers/CMSIS \
	Drivers/CMSIS/Device \
	Drivers/CMSIS/Device/ST \
	Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY) \
	Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Source \
	Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Source/Templates \
	Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Source/Templates/gcc

# general variables
USE_FULL_ASSERT ?= -DUSE_FULL_ASSERT
OTHER_OPT     = "-D__weak=__attribute__((weak))" "-D__packed=__attribute__((__packed__))" 

COMPONENT_ADD_CFLAGS  = $(CPU) $(CMSIS_OPT) $(OTHER_OPT)
COMPONENT_ADD_CFLAGS += -I$(STM32CUBEMX_GEN_DIR)
COMPONENT_ADD_CFLAGS += -I$(STM32CUBEMX_GEN_DIR)/Inc
COMPONENT_ADD_CFLAGS += -I$(STM32CUBEMX_GEN_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Inc
COMPONENT_ADD_CFLAGS += -I$(STM32CUBEMX_GEN_DIR)/Drivers/CMSIS/Include
COMPONENT_ADD_CFLAGS += -I$(STM32CUBEMX_GEN_DIR)/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include
COMPONENT_ADD_LDFLAGS = -l$(COMPONENT_NAME) $(CPU) -lm -specs=nano.specs -T $(LDSCRIPT)

$(STM32CUBEMX_GEN_FILE) $(STM32CUBEMX_GEN_DIR)/stm32cubemx-pinout.csv: $(STM32CUBEMX_FILE)
	@mkdir -p $(STM32CUBEMX_GEN_DIR)
	@rm -rf $(STM32CUBEMX_GEN_DIR)/Src/main.c
	@cat $(COMPONENT_PATH)/stm32cubemx.script | envsubst > $(STM32CUBEMX_GEN_DIR)/stm32cubemx.script
	@cp $(STM32CUBEMX_FILE) $(STM32CUBEMX_GEN_DIR)/stm32cubemx.ioc
	cd $(STM32CUBEMX_GEN_DIR); $(STM32CUBEMX) -q $(STM32CUBEMX_GEN_DIR)/stm32cubemx.script
	dos2unix $(STM32CUBEMX_GEN_DIR)/Src/main.c
	patch -N $(STM32CUBEMX_GEN_DIR)/Src/main.c < $(COMPONENT_PATH)/src.patch
	sed -i -- 's/FLASH_BASE[[:space:]]*[(][(]uint32_t[)]0x[0-9a-fA-F]*[)]/FLASH_BASE            ((uint32_t)$(LINK_FLASH_START))/g' $(STM32CUBEMX_GEN_DIR)/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include/*
	sed -i -- 's/DATA_EEPROM_BASE[[:space:]]*[(][(]uint32_t[)]0x[0-9a-fA-F]*[)]/DATA_EEPROM_BASE      ((uint32_t)$(LINK_DATA_EEPROM_START))/g' $(STM32CUBEMX_GEN_DIR)/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include/*
	rm -rf $(STM32CUBEMX_GEN_DIR)/component-src
	mkdir -p $(COMPONENT_BUILD_DIR)
	cd $(STM32CUBEMX_GEN_DIR) && cp --parents $(SRCS) $(COMPONENT_BUILD_DIR)
	touch $(STM32CUBEMX_GEN_FILE)

$(STM32CUBEMX_GEN_DIR)/pinout.h: $(STM32CUBEMX_GEN_DIR)/stm32cubemx-pinout.csv
	@mkdir -p $(STM32CUBEMX_GEN_DIR)
	@echo "#ifndef _PINOUT_H_" > $(STM32CUBEMX_GEN_DIR)/pinout.h
	@echo "#define _PINOUT_H_" >> $(STM32CUBEMX_GEN_DIR)/pinout.h
	@echo "#include <$(DEVICE_FAMILYL).h>" >> $(STM32CUBEMX_GEN_DIR)/pinout.h
	@echo "#include <$(DEVICE_FAMILYL)_hal.h>" >> $(STM32CUBEMX_GEN_DIR)/pinout.h
	@echo "" >> $(STM32CUBEMX_GEN_DIR)/pinout.h
	cat $(STM32CUBEMX_GEN_DIR)/stm32cubemx-pinout.csv | $(COMPONENT_PATH)/pinout-csv-to-h.sh  | column -t -s' ' -o' ' >> $(STM32CUBEMX_GEN_DIR)/pinout.h
	@echo "#endif" >> $(STM32CUBEMX_GEN_DIR)/pinout.h

$(LDSCRIPT):
	@mkdir -p $(STM32CUBEMX_GEN_DIR)
	@cat $(COMPONENT_PATH)/ldscript | envsubst > $(LDSCRIPT)

COMPONENT_ADDITIONAL_REQS = $(STM32CUBEMX_GEN_FILE) $(STM32CUBEMX_GEN_DIR)/pinout.h $(LDSCRIPT)
