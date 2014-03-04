//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetAlarmOverviewViewController : PWContentViewController<UITableViewDelegate, UITableViewDataSource> {
	
	UILabel *_noLabel;
	NSArray *_alarms;
}

- (UITableView *)tableView;

@end