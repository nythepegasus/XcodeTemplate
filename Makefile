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

TMP_PAYDIR := Payload
TMP_PAYLOAD := $(TMP_PAYDIR)/$(APP)/

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

define package_ipa
$(1): $(2)
	@mkdir -p "$(TMP_PAYLOAD)"
	@cp -R "$(2)/$(PRODUCT)" "$(TMP_PAYLOAD)"
	zip -r "$@" "$(TMP_PAYLOAD)"
	@rm -r "$(TMP_PAYDIR)"
endef

$(eval $(call package_ipa,$(MACOS_ZIP),$(MACOS_ARCHIVE)))
$(eval $(call package_ipa,$(IOS_IPA),$(IOS_ARCHIVE)))
$(eval $(call package_ipa,$(TVOS_IPA),$(TVOS_ARCHIVE)))

ipas: $(MACOS_DMG) $(IOS_IPA) $(TVOS_IPA)

clean:
	rm -rf "$(ARCHIVES)"

.PHONY: ipas clean

