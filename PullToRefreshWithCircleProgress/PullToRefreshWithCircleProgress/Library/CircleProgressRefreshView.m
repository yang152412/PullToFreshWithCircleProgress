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

#define ActivityIndicatorDefaultSize CGSizeMake(28, 28)

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

static CGFloat const PullToRefreshViewHeight = 60;

@interface RadialProgressActivityIndicatorBackgroundLayer : CALayer

@property (nonatomic,assign) CGFloat outlineWidth;
@property (nonatomic, strong) UIColor *tintColor;
- (id)initWithBorderWidth:(CGFloat)width;

@end
@implementation RadialProgressActivityIndicatorBackgroundLayer
- (id)init
{
    self = [super init];
    if(self) {
        self.outlineWidth=2.0f;
        self.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}
- (id)initWithBorderWidth:(CGFloat)width
{
    self = [super init];
    if(self) {
        self.outlineWidth=width;
        self.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}
- (void)drawInContext:(CGContextRef)ctx
{
    //Draw white circle,白色圆形背景
    CGContextSetFillColor(ctx, CGColorGetComponents(self.tintColor.CGColor));
    CGContextFillEllipseInRect(ctx,CGRectInset(self.bounds, self.outlineWidth, self.outlineWidth));

    //Draw circle outline，灰色圆形进度条
    CGContextSetStrokeColorWithColor(ctx, self.tintColor.CGColor);
    CGContextSetLineWidth(ctx, self.outlineWidth);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, self.outlineWidth , self.outlineWidth ));
}
- (void)setOutlineWidth:(CGFloat)outlineWidth
{
    _outlineWidth = outlineWidth;
    [self setNeedsDisplay];
}
- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    [self setNeedsDisplay];
}
@end

/*-----------------------------------------------------------------*/
@interface CircleProgressRefreshView()
{
    CGRect _activityIndicatorFrame;
}

// 转圈动画
@property (nonatomic, strong) EVCircularProgressView *activityIndicatorView;
// 圆圈背景
@property (nonatomic, strong) RadialProgressActivityIndicatorBackgroundLayer *backgroundLayer;
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
    
    self.subtitles = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
    
    self.textColor = [UIColor darkGrayColor];
    // label
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    _dateFormatter.locale = [NSLocale currentLocale];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 10, 180, 20)];
    _titleLabel.text = NSLocalizedString(@"Pull to refresh...",);
    _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _titleLabel.backgroundColor = [UIColor whiteColor];
    _titleLabel.textColor = self.textColor;
    [self addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 10, 180, 20)];
    _subtitleLabel.font = [UIFont systemFontOfSize:12];
    _subtitleLabel.backgroundColor = [UIColor lightGrayColor];
    _subtitleLabel.textColor = self.textColor;
    [self addSubview:_subtitleLabel];
    
    self.wasTriggeredByUser = YES;
    
    // 转圈 frame
    _activityIndicatorFrame = CGRectMake(100, 10, 28, 28);
    
    // red color
    self.borderColor = [UIColor colorWithRed:203/255.0 green:32/255.0 blue:39/255.0 alpha:1];
    self.borderWidth = 1.0f;
//    self.contentMode = UIViewContentModeRedraw;
    self.state = PullToRefreshStateNormal;
    
    //init background layer
    RadialProgressActivityIndicatorBackgroundLayer *backgroundLayer = [[RadialProgressActivityIndicatorBackgroundLayer alloc] initWithBorderWidth:self.borderWidth];
    backgroundLayer.frame = _activityIndicatorFrame;
    backgroundLayer.tintColor = [UIColor whiteColor];
    self.backgroundLayer = backgroundLayer;
    [self.layer addSublayer:self.backgroundLayer];
    

    //init arc draw layer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = CGRectMake(0, 0, 28, 28);
    shapeLayer.fillColor = nil;
    shapeLayer.strokeColor = self.borderColor.CGColor;
    shapeLayer.strokeEnd = 1;
    shapeLayer.contentsScale = [UIScreen mainScreen].scale;
    shapeLayer.lineWidth = self.borderWidth;
    self.shapeLayer = shapeLayer;
    [self.layer addSublayer:self.shapeLayer];
    
    EVCircularProgressView *activity = [[EVCircularProgressView alloc] initWithFrame:_activityIndicatorFrame];
    activity.progressTintColor = self.borderColor;
    activity.progressWidth = self.borderWidth;
    activity.hidden = YES;
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
//    self.shapeLayer.frame = _activityIndicatorFrame;
//    [self updatePath];
    
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
    
    NSString *subtitle = [self.subtitles objectAtIndex:self.state];
    self.subtitleLabel.text = subtitle.length > 0 ? subtitle : nil;
    
}

#pragma mark - ScrollViewInset
- (void)setScrollViewContentInsetForLoadingIndicator:(actionHandler)handler
{
    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height + 20.0);
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
    
    _backgroundLayer.outlineWidth = _borderWidth;
    [_backgroundLayer setNeedsDisplay];
    
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
//        [self setNeedsLayout];
//        [self setNeedsDisplay];
        [self layoutSubviews];
    }
    else if([keyPath isEqualToString:@"frame"])
    {
//        [self setNeedsLayout];
//        [self setNeedsDisplay];
        
        [self layoutSubviews];
    }
}
- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
//    static double prevProgress;
    CGFloat yOffset = contentOffset.y;
    NSLog(@" \n yOffset ==  %g",yOffset);
    if (yOffset >= 0) { // 向上滑
        self.progress = 0;
    }
    else if (-yOffset <= self.originalTopInset) {
        self.progress = 0;
    }else if (-(yOffset+ self.originalTopInset) >= PulltoRefreshThreshold){
        self.progress = 1;
    }else {
        self.progress = (fabs(yOffset+ self.originalTopInset + self.activityIndicatorView.frame.origin.y)/(PulltoRefreshThreshold - self.activityIndicatorView.frame.origin.y));
    }
    /*
    switch (_state) {
        case PullToRefreshStateStopped: //finish
            NSLog(@"Stoped");
            break;
        case PullToRefreshStateNone: //detect action
        {
            NSLog(@"None");
            if(self.scrollView.isDragging && yOffset <0 )
            {
                self.state = PullToRefreshStateTriggering;
            }
        }
        case PullToRefreshStateTriggering: //progress
        {
            NSLog(@"trigering");
                if(self.progress >= 1.0)
                    self.state = PullToRefreshStateTriggered;
        }
            break;
        case PullToRefreshStateTriggered: //fire actionhandler
            NSLog(@"trigered");
            if(self.scrollView.dragging == NO && prevProgress >=1 )
            {
                [self actionTriggeredState];
            }
            break;
        case PullToRefreshStateLoading: //wait until stopIndicatorAnimation
            NSLog(@"loading");
            break;
        default:
            break;
    }
    //because of iOS6 KVO performance
    prevProgress = self.progress;
    */
    
    if (self.state == PullToRefreshStateLoading) {
        CGFloat offset;
        UIEdgeInsets contentInset;
        offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
        offset = MIN(offset, self.originalTopInset + self.bounds.size.height);
        contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
    }
    else {
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
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.frame.size.height) animated:YES];
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
- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(_activityIndicatorFrame),
                                 CGRectGetMidY(_activityIndicatorFrame));
    
    CGFloat radius = _activityIndicatorFrame.size.width/2 - self.borderWidth;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:radius
                                                          startAngle:DEGREES_TO_RADIANS(-80)
                                                            endAngle:DEGREES_TO_RADIANS(-90)
                                                           clockwise:YES];
    
    self.shapeLayer.path = bezierPath.CGPath;
}
- (void)setProgress:(double)progress
{
    static double prevProgress;
    
    if(progress > 1.0)
    {
        progress = 1.0;
    }
    
    NSLog(@" \n progress == %g \n ",progress);
    if (progress >= 0 && progress <=1.0 && self.state != PullToRefreshStateLoading && self.state != PullToRefreshStateNormal) {
        
        //strokeAnimation
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//        animation.fromValue = [NSNumber numberWithFloat:((CAShapeLayer *)self.shapeLayer.presentationLayer).strokeEnd];
//        animation.toValue = [NSNumber numberWithFloat:progress];
//        animation.duration = 0.35 + 0.25*(fabs([animation.fromValue doubleValue] - [animation.toValue doubleValue]));
//        animation.removedOnCompletion = NO;
//        animation.fillMode = kCAFillModeBoth;
//        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        [self.shapeLayer addAnimation:animation forKey:@"animation"];
//        NSLog(@" \n animation.fromValue == %@ animation.toValue == %@ \n ",animation.fromValue,animation.toValue);
        
//        float pro = progress + ((CAShapeLayer *)self.shapeLayer.presentationLayer).strokeEnd;
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView setProgress:self.progress animated:YES];
    }
    _progress = progress;
    prevProgress = progress;
}

#pragma mark - Other methods

- (void)startIndeterminateAnimation
{
//    [self.shapeLayer removeAllAnimations];
//    [self.shapeLayer removeAnimationForKey:@"animation"];
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    self.shapeLayer.lineWidth = self.borderWidth;
//    self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
//                                                          radius:(_activityIndicatorFrame.size.width/2 - self.borderWidth)
//                                                      startAngle:DEGREES_TO_RADIANS(0)
//                                                        endAngle:DEGREES_TO_RADIANS(20)
//                                                       clockwise:YES].CGPath;
//    self.shapeLayer.strokeEnd = 1;
//    [CATransaction commit];
    
//    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
//    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
//    rotationAnimation.duration = 1.0;
//    rotationAnimation.repeatCount = HUGE_VALF;
//    [self.shapeLayer addAnimation:rotationAnimation forKey:@"indeterminateAnimation"];
    
    [self.activityIndicatorView startIndeterminateAnimation];
    self.activityIndicatorView.hidden = NO;
}

- (void)stopIndeterminateAnimation
{
//    [self.shapeLayer removeAnimationForKey:@"indeterminateAnimation"];
//    
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    self.backgroundLayer.hidden = NO;
//    [CATransaction commit];
    
    [self.activityIndicatorView stopIndeterminateAnimation];
    self.activityIndicatorView.hidden = YES;
}

@end