.PHONY: size
size: $(APP_ELF)
	$(SIZE) $(APP_ELF)

# TODO

$(BUILD_DIR)/printsize.sh:
	@mkdir -p $(BUILD_DIR)
	@echo "$$PRINTSIZE_CONTENTS" > $(BUILD_DIR)/printsize.sh
	@chmod a+x $(BUILD_DIR)/printsize.sh

define PRINTSIZE_CONTENTS
#!/bin/bash -e

. $(BUILD_DIR)/vars.sh

TEXT_SIZE=`cat $(BUILD_DIR)/size.report | tail -1 | cut -f 1 | tr -d " "`
DATA_SIZE=`cat $(BUILD_DIR)/size.report | tail -1 | cut -f 2 | tr -d " "`
BSS_SIZE=`cat $(BUILD_DIR)/size.report | tail -1 | cut -f 3 | tr -d " "`

RAM_ALL_KB=$$(echo "scale=1; $${RAM}/1024" | bc -l)
FLASH_ALL_KB=$$(echo "scale=1; $${FLASH}/1024" | bc -l)

TEXT_SIZE_KB=$$(echo "scale=1; $${TEXT_SIZE}/1024" | bc -l)
DATA_SIZE_KB=$$(echo "scale=1; $${DATA_SIZE}/1024" | bc -l)
BSS_SIZE_KB=$$(echo "scale=1; $${BSS_SIZE}/1024" | bc -l)

FLASH_TOTAL=$$(echo "$${TEXT_SIZE}+$${DATA_SIZE}" | bc)
RAM_TOTAL=$$(echo "$${DATA_SIZE}+$${BSS_SIZE}" | bc)
FLASH_REMAINING=$$(echo "$${FLASH}-$${FLASH_TOTAL}" | bc)
RAM_REMAINING=$$(echo "$${RAM}-$${RAM_TOTAL}" | bc)

FLASH_TOTAL_KB=$$(echo "scale=1; $${FLASH_TOTAL}/1024" | bc -l)
RAM_TOTAL_KB=$$(echo "scale=1; $${RAM_TOTAL}/1024" | bc -l)
FLASH_REMAINING_KB=$$(echo "scale=1; $${FLASH_REMAINING}/1024" | bc -l)
RAM_REMAINING_KB=$$(echo "scale=1; $${RAM_REMAINING}/1024" | bc -l)

echo ""
echo "flash = $${FLASH_ALL_KB}kB"
echo "ram   = $${RAM_ALL_KB}kB"
echo ""
echo "flash = text ($${TEXT_SIZE_KB}kB) + data ($${DATA_SIZE_KB}kB) = $${FLASH_TOTAL_KB}kB (remaining: $${FLASH_REMAINING_KB}kB)"
echo "  ram = data ($${DATA_SIZE_KB}kB) +  bss ($${BSS_SIZE_KB}kB) = $${RAM_TOTAL_KB}kB (remaining: $${RAM_REMAINING_KB}kB)"
echo ""
endef
