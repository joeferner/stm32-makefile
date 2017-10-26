gdb:
	$(GDB) -tui -ex "target extended-remote localhost:4242" $(BUILD_DIR)/main.out
