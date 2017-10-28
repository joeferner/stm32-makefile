.PHONY: size

COMPONENT_BUILD_DIR=$(BUILD_DIR_BASE)/size

size: $(APP_ELF)
	echo "Size of $(APP_ELF)"
	$(SIZE) $(APP_ELF) > $(COMPONENT_BUILD_DIR)/size.report
	$(STM32_MAKEFILE_PATH)/components/size/format-size.sh $(COMPONENT_BUILD_DIR)/size.report $(RAM) $(FLASH)
