//
//  UIScrollView+UzysInteractiveIndicator.m
//  UzysRadialProgressActivityIndicator
//
//  Created by Uzysjung on 2013. 11. 12..
//  Copyright (c) 2013년 Uzysjung. All rights reserved.
//

#import "UITableView+CircularProgressPullToRefresh.h"
#import <objc/runtime.h>
static char UIScrollViewPullToRefreshView;

@implementation UITableView (CircularProgressPullToRefresh)
@dynamic pullToRefreshView, showPullToRefresh;

- (void)addPullToRefreshActionHandler:(actionHandler)handler
{
    if(self.pullToRefreshView == nil)
    {
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor greenColor];
        [self setBackgroundView:bgView];
        
        CircleProgressRefreshView *view = [[CircleProgressRefreshView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, PulltoRefreshThreshold)];
        view.pullToRefreshHandler = handler;
        view.scrollView = self;
        view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
//        view.frame = CGRectMake((self.bounds.size.width - view.bounds.size.width)/2-50,10, view.bounds.size.width, view.bounds.size.height);
        view.originalTopInset = self.contentInset.top;
//        [self addSubview:view];
//        [self sendSubviewToBack:view];
        
        self.pullToRefreshView = view;
        self.showPullToRefresh = YES;
        [bgView addSubview:view];
        
        // add a line
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.origin.y + PulltoRefreshThreshold, 320, 1)];
        line.backgroundColor = [UIColor yellowColor];
        [bgView addSubview:line];
        [bgView sendSubviewToBack:line];
    }
}

- (void)triggerPullToRefresh
{
    [self.pullToRefreshView manuallyTriggered];
}
- (void)stopRefreshAnimation
{
    [self.pullToRefreshView stopAnimating];
}
#pragma mark - property
- (void)setPullToRefreshView:(CircleProgressRefreshView *)pullToRefreshView
{
    [self willChangeValueForKey:@"CircleProgressRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView, pullToRefreshView, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"CircleProgressRefreshView"];
}
- (CircleProgressRefreshView *)pullToRefreshView
{
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

- (void)setShowPullToRefresh:(BOOL)showPullToRefresh {
    self.pullToRefreshView.hidden = !showPullToRefresh;
    
    if(showPullToRefresh)
    {
        if(!self.pullToRefreshView.isObserving)
        {
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            self.pullToRefreshView.isObserving = YES;
        }
    }
    else
    {
        if(self.pullToRefreshView.isObserving)
        {
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentOffset"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentSize"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"frame"];
            self.pullToRefreshView.isObserving = NO;
        }
    }
}

- (BOOL)showPullToRefresh
{
    return !self.pullToRefreshView.hidden;
}
@end
