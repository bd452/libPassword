TARGET = iphone:clang:7.1:2.0
ARCHS = armv7 armv7s arm64
CFLAGS = -fobjc-arc

THEOS_PACKAGE_DIR_NAME = debs

include theos/makefiles/common.mk

TWEAK_NAME = libPass
libPass_FILES = Tweak.xm LibPass.m libPass_compat.m
libPass_FRAMEWORKS = UIKit
libPass_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk
#SUBPROJECTS += timecode
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
