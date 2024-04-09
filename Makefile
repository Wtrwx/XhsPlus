TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = discover

ROOTLESS = 1
ifeq ($(ROOTLESS),1)
 THEOS_PACKAGE_SCHEME=rootless
endif
ifeq ($(THEOS_PACKAGE_SCHEME), rootless)
 TARGET = iphone:clang:latest:15.0
else
 TARGET = iphone:clang:latest:12.0
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XhsPlus

XhsPlus_FILES = Tweak.x CustomSettingsViewController.m
XhsPlus_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
