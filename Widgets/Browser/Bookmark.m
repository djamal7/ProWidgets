//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Bookmark.h"
#import "Browser.h"
#import "Add.h"
#import "PWContentViewController.h"
#import "PWThemableTableView.h"

@implementation PWWidgetBrowserBookmarkViewController

- (void)load {
	
	self.actionButtonText = @"Add";
	
	self.shouldAutoConfigureStandardButtons = NO;
	self.wantsFullscreen = YES;
	self.requiresKeyboard = YES;
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	[self setActionEventHandler:self selector:@selector(actionEventHandler)];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (NSString *)title {
	return _isRoot ? @"Bookmarks" : _folderTitle;
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain theme:self.theme] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	if (_isRoot) {
		[self configureCloseButton];
	}
	[self configureActionButton];
	[self loadBookmarkItems];
}

- (void)actionEventHandler {
	
	PWWidgetBrowserDefault defaultBrowser = [(PWWidgetBrowser *)self.widget defaultBrowser];
	
	if (defaultBrowser == PWWidgetBrowserDefaultChrome) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Adding bookmark to Chrome is not supported yet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	} else if (defaultBrowser == PWWidgetBrowserDefaultSafari) {
		
		PWWidgetBrowserAddBookmarkViewController *addViewController = [[[PWWidgetBrowserAddBookmarkViewController alloc] initForWidget:self.widget] autorelease];
		[self.widget pushViewController:addViewController animated:YES];
	}
}

- (void)titleTapped {
	[[PWWidgetBrowser widget] switchToWebInterface];
}

- (void)reload {
	// reload table view
	[self.tableView reloadData];
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	PWWidgetBrowserDefault defaultBrowser = [(PWWidgetBrowser *)self.widget defaultBrowser];
	return defaultBrowser == PWWidgetBrowserDefaultSafari;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Delete";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	
	if (row >= [_items count]) return;
	
	WebBookmarkCollection *collection = [WebBookmarkCollection safariBookmarkCollection];
	NSDictionary *item = _items[row];
	NSUInteger identifier = [(NSNumber *)item[@"identifier"] unsignedIntegerValue];
	
	WebBookmark *bookmark = [collection bookmarkWithID:identifier];
	[collection deleteBookmark:bookmark postChangeNotification:YES];
	
	[_items removeObjectAtIndex:row];
	[self reload];
	applyFadeTransition(tableView, PWTransitionAnimationDuration);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	
	// deselect the cell
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (row >= [_items count]) return;
	
	PWWidgetBrowser *widget = (PWWidgetBrowser *)self.widget;
	
	NSDictionary *item = _items[row];
	
	BOOL isFolder = [(NSNumber *)item[@"isFolder"] boolValue];
	NSUInteger identifier = [(NSNumber *)item[@"identifier"] unsignedIntegerValue];
	NSString *title = item[@"title"];
	NSString *address = item[@"address"];
	
	if (isFolder) {
		PWWidgetBrowserBookmarkViewController *bookmarkViewController = [[[PWWidgetBrowserBookmarkViewController alloc] initForWidget:self.widget] autorelease];
		bookmarkViewController.folderIdentifier = identifier;
		bookmarkViewController.folderTitle = title;
		[widget pushViewController:bookmarkViewController animated:YES];
	} else {
		[widget navigateToURL:address];
	}
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	
	NSString *identifier = @"PWWidgetBrowserBookmarkTableViewCell";
	PWThemableTableViewCell *cell = (PWThemableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		cell = [[[PWThemableTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier theme:self.theme] autorelease];
	}
	
	PWWidgetBrowser *widget = (PWWidgetBrowser *)self.widget;
	NSDictionary *item = _items[row];
	BOOL isFolder = [(NSNumber *)item[@"isFolder"] boolValue];
	NSString *title = item[@"title"];
	
	cell.textLabel.text = title;
	
	if (isFolder) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.imageView.image = [widget folderIcon];
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.imageView.image = [widget bookmarkIcon];
	}
	
	return cell;
}

- (void)loadBookmarkItems {
	
	PWWidgetBrowserDefault defaultBrowser = [(PWWidgetBrowser *)self.widget defaultBrowser];
	
	if (defaultBrowser == PWWidgetBrowserDefaultSafari) {
	
		WebBookmarkCollection *collecton = [WebBookmarkCollection safariBookmarkCollection];
		NSMutableArray *items = [NSMutableArray array];
		
		__block void(^processBookmark)(WebBookmark *) = ^void(WebBookmark *bookmark) {
			
			BOOL isFolder = bookmark.isFolder;
			BOOL isWebFilterWhiteListFolder = bookmark.isWebFilterWhiteListFolder;
			BOOL isReadingListFolder = bookmark.isReadingListFolder;
			if (isWebFilterWhiteListFolder || isReadingListFolder) return;
			
			NSUInteger identifier = bookmark.identifier;
			NSString *title = bookmark.localizedTitle;
			NSString *address = bookmark.address;
			
			if (title == nil) title = @"";
			if (address == nil) address = @"";
			
			NSDictionary *row = @{ @"identifier": @(identifier), @"title": title, @"address": address, @"isFolder": @(isFolder) };
			[items addObject:row];
		};
		
		__block void(^iterateSubitems)(WebBookmarkList *) = ^void(WebBookmarkList *list) {
			NSArray *bookmarks = [list bookmarkArray];
			for (WebBookmark *bookmark in bookmarks) {
				processBookmark(bookmark);
			}
		};
		
		if (_isRoot) {
			// reading list
			WebBookmark *readingListFolder = [collecton readingListFolder];
			if (readingListFolder != nil)
				processBookmark(readingListFolder);
			
			// favourite
			WebBookmark *bookmarksBarBookmark = [collecton bookmarksBarBookmark];
			if (bookmarksBarBookmark != nil)
				processBookmark(bookmarksBarBookmark);
			
			// root list
			WebBookmarkList *root = [collecton rootList];
			iterateSubitems(root);
			
		} else {
			
			// folder list
			WebBookmarkList *folderList = [collecton listWithID:_folderIdentifier];
			iterateSubitems(folderList);
		}
		
		[_items release];
		_items = [items retain];
		
	} else if (defaultBrowser == PWWidgetBrowserDefaultChrome) {
		
		NSArray *bookmarks = [PWWidgetBrowser readChromeBookmarks];
		
		if (_isRoot) {
			[_items release];
			_items = [bookmarks mutableCopy];
		} else {
			// search for the array with specified identifier
			__block void(^search)(NSArray *) = ^void(NSArray *root) {
				for (NSDictionary *item in root) {
					NSNumber *identifier = item[@"identifier"];
					NSArray *children = item[@"children"];
					if ([identifier unsignedIntegerValue] == _folderIdentifier) {
						[_items release];
						_items = [children mutableCopy];
					} else {
						// continue searching its children
						search(children);
					}
				}
			};
			search(bookmarks);
		}
	}
	
	[self.tableView reloadData];
}

- (void)dealloc {
	RELEASE(_folderTitle)
	RELEASE(_items)
	[super dealloc];
}

@end