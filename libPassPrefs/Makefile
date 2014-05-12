TARGET = iphone:clang:7.1:2.0
ARCHS = armv7 armv7s arm64
include theos/makefiles/common.mk

CFLAGS = -I..

BUNDLE_NAME = libPassPrefs
libPassPrefs_FILES = libPassPrefs.mm
libPassPrefs_INSTALL_PATH = /Library/PreferenceBundles
libPassPrefs_FRAMEWORKS = UIKit
libPassPrefs_PRIVATE_FRAMEWORKS = Preferences
libPassPrefs_LDFLAGS = -lPass

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/libPassPrefs.plist$(ECHO_END)
