#import "PWPrefController.h"
#import "PWPrefWidgets.h"
#import "PWPrefWidgetsView.h"
#import "PWPrefWidgetPreference.h"
#import "PWPrefInfoViewController.h"
#import "PWController.h"

extern NSBundle *bundle;

@implementation PWPrefWidgets

- (Class)viewClass {
	return [PWPrefWidgetsView class];
}

- (NSString *)navigationTitle {
	return PTEXT(@"Widgets");
}

- (BOOL)requiresEditBtn {
	return YES;
}

- (PWPrefURLInstallationType)URLInstallationType {
	return PWPrefURLInstallationTypeWidget;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	// reload installed widgets
	[self reloadInstalledWidgets];
}

- (void)reloadInstalledWidgets {
	// re-fetch installed widgets from PWController
	[_installedWidgets release];
	_installedWidgets = [[[PWController sharedInstance] installedWidgets] mutableCopy];
	// update enabled state of edit button
	self.navigationItem.rightBarButtonItem.enabled = [_installedWidgets count] > 0;
	// reload table view
	[(PWPrefWidgetsView *)self.view reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? MAX(1, [_installedWidgets count]) : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? PTEXT(@"InstalledWidgets") : nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0 && [_installedWidgets count] > 0) {
		return PTEXT(@"InstalledWidgetsFooterText");
	} else if (section == 0 && [_installedWidgets count] == 0) {
		return PTEXT(@"NoInstalledWidgetsFooterText");
	} else if (section == 1) {
		return PTEXT(@"InstallWidgetViaURLFooterText");
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	BOOL isMessageCell = section == 0 && [_installedWidgets count] == 0;
	
	NSString *identifier = nil;
	
	if (isMessageCell) {
		identifier = @"PWPrefWidgetsViewMessageCell";
	} else if (section == 0) {
		identifier = @"PWPrefWidgetsViewCell";
	} else if (section == 1) {
		identifier = @"PWPrefWidgetsViewInstallCell";
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		
		UITableViewCellStyle style = UITableViewCellStyleDefault;
		if (!isMessageCell && section == 0) style = UITableViewCellStyleSubtitle;
		
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
		
		if (isMessageCell) {
			
			cell.textLabel.text = PTEXT(@"NoInstalledWidgets");
			cell.textLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
			cell.textLabel.font = [UIFont italicSystemFontOfSize:[UIFont labelFontSize]];
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
		} else if (section == 0) {
			
			cell.detailTextLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
			cell.imageView.userInteractionEnabled = YES;
			
			UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_cellImageViewTapHandler:)] autorelease];
			tap.numberOfTapsRequired = 1;
			[cell.imageView addGestureRecognizer:tap];
			
		} else if (section == 1) {
			
			cell.textLabel.text = PTEXT(@"InstallWidgetViaURL");
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	
	if (section == 0 && !isMessageCell) {
		
		// retrieve the widget info
		NSDictionary *info = row < [_installedWidgets count] ? _installedWidgets[row] : nil;
		
		// extract widget info
		NSBundle *widgetBundle = info[@"bundle"];
		NSString *displayName = info[@"displayName"];
		NSString *shortDescription = info[@"shortDescription"];
		NSString *iconFile = info[@"iconFile"];
		UIImage *iconImage = [iconFile length] > 0 ? [UIImage imageNamed:iconFile inBundle:widgetBundle] : nil;
		BOOL hasPreference = [info[@"hasPreference"] boolValue];
		
		// set default display name
		if ([displayName length] == 0) displayName = PTEXT(@"Unknown");
		
		// set default description
		if ([shortDescription length] == 0) shortDescription = nil;
		
		// set default icon image
		if (iconImage == nil) iconImage = IMAGE(@"icon_widgets");
		
		// configure cell
		cell.textLabel.text = displayName;
		cell.detailTextLabel.text = shortDescription;
		cell.imageView.image = iconImage;
		
		if (hasPreference) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (section == 0) {
		if (row < [_installedWidgets count]) {
			
			NSDictionary *info  = _installedWidgets[row];
			NSBundle *bundle = info[@"bundle"];
			BOOL hasPreference = [info[@"hasPreference"] boolValue];
			
			if (hasPreference) {
				
				NSString *prefFile = info[@"preferenceFile"];
				NSString *prefBundle = info[@"preferenceBundle"];
				
				if ([prefFile length] > 0) {
					
					PWPrefWidgetPreference *controller = [[[PWPrefWidgetPreference alloc] initWithPlist:prefFile inBundle:bundle] autorelease];
					controller.rootController = self.rootController;
					controller.parentController = self;
					[self pushController:controller];
					
				} else if ([prefBundle length] > 0) {
					
					// load the preference bundle
					if ([prefBundle hasSuffix:@".bundle"]) {
						prefBundle = [prefBundle stringByDeletingPathExtension];
					}
					
					NSString *bundlePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/%@.bundle/", prefBundle];
					NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
					
					if ([bundle load]) {
						
						Class principalClass = [bundle principalClass];
						id viewController = [[principalClass new] autorelease];
						
						if (viewController == nil) {
							LOG(@"The principal class cannot be found or initialized.");
							return;
						}
						
						if (![viewController isKindOfClass:[UIViewController class]]) {
							LOG(@"The principal class is not a sub class of UIViewController.");
							return;
						}
						
						if ([viewController respondsToSelector:@selector(setRootController:)]) {
							[viewController performSelector:@selector(setRootController:) withObject:self.rootController];
						}
						
						if ([viewController respondsToSelector:@selector(setParentController:)]) {
							[viewController performSelector:@selector(setParentController:) withObject:self];
						}
						
						[self pushController:viewController];
					}
				}
			}
		}
	} else if (section == 1) {
		if (row == 0) {
			[self promptURLInstallation];
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	if (section != 0 || row >= [_installedWidgets count]) return NO;
	
	NSDictionary *info = _installedWidgets[row];
	BOOL installedViaURL = [info[@"installedViaURL"] boolValue];
	
	return installedViaURL;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return PTEXT(@"Uninstall");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	if (section != 0 || row >= [_installedWidgets count]) return;
	[self _uninstallWidgetAtIndex:row];
}

- (void)_cellImageViewTapHandler:(UITapGestureRecognizer *)sender {
	
	UIView *superview = sender.view;
	while ((superview = superview.superview) && superview != nil && ![superview isKindOfClass:[UITableViewCell class]]);
	
	UITableViewCell *cell = (UITableViewCell *)superview;
	if ([cell isKindOfClass:[UITableViewCell class]]) {
		UITableView *tableView = (UITableView *)self.view;
		NSIndexPath *indexPath = [tableView indexPathForCell:cell];
		NSUInteger row = [indexPath row];
		if (row != NSNotFound && [_installedWidgets count] > row) {
			
			PWPrefInfoViewController *infoViewController = [[PWPrefInfoViewController new] autorelease];
			
			NSDictionary *info = _installedWidgets[row];
			NSBundle *widgetBundle = info[@"bundle"];
			
			// prepare icon
			NSString *iconFile = info[@"iconFile"];
			UIImage *iconImage = [iconFile length] > 0 ? [UIImage imageNamed:iconFile inBundle:widgetBundle] : nil;
			if (iconImage == nil) iconImage = IMAGE(@"icon_widgets");
			
			// configure info view
			PWPrefInfoView *infoView = infoViewController.infoView;
			[infoView setIcon:iconImage];
			[infoView setName:info[@"displayName"]];
			[infoView setAuthor:info[@"author"]];
			[infoView setDescription:info[@"description"]];
			[infoView setLivePreviewHidden:NO];
			[infoView setLivePreviewEnabledState:[info[@"requiresLivePreview"] boolValue]];
			[infoView setLivePreviewSwitchTarget:self action:@selector(_infoViewLivePreviewSwitchHandler:info:)];
			[infoView setLivePreviewSwitchInfo:@{ @"name":info[@"name"] }];
			[infoView setConfirmButtonTitle:@"Uninstall"];
			
			if ([info[@"installedViaURL"] boolValue]) {
				[infoView setConfirmButtonType:PWPrefInfoViewConfirmButtonTypeWarning];
				[infoView setConfirmButtonTarget:self action:@selector(_infoViewConfirmButtonHandler:)];
				[infoView setConfirmButtonInfo:@{ @"index":@(row) }];
			} else {
				[infoView setConfirmButtonType:PWPrefInfoViewConfirmButtonTypeDisabled];
			}
			
			[self presentViewController:infoViewController animated:YES completion:nil];
		}
	}
}

- (void)_infoViewLivePreviewSwitchHandler:(UISwitch *)sender info:(NSDictionary *)info {
	
	BOOL on = sender.on;
	NSString *name = info[@"name"];
	if (name == nil) return;
	
	PWPrefController *parent = (PWPrefController *)self.parentController;
	NSMutableDictionary *settings = [[parent valueForKey:@"livePreviewSettings"] mutableCopy];
	if (on) {
		settings[name] = @YES;
	} else {
		[settings removeObjectForKey:name];
	}
	
	[parent updateValue:settings forKey:@"livePreviewSettings"];
}

- (void)_infoViewConfirmButtonHandler:(NSDictionary *)info {
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
	NSNumber *_index = info[@"index"];
	if (_index != nil) {
		NSUInteger index = [_index unsignedIntegerValue];
		[self _uninstallWidgetAtIndex:index];
	}
}

- (void)_uninstallWidgetAtIndex:(NSUInteger)index {
	
	NSDictionary *info = _installedWidgets[index];
	BOOL installedViaURL = [info[@"installedViaURL"] boolValue];
	
	if (installedViaURL) {
		[self uninstallPackage:info completionHandler:^{
			[_installedWidgets removeObjectAtIndex:index];
			[(UITableView *)self.view reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		}];
	}
}

- (void)dealloc {
	[_installedWidgets release], _installedWidgets = nil;
	[super dealloc];
}

@end