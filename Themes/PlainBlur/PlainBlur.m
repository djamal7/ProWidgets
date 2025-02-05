//
//  ProWidgets
//  Default Blur Theme
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWTheme.h"
#import "PWContainerView.h"

@interface _UIBackdropView : UIView

- (id)initWithSettings:(id)settings;

@end

@interface _UIBackdropViewSettings : NSObject

@property(nonatomic, retain) UIColor *colorTint;
@property(nonatomic) float colorTintAlpha;
@property(nonatomic) float saturationDeltaFactor;

+ (instancetype)settingsForStyle:(int)style;
- (instancetype)initWithDefaultValues;

@end

@interface UINavigationBar (backgroundView)

- (UIView *)_backgroundView;

@end

@interface PWWidgetThemePlainBlur : PWTheme {
	
	UIView *_blurView;
}

@end

@implementation PWWidgetThemePlainBlur

/**
 * Override these methods
 **/

- (CGFloat)cornerRadius {
	return 7.0;
}

- (UIColor *)tintColor {
	return [PWTheme systemBlueColor];
}

- (UIColor *)sheetBackgroundColor {
	return [UIColor clearColor];
}

- (UIColor *)navigationBarBackgroundColor {
	return [UIColor clearColor];
}

- (UIColor *)cellSelectedBackgroundColor {
	return [UIColor colorWithWhite:0.85 alpha:.9];
}

- (void)enterSnapshotMode {
	if (!self.disabledBlur) {
		_blurView.backgroundColor = [UIColor whiteColor];
	}
}

- (void)exitSnapshotMode {
	if (!self.disabledBlur) {
		_blurView.backgroundColor = [UIColor clearColor];
	}
}

- (void)setupTheme {
	
	UINavigationBar *navigationBar = [self navigationBar];
	PWContainerView *containerView = [self containerView];
	
	navigationBar.translucent = NO;
	
	UIView *backgroundView = [navigationBar _backgroundView];
	backgroundView.backgroundColor = [UIColor clearColor]; // remove white background
	
	if (self.disabledBlur) {
		
		CGFloat alpha = .98;
		
		_blurView = [UIView new];
		_blurView.backgroundColor = [UIColor whiteColor];
		_blurView.alpha = alpha;
		[containerView insertSubview:_blurView atIndex:0];
		
	} else {
	
		// backdrop view settings
		_UIBackdropViewSettings *settings = [[[objc_getClass("_UIBackdropViewSettingsUltraLight") alloc] initWithDefaultValues] autorelease];
		
		// add blur view as the background
		_blurView = [[objc_getClass("_UIBackdropView") alloc] initWithSettings:settings];
		[containerView insertSubview:_blurView atIndex:0];
	}
}

- (void)removeTheme {
	
	[_blurView removeFromSuperview];
	[_blurView release], _blurView = nil;
}

- (void)adjustLayout {
	
	CGRect superRect = [self containerView].bounds;
	CGSize superSize = superRect.size;
	
	_blurView.frame = CGRectMake(0, 0, superSize.width, superSize.height);
}

- (void)dealloc {
	
	[_blurView removeFromSuperview];
	[_blurView release], _blurView = nil;
	
	[super dealloc];
}

@end