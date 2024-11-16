.DEFAULT_GOAL := build

TARGET := XcodeTemplate
APP := $(TARGET).app
ARCHIVES := Archives
PRODUCT := Products/Applications/$(APP)/

COMMON_FLAGS := CODE_SIGNING_REQUIRED=NO \
                AD_HOC_CODE_SIGNING_ALLOWED=YES \
                CODE_SIGNING_ALLOWED=NO \
                DEVELOPMENT_TEAM=XYZ0123456 \
                DWARF_DSYM_FOLDER_PATH="."

MACOS_ARCHIVE := $(ARCHIVES)/macOS-archive.xcarchive
IOS_ARCHIVE   := $(ARCHIVES)/iOS-archive.xcarchive
TVOS_ARCHIVE  := $(ARCHIVES)/tvOS-archive.xcarchive

TMP_PAYLOAD := Payload/$(APP)/

MACOS_ZIP := $(ARCHIVES)/$(TARGET).zip
IOS_IPA := $(ARCHIVES)/$(TARGET).ios.ipa
TVOS_IPA := $(ARCHIVES)/$(TARGET).tvos.ipa

$(ARCHIVES):
	@mkdir -p "$(ARCHIVES)"

define build_target
$(1): $(ARCHIVES)
	@xcodebuild -project $(TARGET).xcodeproj \
				-scheme $(TARGET) \
				-sdk $(2) \
				 archive -archivePath ./$(ARCHIVES)/$(3) \
				 $(COMMON_FLAGS)
	@mv ./$(APP).dSYM ./$(1)/dSYMs/
endef

$(eval $(call build_target,$(MACOS_ARCHIVE),macosx,macOS-archive))
$(eval $(call build_target,$(IOS_ARCHIVE),iphoneos,iOS-archive))
$(eval $(call build_target,$(TVOS_ARCHIVE),iphoneos,tvOS-archive))

build: $(MACOS_ARCHIVE) $(IOS_ARCHIVE) $(TVOS_ARCHIVE)

define package_zip
$(1): $(2)
	@mkdir -p "$(3)"
	@cp -R "$(2)/$(PRODUCT)" "$(3)"
	zip -r "$(1)" "$(3)"
	@rm -r "$(3)" || true
	@rm -r Payload || true
endef

$(eval $(call package_zip,$(MACOS_ZIP),$(MACOS_ARCHIVE),$(APP)))
$(eval $(call package_zip,$(IOS_IPA),$(IOS_ARCHIVE),$(TMP_PAYLOAD)))
$(eval $(call package_zip,$(TVOS_IPA),$(TVOS_ARCHIVE),$(TMP_PAYLOAD)))

ipas: $(MACOS_ZIP) $(IOS_IPA) $(TVOS_IPA)

clean:
	rm -rf "$(ARCHIVES)"

.PHONY: ipas clean

