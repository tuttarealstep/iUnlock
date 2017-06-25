include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = iUnlockPreferences
iUnlockPreferences_FILES = iupRootListController.m
iUnlockPreferences_INSTALL_PATH = /Library/PreferenceBundles
iUnlockPreferences_FRAMEWORKS = UIKit
iUnlockPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/iUnlockPreferences.plist$(ECHO_END)
