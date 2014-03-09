

TARGET = iPhone:7.0:2.0
#TARGET = simulator:clang:7.0
ARCHS = armv7 arm64
#TARGET = iPhone:7.0:2.0

THEOS_PACKAGE_DIR_NAME = debs

include theos/makefiles/common.mk
include theos/makefiles/library.mk
include theos/makefiles/bundle.mk


TWEAK_NAME = libPass


libPass_FILES = Tweak.xm
libPass_FRAMEWORKS = AVFoundation UIKit Security

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += libPassPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk