TARGET = iphone:clang:7.1:2.0
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = TimeCode
TimeCode_FILES = Tweak.xm
TimeCode_LIBRARIES = Pass

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
