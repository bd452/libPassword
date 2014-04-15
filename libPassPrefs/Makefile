TARGET = iPhone:7.0:2.0
#TARGET = simulator:clang:7.0
ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = libPassPrefs
libPassPrefs_FILES = libPassPrefs.mm
libPassPrefs_INSTALL_PATH = /Library/PreferenceBundles
libPassPrefs_FRAMEWORKS = UIKit AddressBook AddressBookUI AdSupport AudioToolbox AVFoundation CoreMotion EventKit MediaPlayer MessageUI QuartzCore CoreGraphics CoreTelephony MessageUI StoreKit SystemConfiguration RevMobAds
libPassPrefs_PRIVATE_FRAMEWORKS = Preferences
libPassPrefs_LDFLAGS = -lPass

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/libPassPrefs.plist$(ECHO_END)
