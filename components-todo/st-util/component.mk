st-util:
	@echo "Use lsusb then STLINK_DEVICE=<bus>:<device id> for multiple devices"
	st-util -m -v

write: $(BIN)
	@echo "Use lsusb then STLINK_DEVICE=<bus>:<device id> for multiple devices"
	st-flash --reset write $(BIN) $(LINK_FLASH_START)

erase:
	@echo "Use lsusb then STLINK_DEVICE=<bus>:<device id> for multiple devices"
	st-flash erase
