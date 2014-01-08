//
//  UIScrollView+UzysInteractiveIndicator.h
//  UzysRadialProgressActivityIndicator
//
//  Created by Uzysjung on 2013. 11. 12..
//  Copyright (c) 2013년 Uzysjung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressRefreshView.h"

@interface UITableView (CircularProgressPullToRefresh)
@property (nonatomic,assign) BOOL showPullToRefresh;
@property (nonatomic,strong,readonly) CircleProgressRefreshView *pullToRefreshView;

- (void)addPullToRefreshActionHandler:(actionHandler)handler;
- (void)addPullToRefreshWithUpdateDateKey:(NSString *)updateDateKey actionHandler:(actionHandler)handler;
- (void)triggerPullToRefresh;
- (void)stopRefreshAnimation;

@end
