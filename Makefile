#export THEOS_DEVICE_IP=192.168.1.15
#export THEOS_DEVICE_IP=143.89.226.137
export THEOS_DEVICE_IP=127.0.0.1
export THEOS_DEVICE_PORT=2222

#export DEBUG = 1
#export DEBUGFLAG = -ggdb
export DEBUG = 0

export TARGET = :clang
export ARCHS = armv7 arm64
export ADDITIONAL_OBJCFLAGS = -fvisibility=default -fvisibility-inlines-hidden -fno-objc-arc -O2

############################################################

# libprowidgets

### Controller ###
LIB = PWController.m
LIB += PWWidgetController.m
LIB += PWWidgetNavigationController.m

### Core ###
#LIB += PWTestBar.m
LIB += PWMiniView.m
LIB += PWShadowView.m
LIB += PWBase.m
LIB += PWWindow.m
LIB += PWBackgroundView.m
LIB += PWView.m
LIB += PWContainerView.m
LIB += PWContentViewController.m
LIB += PWContentItemViewController.m
LIB += PWContentListViewController.m
LIB += PWEventHandler.m
LIB += PWThemableTableView.m
LIB += PWThemableTableViewCell.m
LIB += PWThemableTextField.m
LIB += PWThemableTextView.m
LIB += PWThemableSwitch.m
LIB += PWAlertView.m

### Widget ###
LIB += PWWidget.m
LIB += PWWidgetJS.m
LIB += PWWidgetPlistParser.m
LIB += PWWidgetItem.m
LIB += PWWidgetItemCell.m

### Widget Items ###
LIB += WidgetItems/_PWWidgetItemTextInputTraits.m
LIB += WidgetItems/PWWidgetItemTextArea.m
LIB += WidgetItems/PWWidgetItemTextField.m
LIB += WidgetItems/PWWidgetItemValue.m
LIB += WidgetItems/PWWidgetItemListValue.m
LIB += WidgetItems/PWWidgetItemDateValue.m
LIB += WidgetItems/PWWidgetItemToneValue.m
LIB += WidgetItems/ToneValue/PWWidgetItemTonePickerController.m
LIB += WidgetItems/PWWidgetItemSwitch.m
LIB += WidgetItems/PWWidgetItemText.m
LIB += WidgetItems/PWWidgetItemButton.m
LIB += WidgetItems/PWWidgetItemWebView.m
LIB += WidgetItems/PWWidgetItemRecipient.m
LIB += WidgetItems/Recipient/PWWidgetItemRecipientController.m
LIB += WidgetItems/Recipient/PWWidgetItemRecipientView.m
LIB += WidgetItems/Recipient/PWWidgetItemRecipientTableViewCell.m
#LIB += WidgetItems/PWWidgetItemPhoto.m

### Script ###
LIB += PWScript.m

### Theme Support ###
LIB += PWTheme.m
LIB += PWThemeParsed.m
LIB += PWThemePlistParser.m

### Web Request ###
LIB += PWWebRequest.m
LIB += PWWebRequestFileFormData.m

### JavaScript Bridge ###
LIB += JSBridge/PWJSBridge.m
LIB += JSBridge/PWJSBridgeWrapper.m
LIB += JSBridge/PWJSBridgeBaseWrapper.m
LIB += JSBridge/PWJSBridgeConsoleWrapper.m
LIB += JSBridge/PWJSBridgeWidgetWrapper.m
LIB += JSBridge/PWJSBridgeWidgetItemWrapper.m
LIB += JSBridge/PWJSBridgeScriptWrapper.m
LIB += JSBridge/PWJSBridgeWebRequestWrapper.m
LIB += JSBridge/PWJSBridgeFileWrapper.m
LIB += JSBridge/PWJSBridgePreferenceWrapper.m

############################################################

# Activation
ACTIVATION_METHODS = ActivationMethods/LockScreen
ACTIVATION_METHODS += ActivationMethods/TodayView
ACTIVATION_METHODS += ActivationMethods/NotificationCenter
ACTIVATION_METHODS += ActivationMethods/NotificationCenterCorners
ACTIVATION_METHODS += ActivationMethods/ActivatorListener
ACTIVATION_METHODS += ActivationMethods/ControlCenter

############################################################

# API
API = API/Message.m
API += API/Mail.m
API += API/Alarm.m
API += API/Calendar.m
API += API/Note.m
#API += API/Contact.m

############################################################

# API Substrates
API_SUBSTRATES = API/MessageSubstrate
API_SUBSTRATES += API/MailSubstrate
API_SUBSTRATES += API/AlarmSubstrate

############################################################

# Built-in Widgets
WIDGETS += Widgets/Calendar
WIDGETS += Widgets/Reminders
WIDGETS += Widgets/Notes
WIDGETS += Widgets/Browser
WIDGETS += Widgets/Dictionary
WIDGETS += Widgets/Alarm
WIDGETS += Widgets/Timer
WIDGETS += Widgets/Messages
WIDGETS += Widgets/Mail

#WIDGETS += Widgets/Test
#WIDGETS += Widgets/Custom

############################################################

# Third-party Widgets
#WIDGETSTP = WidgetsTP/Authenticator
#WIDGETSTP += WidgetsTP/Spotify

############################################################

# Test Scripts
#SCRIPTS = Scripts/Test

############################################################

# Built-in Themes
THEMES = Themes/Blur
THEMES += Themes/DarkBlur
THEMES += Themes/PlainBlur
THEMES += Themes/Plain
THEMES += Themes/Grey

############################################################

# Preference
PREFERENCE = preference

############################################################

# Welcome Screen
WELCOME_SCREEN = WelcomeScreen/PWWSWindow.m
WELCOME_SCREEN += WelcomeScreen/PWWSTipView.m

############################################################

LIBRARY_NAME = libprowidgets
libprowidgets_FILES = $(LIB) $(API) $(WELCOME_SCREEN)
libprowidgets_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics CoreImage QuartzCore JavaScriptCore EventKit AddressBook MediaPlayer
libprowidgets_PRIVATE_FRAMEWORKS = MobileKeyBag Calculate MobileTimer ToneKit ToneLibrary AddressBook MessageUI ChatKit MailServices Notes
libprowidgets_INSTALL_PATH = /Library/ProWidgets/
libprowidgets_LIBRARIES = substrate objcipc

SUBPROJECTS = Substrate $(API_SUBSTRATES) $(ACTIVATION_METHODS) $(WIDGETS) $(WIDGETSTP) $(SCRIPTS) $(THEMES) $(PREFERENCE)

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

#LIB_PATH = $(libprowidgets_INSTALL_PATH)$(LIBRARY_NAME).dylib
#STUB_PATH = $(THEOS_STAGING_DIR)$(LIBRARY_NAME).stub.dylib
#$(ECHO_LINKING)echo "" | $(TARGET_LD) $(TARGET_LDFLAGS) -dynamiclib -install_name $(LIB_PATH) -o $(STUB_PATH) -x c -; $(TARGET_STRIP) -c $(STUB_PATH)$(ECHO_END)

after-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.psd' -exec rm -rfv {} + $(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.bak' -exec rm -rfv {} + $(ECHO_END)

after-install::
	install.exec "killall -9 backboardd"