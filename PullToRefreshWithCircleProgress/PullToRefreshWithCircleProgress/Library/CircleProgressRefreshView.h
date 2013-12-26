//
//  CircleProgressRefreshView.h
//  CircleProgressRefreshView.h
//
//  Created by jung on 13. 10. 22..
//  Copyright (c) 2013년 jung. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PulltoRefreshThreshold 60.0

typedef void (^actionHandler)(void);
typedef NS_ENUM(NSUInteger, PullToRefreshState) {
    PullToRefreshStateNone =0,
    PullToRefreshStateStopped,
    PullToRefreshStateTriggering,
    PullToRefreshStateTriggered,
    PullToRefreshStateLoading,
    
};


@interface CircleProgressRefreshView : UIView

@property (nonatomic,assign) BOOL isObserving;
@property (nonatomic,assign) CGFloat originalTopInset;
@property (nonatomic,assign) PullToRefreshState state;
@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,copy) actionHandler pullToRefreshHandler;

@property (nonatomic,strong) UIImage *imageIcon;
@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,assign) CGFloat borderWidth;

- (void)stopIndicatorAnimation;
- (void)manuallyTriggered;

- (id)initWithImage:(UIImage *)image;
- (void)setSize:(CGSize) size;

// On iOS 7, progressTintColor sets and gets the tintColor property, and therefore defaults to the value of tintColor
// On iOS 6, defaults to [UIColor blackColor]
//@property (nonatomic, strong) UIColor *progressTintColor;

@end
