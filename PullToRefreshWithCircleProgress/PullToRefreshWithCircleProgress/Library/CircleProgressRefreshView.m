//
//  CircleProgressRefreshView.m
//  CircleProgressRefreshView
//
//  Created by jung on 13. 10. 22..
//  Copyright (c) 2013년 jung. All rights reserved.
//

#import "CircleProgressRefreshView.h"
#import "UITableView+CircularProgressPullToRefresh.h"

#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0

//#define ActivityIndicatorDefaultSize CGSizeMake(28, 28)

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

/*-----------------------------------------------------------------*/
@interface CircleProgressRefreshView()
{
    CGRect _activityIndicatorFrame;
}

// 转圈动画
@property (nonatomic, strong) EVCircularProgressView *activityIndicatorView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) double progress; // 进度条

// label
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UILabel *subtitleLabel;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *subtitles;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSDate *lastUpdatedDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) BOOL wasTriggeredByUser;

@end

@implementation CircleProgressRefreshView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        // default styling values
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    self.titles = [NSMutableArray arrayWithObjects:NSLocalizedString(@"Pull to refresh...",),
                   NSLocalizedString(@"Release to refresh...",),
                   NSLocalizedString(@"Release to refresh...",),
                   NSLocalizedString(@"Loading...",),
                   nil];
    
    self.subtitles = [NSMutableArray arrayWithObjects:[[NSDate date] description], @"", @"", @"", nil];
    
    self.textColor = [UIColor darkTextColor];
    // label
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    _dateFormatter.locale = [NSLocale currentLocale];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 19, 180, 20)];
    _titleLabel.text = NSLocalizedString(@"Pull to refresh...",);
    _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _titleLabel.backgroundColor = [UIColor whiteColor];
    _titleLabel.textColor = self.textColor;
    [self addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 39, 180, 20)];
    _subtitleLabel.font = [UIFont systemFontOfSize:12];
    _subtitleLabel.backgroundColor = [UIColor lightGrayColor];
    _subtitleLabel.textColor = [UIColor lightTextColor];
    [self addSubview:_subtitleLabel];
    
    self.wasTriggeredByUser = YES;
    
    // 转圈 frame
    _activityIndicatorFrame = CGRectMake(100, 19, 16, 16);
    
    // red color
    self.borderColor = [UIColor colorWithRed:203/255.0 green:32/255.0 blue:39/255.0 alpha:1];
    self.borderWidth = 1.0f;
//    self.contentMode = UIViewContentModeRedraw;
    self.state = PullToRefreshStateNormal;
    
    EVCircularProgressView *activity = [[EVCircularProgressView alloc] initWithFrame:_activityIndicatorFrame];
    activity.progressTintColor = self.borderColor;
    activity.progressWidth = self.borderWidth;
    self.activityIndicatorView = activity;
    [self addSubview:self.activityIndicatorView];
    
    // 设置state
    self.state = PullToRefreshStateNormal;
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UITableView *scrollView = (UITableView *)self.superview;
        if (scrollView.showPullToRefresh) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    switch (self.state) {
        case PullToRefreshStateNormal:
            [self stopIndeterminateAnimation];
            break;
        case PullToRefreshStateTriggered:
            break;
        case PullToRefreshStateTriggering:
            break;
        case PullToRefreshStateLoading:
            [self startIndeterminateAnimation];
            break;
    }
    
    // 更新 title
    self.titleLabel.text = [self.titles objectAtIndex:self.state];
    
//    NSString *subtitle = [self.subtitles objectAtIndex:self.state];
//    self.subtitleLabel.text = subtitle.length > 0 ? subtitle : nil;
    
    self.subtitleLabel.text = [[NSDate date] description];
}

#pragma mark - ScrollViewInset
- (void)setScrollViewContentInsetForLoadingIndicator:(actionHandler)handler
{
//    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
//    currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height + _activityIndicatorFrame.origin.y);
    currentInsets.top = self.originalTopInset + PulltoRefreshThreshold;
    NSLog(@" \n currentInsets.top == %g ",currentInsets.top);
    [self setScrollViewContentInset:currentInsets handler:handler];
}
- (void)resetScrollViewContentInset:(actionHandler)handler
{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    [self setScrollViewContentInset:currentInsets handler:handler];
}
- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset handler:(actionHandler)handler
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished) {
                         if(handler) {
                             handler();
                         }
                     }];
}
#pragma mark - Setter property
- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    _shapeLayer.lineWidth = _borderWidth;
    
}
- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    _shapeLayer.strokeColor = _borderColor.CGColor;
}

- (void)setTextColor:(UIColor *)newTextColor {
    _textColor = newTextColor;
    self.titleLabel.textColor = newTextColor;
	self.subtitleLabel.textColor = newTextColor;
}

- (void)setTitle:(NSString *)title forState:(PullToRefreshState)state {
    if(!title) {
        title = @"";
    }
//    if(state == SVPullToRefreshStateAll)
//        [self.titles replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[title, title, title]];
//    else
        [self.titles replaceObjectAtIndex:state withObject:title];
    
    [self setNeedsLayout];
}

- (void)setSubtitle:(NSString *)subtitle forState:(PullToRefreshState)state {
    if(!subtitle) {
        subtitle = @"";
    }
//    if(state == PullToRefreshStateAll)
//        [self.subtitles replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[subtitle, subtitle, subtitle]];
//    else
        [self.subtitles replaceObjectAtIndex:state withObject:subtitle];
    
    [self setNeedsLayout];
}

- (void)setLastUpdatedDate:(NSDate *)newLastUpdatedDate {
    self.subtitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@",), newLastUpdatedDate?[self.dateFormatter stringFromDate:newLastUpdatedDate]:NSLocalizedString(@"Never",)];
}

- (void)setDateFormatter:(NSDateFormatter *)newDateFormatter {
	_dateFormatter = newDateFormatter;
    self.subtitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@",), self.lastUpdatedDate?[newDateFormatter stringFromDate:self.lastUpdatedDate]:NSLocalizedString(@"Never",)];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        [self layoutSubviews];
    }
    else if([keyPath isEqualToString:@"frame"])
    {
        [self layoutSubviews];
    }
}
- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
    CGFloat yOffset = contentOffset.y;
    NSLog(@" \n yOffset ==  %g",yOffset);
    
    if (self.state == PullToRefreshStateLoading) {
        CGFloat offset;
        UIEdgeInsets contentInset;
        offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
        offset = MIN(offset, self.originalTopInset + self.bounds.size.height);
        contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
    }
    else {
        if (yOffset >= 0) { // 向上滑
            self.progress = 0;
        }
        else if (-yOffset <= self.activityIndicatorView.frame.origin.y) {
            self.progress = 0;
        }
        else if (-yOffset <= self.originalTopInset) {
            self.progress = 0;
        }else if (fabs((-yOffset+ self.originalTopInset)) >= PulltoRefreshThreshold){
            self.progress = 1;
        }else {
            self.progress = (fabs(-yOffset+ self.originalTopInset - self.activityIndicatorView.frame.origin.y)/(PulltoRefreshThreshold - self.activityIndicatorView.frame.origin.y));
            NSLog(@"\n yOffset == %g \n,self.porgress == %g",yOffset,self.progress);
        }
        
        // 向下滑动，offset.y < 0;
//        CGFloat offsetY = contentOffset.y * -1.0;
//        CGFloat scrollOffsetThreshold = self.frame.origin.y - self.originalTopInset;
        CGFloat scrollOffsetThreshold = -PulltoRefreshThreshold;
        if (!self.scrollView.isDragging && self.state == PullToRefreshStateTriggered) {
            // 松开手指，已经达到 offset阈值，开始loading
            self.state = PullToRefreshStateLoading;
        }
        else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == PullToRefreshStateNormal)
        {
            // offset，已经达到阈值，但是还在dragging，
            self.state = PullToRefreshStateTriggered;
        }
        else if (contentOffset.y >= scrollOffsetThreshold && self.state != PullToRefreshStateNormal) {
            // offset 没有达到阈值，
            self.state = PullToRefreshStateNormal;
        }
    }
    
}

#pragma mark - public method

- (void)manuallyTriggered
{
    self.state = PullToRefreshStateTriggered;
    [self startAnimating];
}

- (void)startAnimating{
    
    if(fequalzero(self.scrollView.contentOffset.y)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -(self.frame.size.height+self.frame.origin.y)) animated:YES];
        self.wasTriggeredByUser = NO;
    }
    else {
        self.wasTriggeredByUser = YES;
    }
    self.state = PullToRefreshStateLoading;
}

- (void)stopAnimating {
    self.state = PullToRefreshStateNormal;
    
    if(!self.wasTriggeredByUser) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalTopInset) animated:YES];
    }
}

- (void)setState:(PullToRefreshState)newState {
    
    if(_state == newState)
        return;
    NSLog(@" setState: %d ",newState);
    
    PullToRefreshState previousState = _state;
    _state = newState;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    switch (newState) {
        case PullToRefreshStateNormal:
            [self resetScrollViewContentInset:nil];
            break;
            
        case PullToRefreshStateTriggered:
            break;
        case PullToRefreshStateTriggering:
            break;
        case PullToRefreshStateLoading:
            if(previousState == PullToRefreshStateTriggered && self.pullToRefreshHandler) {
                [self setScrollViewContentInsetForLoadingIndicator:self.pullToRefreshHandler];
            }
            break;
    }
}

#pragma mark - 进度条
- (void)setProgress:(double)progress
{
    NSLog(@" \n porgress == %g \n ",progress);
    if(progress > 1.0)
    {
        progress = 1.0;
    }
    _progress = progress;
    [self.activityIndicatorView setProgress:self.progress animated:NO];
}

#pragma mark - Other methods

- (void)startIndeterminateAnimation
{
    [self.activityIndicatorView startIndeterminateAnimation];
}

- (void)stopIndeterminateAnimation
{
    [self.activityIndicatorView stopIndeterminateAnimation];
}

@end