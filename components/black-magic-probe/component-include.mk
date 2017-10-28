.PHONY: bmp-gdb

bmp-gdb:
	$(GDB) \
	  -ex "target extended-remote $(CONFIG_BMP_DEVICE)" \
	  -ex "monitor swdp_scan" \
	  -ex "attach 1" \
	  $(APP_ELF)
