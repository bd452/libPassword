TARGET = iphone:clang:7.1:2.0
ARCHS = armv7 armv7s arm64
CFLAGS = -fobjc-arc

THEOS_PACKAGE_DIR_NAME = debs

include theos/makefiles/common.mk

TWEAK_NAME = libPass
libPass_FILES = Tweak.xm
libPass_FRAMEWORKS = UIKit
libPass_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk