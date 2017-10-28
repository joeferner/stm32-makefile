# Variables for version.h
GIT_HASH := $(shell git rev-parse HEAD)
GIT_TAG  := $(shell git describe --abbrev=0 --tags)

$(COMPONENT_BUILD_DIR)/version.h: $(COMPONENT_BUILD_DIR)/$(GIT_HASH)
	@echo "#ifndef _VERSION_H_" > $(COMPONENT_BUILD_DIR)/version.h
	@echo "#define _VERSION_H_" >> $(COMPONENT_BUILD_DIR)/version.h
	@echo "" >> $(COMPONENT_BUILD_DIR)/version.h
	@echo "#define GIT_HASH \"$(GIT_HASH)\"" >> $(COMPONENT_BUILD_DIR)/version.h
	@echo "#define GIT_TAG \"$(GIT_TAG)\"" >> $(COMPONENT_BUILD_DIR)/version.h
	@echo "" >> $(COMPONENT_BUILD_DIR)/version.h
	@echo "#endif" >> $(COMPONENT_BUILD_DIR)/version.h

$(COMPONENT_BUILD_DIR)/$(GIT_HASH):
	@mkdir -p $(COMPONENT_BUILD_DIR)
	touch $(COMPONENT_BUILD_DIR)/$(GIT_HASH)

COMPONENT_ADDITIONAL_REQS = $(COMPONENT_BUILD_DIR)/version.h
COMPONENT_ADD_CFLAGS = -I$(COMPONENT_BUILD_DIR)
