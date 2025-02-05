//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWThemableTableView.h"
#import "PWController.h"
#import "PWTheme.h"

static char PWThemableTableViewHeaderFooterViewConfiguredKey;

@interface UITableView (Private)

- (UITableViewHeaderFooterView *)_sectionHeaderView:(BOOL)arg1 withFrame:(CGRect)frame forSection:(int)section floating:(BOOL)floating reuseViewIfPossible:(BOOL)reuse;

@end

@implementation PWThemableTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style theme:(PWTheme *)theme {
	if ((self = [super initWithFrame:frame style:style])) {
		_theme = [theme retain];
		[self _configureAppearance];
	}
	return self;
}

- (void)_configureAppearance {
	
	// set background color
	self.backgroundColor = [UIColor clearColor];
	
	// set table view
	self.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.alwaysBounceVertical = YES;
	
	// you may set this again to hide separator in empty cells
	[self setHideSeparatorInEmptyCells:NO];
}

- (UITableViewHeaderFooterView *)_sectionHeaderView:(BOOL)arg1 withFrame:(CGRect)frame forSection:(int)section floating:(BOOL)floating reuseViewIfPossible:(BOOL)reuse {
	
	UITableViewHeaderFooterView *view = [super _sectionHeaderView:arg1 withFrame:frame forSection:section floating:floating reuseViewIfPossible:reuse];
	
	if (view == nil) return nil;
	
	NSNumber *configured = objc_getAssociatedObject(view, &PWThemableTableViewHeaderFooterViewConfiguredKey);
	if (configured == nil || ![configured boolValue]) {
		
		// configure its appearance
		PWTheme *theme = _theme;
		view.contentView.backgroundColor = [theme cellHeaderFooterViewBackgroundColor];
		view.textLabel.textColor = [theme cellHeaderFooterViewTitleTextColor];
		view.detailTextLabel.textColor = [theme cellHeaderFooterViewTitleTextColor];
		view.opaque = NO;
		
		objc_setAssociatedObject(view, &PWThemableTableViewHeaderFooterViewConfiguredKey, @(YES), OBJC_ASSOCIATION_COPY);
	}
	
	return view;
}

- (void)setHideSeparatorInEmptyCells:(BOOL)hidden {
	if (hidden) {
		// remove separator lines for empty cells
		UIView *emptyView = [[UIView alloc] initWithFrame:CGRectZero];
		emptyView.backgroundColor = [UIColor clearColor];
		[self setTableFooterView:emptyView];
		[emptyView release];
	} else {
		[self setTableFooterView:nil];
	}
}

- (void)dealloc {
	RELEASE(_theme)
	[super dealloc];
}

@end