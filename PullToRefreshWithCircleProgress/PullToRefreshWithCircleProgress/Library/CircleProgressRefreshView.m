//
//  uzysRadialProgressActivityIndicator.m
//  UzysRadialProgressActivityIndicator
//
//  Created by Uzysjung on 13. 10. 22..
//  Copyright (c) 2013년 Uzysjung. All rights reserved.
//

#import "CircleProgressRefreshView.h"

#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0

#define ActivityIndicatorDefaultSize CGSizeMake(28, 28)

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
@property (nonatomic, strong) RadialProgressActivityIndicatorBackgroundLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
//@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, assign) double progress;

@end
@implementation CircleProgressRefreshView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 28, 28)];
    if(self) {
        [self _commonInit];
    }
    return self;
}
- (id)initWithImage:(UIImage *)image
{
    self = [super initWithFrame:CGRectMake(0, 0, 28, 28)];
    if(self) {
        self.imageIcon =image;
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    self.borderColor = [UIColor colorWithRed:203/255.0 green:32/255.0 blue:39/255.0 alpha:1];
    self.borderWidth = 1.0f;
    self.contentMode = UIViewContentModeRedraw;
    self.state = UZYSPullToRefreshStateNone;
    self.backgroundColor = [UIColor clearColor];
    //init actitvity indicator
    
    //init background layer
    RadialProgressActivityIndicatorBackgroundLayer *backgroundLayer = [[RadialProgressActivityIndicatorBackgroundLayer alloc] initWithBorderWidth:self.borderWidth];
    backgroundLayer.frame = self.bounds;
    backgroundLayer.tintColor = [UIColor whiteColor];
    [self.layer addSublayer:backgroundLayer];
    self.backgroundLayer = backgroundLayer;
    
//    if(!self.imageIcon) {
//        self.imageIcon = [UIImage imageNamed:@"centerIcon"];
//    }
    
    //init icon layer
//    CALayer *imageLayer = [CALayer layer];
//    imageLayer.contentsScale = [UIScreen mainScreen].scale;
//    imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);
//    imageLayer.contents = (id)self.imageIcon.CGImage;
//    [self.layer addSublayer:imageLayer];
//    self.imageLayer = imageLayer;
//    self.imageLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(180),0,0,1);

    //init arc draw layer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = nil;
    shapeLayer.strokeColor = self.borderColor.CGColor;
    shapeLayer.strokeEnd = 1;
//    shapeLayer.shadowColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
//    shapeLayer.shadowOpacity = 0.7;
//    shapeLayer.shadowRadius = 20;
    shapeLayer.contentsScale = [UIScreen mainScreen].scale;
    shapeLayer.lineWidth = self.borderWidth;
//    shapeLayer.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.shapeLayer.frame = self.bounds;
    [self updatePath];

}
- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:(self.bounds.size.width/2 - self.borderWidth)
                                                          startAngle:DEGREES_TO_RADIANS(-80)
                                                            endAngle:DEGREES_TO_RADIANS(-90)
                                                           clockwise:YES];

    self.shapeLayer.path = bezierPath.CGPath;
}

#pragma mark - ScrollViewInset
- (void)setupScrollViewContentInsetForLoadingIndicator:(actionHandler)handler
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
                         if(handler)
                             handler();
                     }];
}
#pragma mark - property
- (void)setProgress:(double)progress
{
    static double prevProgress;
    
    if(progress > 1.0)
    {
        progress = 1.0;
    }
    // 不需要修改透明度
//    self.alpha = 1.0 * progress;
    NSLog(@" \n progress == %g \n ",progress);
    if (progress >= 0 && progress <=1.0 && self.state != UZYSPullToRefreshStateLoading && self.state != UZYSPullToRefreshStateStopped) {
        //rotation Animation
//        CABasicAnimation *animationImage = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//        animationImage.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180-180*prevProgress)];
//        animationImage.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180-180*progress)];
//        animationImage.duration = 0.15;
//        animationImage.removedOnCompletion = NO;
//        animationImage.fillMode = kCAFillModeForwards;
//        [self.imageLayer addAnimation:animationImage forKey:@"animation"];

        //strokeAnimation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = [NSNumber numberWithFloat:((CAShapeLayer *)self.shapeLayer.presentationLayer).strokeEnd];
        animation.toValue = [NSNumber numberWithFloat:progress];
        animation.duration = 0.35 + 0.25*(fabs([animation.fromValue doubleValue] - [animation.toValue doubleValue]));
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeBoth;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [self.shapeLayer addAnimation:animation forKey:@"animation"];
        
        NSLog(@" \n animation.fromValue == %@ animation.toValue == %@ \n ",animation.fromValue,animation.toValue);
    }
    _progress = progress;
    prevProgress = progress;
}
-(void)setLayerOpacity:(CGFloat)opacity
{
//    self.imageLayer.opacity = opacity;
    self.backgroundLayer.opacity = opacity;
    self.shapeLayer.opacity = opacity;
}
-(void)setLayerHidden:(BOOL)hidden
{
//    self.imageLayer.hidden = hidden;
    self.shapeLayer.hidden = hidden;
    self.backgroundLayer.hidden = hidden;
}
-(void)setCenter:(CGPoint)center
{
    [super setCenter:center];
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
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    else if([keyPath isEqualToString:@"frame"])
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}
- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
    static double prevProgress;
    CGFloat yOffset = contentOffset.y;
    NSLog(@" \n yOffset ==  %g",yOffset);
    if (-yOffset <= self.frame.origin.y) {
        self.progress = 0;
    }else if (-(yOffset+ self.originalTopInset + self.frame.origin.y) >= PulltoRefreshThreshold){
        self.progress = 1;
    }else {
        self.progress = (-(yOffset+ self.originalTopInset + self.frame.origin.y)/PulltoRefreshThreshold);
    }
    
    
//    self.center = CGPointMake(self.center.x, (contentOffset.y+ self.originalTopInset)/2);
    switch (_state) {
        case UZYSPullToRefreshStateStopped: //finish
            NSLog(@"Stoped");
            break;
        case UZYSPullToRefreshStateNone: //detect action
        {
            NSLog(@"None");
            if(self.scrollView.isDragging && yOffset <0 )
            {
                self.state = UZYSPullToRefreshStateTriggering;
            }
        }
        case UZYSPullToRefreshStateTriggering: //progress
        {
            NSLog(@"trigering");
                if(self.progress >= 1.0)
                    self.state = UZYSPullToRefreshStateTriggered;
        }
            break;
        case UZYSPullToRefreshStateTriggered: //fire actionhandler
            NSLog(@"trigered");
            if(self.scrollView.dragging == NO && prevProgress >=1 )
            {
                [self actionTriggeredState];
            }
            break;
        case UZYSPullToRefreshStateLoading: //wait until stopIndicatorAnimation
            NSLog(@"loading");
            break;
        default:
            break;
    }
    //because of iOS6 KVO performance
    prevProgress = self.progress;
    
}
-(void)actionStopState
{
    self.state = UZYSPullToRefreshStateNone;
    [self stopIndeterminateAnimation];
    [self resetScrollViewContentInset:^{
        //            [self setLayerHidden:NO];
        //            [self setLayerOpacity:1.0];
    }];
    
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
//    } completion:^(BOOL finished) {
//        
//
//    }];
}
-(void)actionTriggeredState
{
    self.state = UZYSPullToRefreshStateLoading;
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
//        [self setLayerOpacity:0.0];
    } completion:^(BOOL finished) {
//        [self setLayerHidden:YES];
    }];
    
    [self startIndeterminateAnimation];
    [self setupScrollViewContentInsetForLoadingIndicator:nil];
    if(self.pullToRefreshHandler) {
        self.pullToRefreshHandler();
    }
}

#pragma mark - public method
- (void)stopIndicatorAnimation
{
    [self actionStopState];
}
- (void)manuallyTriggered
{
//    [self setLayerOpacity:0.0];

    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset + self.bounds.size.height + 30;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -currentInsets.top);
    } completion:^(BOOL finished) {
        [self actionTriggeredState];
    }];
}
- (void)setSize:(CGSize) size
{
    CGRect rect = CGRectMake((self.scrollView.bounds.size.width - size.width)/2,
                             -size.height, size.width, size.height);

    self.frame=rect;
    self.shapeLayer.frame = self.bounds;
//    self.imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);
    
    self.backgroundLayer.frame = self.bounds;
    [self.backgroundLayer setNeedsDisplay];
}
- (void)setImageIcon:(UIImage *)imageIcon
{
    _imageIcon = imageIcon;
//    _imageLayer.contents = (id)_imageIcon.CGImage;
//    _imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);

    if (!_imageIcon) {
        [self setSize:ActivityIndicatorDefaultSize];
    } else {
        [self setSize:_imageIcon.size];
    }
}
- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    
    _backgroundLayer.outlineWidth = _borderWidth;
    [_backgroundLayer setNeedsDisplay];
    
    _shapeLayer.lineWidth = _borderWidth;
//    _imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);

}
- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    _shapeLayer.strokeColor = _borderColor.CGColor;
}

#pragma mark - Other methods

//- (void)tintColorDidChange
//{
//    self.backgroundLayer.tintColor = self.progressTintColor;
//    self.shapeLayer.strokeColor = self.progressTintColor.CGColor;
//}

- (void)startIndeterminateAnimation
{
//    [self.shapeLayer removeAllAnimations];
    [self.shapeLayer removeAnimationForKey:@"animation"];
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    
////    self.backgroundLayer.hidden = YES;
//    
//    self.shapeLayer.lineWidth = self.borderWidth;
//    self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
//                                                          radius:(self.bounds.size.width/2 - self.borderWidth)
//                                                      startAngle:DEGREES_TO_RADIANS(0)
//                                                        endAngle:DEGREES_TO_RADIANS(20)
//                                                       clockwise:YES].CGPath;
//    self.shapeLayer.strokeEnd = 1;
//    
//    [CATransaction commit];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [self.shapeLayer addAnimation:rotationAnimation forKey:@"indeterminateAnimation"];
}

- (void)stopIndeterminateAnimation
{
    [self.shapeLayer removeAnimationForKey:@"indeterminateAnimation"];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.backgroundLayer.hidden = NO;
    [CATransaction commit];
}

@end