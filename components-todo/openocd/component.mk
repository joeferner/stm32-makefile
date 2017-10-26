openocd:
	@mkdir -p $(BUILD_DIR)
	@echo "gdb_port 4242" > $(BUILD_DIR)/openocd.cfg
	openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -f $(BUILD_DIR)/openocd.cfg
