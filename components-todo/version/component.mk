# Variables for version.h
GIT_HASH := $(shell git rev-parse HEAD)
GIT_TAG  := $(shell git describe --abbrev=0 --tags)

$(BUILD_DIR)/version.h: $(BUILD_DIR)/$(GIT_HASH)
	@echo "#ifndef _VERSION_H_" > $(BUILD_DIR)/version.h
	@echo "#define _VERSION_H_" >> $(BUILD_DIR)/version.h
	@echo "" >> $(BUILD_DIR)/version.h
	@echo "#define GIT_HASH \"$(GIT_HASH)\"" >> $(BUILD_DIR)/version.h
	@echo "#define GIT_TAG \"$(GIT_TAG)\"" >> $(BUILD_DIR)/version.h
	@echo "" >> $(BUILD_DIR)/version.h
	@echo "#endif" >> $(BUILD_DIR)/version.h

$(BUILD_DIR)/$(GIT_HASH):
	@mkdir -p $(BUILD_DIR)
	touch $(BUILD_DIR)/$(GIT_HASH)
