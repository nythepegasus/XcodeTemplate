.DEFAULT_GOAL := build

TARGET := XcodeTemplate

APP := $(TARGET).app

ARCHIVES := Archives

MACOS_ARCHIVE := $(ARCHIVES)/macOS-archive.xcarchive
IOS_ARCHIVE   := $(ARCHIVES)/iOS-archive.xcarchive
TVOS_ARCHIVE  := $(ARCHIVES)/tvOS-archive.xcarchive

$(ARCHIVES):
	@mkdir $(ARCHIVES)

$(MACOS_ARCHIVE): $(ARCHIVES)
	@xcodebuild -project $(TARGET).xcodeproj \
				-scheme $(TARGET) \
				-sdk macosx \
				 archive -archivePath ./$(ARCHIVES)/macOS-archive \
				 CODE_SIGNING_REQUIRED=NO \
				 AD_HOC_CODE_SIGNING_ALLOWED=YES \
				 CODE_SIGNING_ALLOWED=NO \
				 DEVELOPMENT_TEAM=XYZ0123456 \
				 DWARF_DSYM_FOLDER_PATH="."
	@mv ./$(APP).dSYM ./$@/dSYMs/

$(IOS_ARCHIVE): $(ARCHIVES)
	@xcodebuild -project $(TARGET).xcodeproj \
				-scheme $(TARGET) \
				-sdk iphoneos \
				 archive -archivePath ./$(ARCHIVES)/iOS-archive \
				 CODE_SIGNING_REQUIRED=NO \
				 AD_HOC_CODE_SIGNING_ALLOWED=YES \
				 CODE_SIGNING_ALLOWED=NO \
				 DEVELOPMENT_TEAM=XYZ0123456 \
				 DWARF_DSYM_FOLDER_PATH="."
	@mv ./$(APP).dSYM ./$@/dSYMs/

$(TVOS_ARCHIVE): $(ARCHIVES)
	@xcodebuild -project $(TARGET).xcodeproj \
				-scheme $(TARGET) \
				-sdk iphoneos \
				 archive -archivePath ./$(ARCHIVES)/tvOS-archive \
				 CODE_SIGNING_REQUIRED=NO \
				 AD_HOC_CODE_SIGNING_ALLOWED=YES \
				 CODE_SIGNING_ALLOWED=NO \
				 DEVELOPMENT_TEAM=XYZ0123456 \
				 DWARF_DSYM_FOLDER_PATH="."
	@mv ./$(APP).dSYM ./$@/dSYMs/

build: $(MACOS_ARCHIVE) $(IOS_ARCHIVE) $(TVOS_ARCHIVE)

PRODUCT := Products/Applications/$(APP)/
TMP_PAYDIR := Payload
TMP_PAYLOAD := $(TMP_PAYDIR)/$(APP)/

MACOS_DMG := $(ARCHIVES)/$(TARGET).dmg
IOS_IPA := $(ARCHIVES)/$(TARGET).ios.ipa
TVOS_IPA := $(ARCHIVES)/$(TARGET).tvos.ipa

$(MACOS_DMG): $(MACOS_ARCHIVE)
	@mkdir -p $(TMP_PAYLOAD) || true
	cp -R $(MACOS_ARCHIVE)/$(PRODUCT) $(TMP_PAYLOAD)
	hdiutil create -volname $(TARGET) \
				   -srcfolder ./$(TMP_PAYDIR) \
				   -ov -format UDZO $@
	@rm -r $(TMP_PAYDIR)

$(IOS_IPA): $(IOS_ARCHIVE)
	@mkdir -p $(TMP_PAYLOAD)
	@cp -R $(IOS_ARCHIVE)/$(PRODUCT) $(TMP_PAYLOAD)
	zip -r $@ $(TMP_PAYLOAD)
	@rm -r $(TMP_PAYDIR)

$(TVOS_IPA): $(TVOS_ARCHIVE)
	@mkdir -p $(TMP_PAYLOAD)
	@cp -R $(TVOS_ARCHIVE)/$(PRODUCT) $(TMP_PAYLOAD)
	zip -r $@ $(TMP_PAYLOAD)
	@rm -r $(TMP_PAYDIR)

ipas: $(MACOS_DMG) $(IOS_IPA) $(TVOS_IPA)

default: build

clean:
	rm -r $(ARCHIVES)

.PHONY: ipas clean
