//
//  CircleProgressRefreshView.h
//  CircleProgressRefreshView.h
//
//  Created by jung on 13. 10. 22..
//  Copyright (c) 2013년 jung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVCircularProgressView.h"

#define PulltoRefreshThreshold 67.0

typedef void (^actionHandler)(void);
typedef NS_ENUM(NSUInteger, PullToRefreshState) {
    PullToRefreshStateNormal, // 正常情况
    PullToRefreshStateTriggering, // offset 没有达到阈值
    PullToRefreshStateTriggered, // offset 达到阈值
    PullToRefreshStateLoading, // 正在加载中
};


@interface CircleProgressRefreshView : UIView

@property (nonatomic,assign) BOOL isObserving;
@property (nonatomic,assign) CGFloat originalTopInset;

@property (nonatomic,assign) PullToRefreshState state;
@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,copy) actionHandler pullToRefreshHandler;


@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,assign) CGFloat borderWidth;

@property (nonatomic, strong) NSDate *lastUpdatedDate;

- (void)manuallyTriggered; // 手动调用下拉刷新
- (void)stopAnimating; // 停止动画

@end
