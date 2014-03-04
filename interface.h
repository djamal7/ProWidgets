#import <AddressBook/AddressBook.h>
#import "interface/ToneKitInterface.h"
#import "interface/ToneLibraryInterface.h"

@interface SLSheetMasklayer : CALayer

@property(nonatomic) float clipCornerRadius;

- (void)updateMaskWithBounds:(CGRect)bounds maskRect:(CGRect)rect;

@end

@interface MFComposeRecipient : NSObject

@property(nonatomic, readonly) NSString *address;
@property(nonatomic, readonly) NSString *rawAddress;
@property(nonatomic, readonly) NSString *compositeName;
@property(nonatomic, readonly) NSString *shortName;

+ (id)recipientWithProperty:(ABPropertyID)property address:(NSString *)address;

@end

@interface MFComposeRecipientView : UIView

@property(assign) id delegate;
@property(getter=isSeparatorHidden) BOOL separatorHidden;
@property(retain) NSArray *recipients;

+ (CGFloat)preferredHeight;

- (void)setAddresses:(id)arg1;
- (void)setLabel:(id)arg1;

- (void)clearText;

- (void)addRecipient:(id)arg1 index:(unsigned int)arg2 animate:(BOOL)arg3;
- (void)addRecipient:(id)arg1;
- (void)setAddressAtomPresentationOptions:(int)options forRecipient:(id)recipient;

@end

@interface MFRecipientTableViewCell : UITableViewCell

+ (CGFloat)heightWithRecipient:(id)recipient width:(CGFloat)width;
- (void)setRecipient:(id)recipient;

@end

@interface CKRecipientGenerator : NSObject

+ (instancetype)sharedRecipientGenerator;
- (id)recipientWithAddress:(NSString *)address;
- (id)recipientWithRecord:(void *)arg1 property:(int)arg2 identifier:(int)arg3;
- (NSArray *)resultsForText:(NSString *)text;

@end

@interface SpringBoard : UIApplication

- (UIInterfaceOrientation)activeInterfaceOrientation;
- (void)addActiveOrientationObserver:(id)observer;

@end

@interface SBUIController : NSObject

+ (instancetype)sharedInstance;
- (void)_hideKeyboard;

- (void)_releaseTransitionOrientationLock;
- (void)_releaseSystemGestureOrientationLock;
- (void)releaseSwitcherOrientationLock;
- (void)_lockOrientationForSwitcher;
- (void)_lockOrientationForSystemGesture;
- (void)_lockOrientationForTransition;

@end

@interface SBBacklightController : NSObject

+ (id)sharedInstance;
- (void)resetLockScreenIdleTimerWithDuration:(double)duration;
- (void)resetLockScreenIdleTimer;

@end

@interface UIPeripheralHost

+ (id)sharedInstance;

- (void)forceOrderOutAutomaticAnimated:(BOOL)arg1;
- (void)forceOrderInAutomaticAnimated:(BOOL)arg1;

@end

@protocol SBUIActiveOrientationObserver <NSObject>

- (void)activeInterfaceOrientationDidChangeToOrientation:(UIInterfaceOrientation)activeInterfaceOrientation willAnimateWithDuration:(double)duration fromOrientation:(UIInterfaceOrientation)orientation;

- (void)activeInterfaceOrientationWillChangeToOrientation:(UIInterfaceOrientation)activeInterfaceOrientation;

@end

@interface CAFilter : NSObject

+ (instancetype)filterWithName:(NSString *)name;
- (void)setValue:(id)value forKey:(id)key;

@end

@interface UIWindow ()

- (UIResponder *)firstResponder;

@end

@interface UIView ()

+ (void)setAnimationPosition:(CGPoint)position;
- (NSString *)recursiveDescription;

@end

@interface UITableViewCell (Private)

- (void)setSeparatorColor:(id)arg1;
- (void)_updateSeparatorContent:(BOOL)arg;

@end

@interface UIImage ()

+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

@end

@interface UINavigationController ()

@property(getter=isInteractiveTransition) BOOL interactiveTransition;

@property(getter=_builtinTransitionStyle,setter=_setBuiltinTransitionStyle:) int builtinTransitionStyle;
@property(getter=_builtinTransitionGap,setter=_setBuiltinTransitionGap:) float builtinTransitionGap;

@end