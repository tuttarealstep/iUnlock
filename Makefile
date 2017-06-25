THEOS_DEVICE_IP = 192.168.1.4
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iUnlock
iUnlock_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += iunlockpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
