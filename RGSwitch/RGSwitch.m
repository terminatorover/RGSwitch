//
//  RGDrawerView.m
//  Drawing
//
//  Created by ROBERA GELETA on 2/19/16.
//  Copyright (c) 2016 ROBERA GELETA. All rights reserved.
//
#define BACKGROUND_COLOR [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
#define RG_SWITCH_MIN_HEIGHT 50
#define RG_SWITCH_MAX_HEIGHT 300
#define RG_DEFAULT_BACKGROUND_COLOR [UIColor colorWithRed:0.23 green:0.51 blue:0.95 alpha:1];

#define TOTAL_ANIMATION_TIME 1.1
#define STRIP_BACKGROUNDCOLOR [UIColor colorWithRed:0.1 green:0.34 blue:0.7 alpha:1]

#import "RGSwitch.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>

@interface RGSwitch ()

@property UIView *controlPoint1;
@property UIView *controlPoint2;
@property UIView *controlPoint3;
@property UIView *controlPoint4;

@end

@implementation RGSwitch
{
    CGFloat _switchHeight;
    CGFloat _switchWidth;


    CGFloat _bigCircleDimension;
    CGFloat _smallCircleDimension;

    CGPoint _leftCenterPoint;
    CGPoint _rightCenterPoint;
    CGFloat _distanceBetweenAnchorPoints;
    
    CGFloat _stripHeight;
    CGFloat _stripRadius;


    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    CGPoint point4;
    CGPoint pointC1;
    CGPoint pointC2;

    CGFloat r1;
    CGFloat r2;
    CGFloat x1;
    CGFloat y1;
    CGFloat x2;
    CGFloat y2;

    BOOL _isAnimating;

    CADisplayLink *_displayLink;
    UITapGestureRecognizer *_tapGestureRecognizer;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    CGFloat xPosition = CGRectGetMinX(frame);
    CGFloat yPosition = CGRectGetMinY(frame);
    CGFloat frameHeight = CGRectGetHeight(frame);
    frameHeight = MAX(frameHeight, RG_SWITCH_MIN_HEIGHT);
    frameHeight = MIN(frameHeight, RG_SWITCH_MAX_HEIGHT);
    _bigCircleDimension = frameHeight/2.0 * 1.0;//note the .8 is because imperfect bezier cirlce drawing bleeds some part of the big circle outside the container view
    _switchWidth = (_bigCircleDimension * 2.0) + (1.75 * _bigCircleDimension);//the extra is the space in between the two anchor points
    CGFloat frameWidth = _switchWidth;
    frame = CGRectMake(xPosition, yPosition,frameHeight,frameWidth);

    _switchHeight = frameHeight;
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;

        _smallCircleDimension = _bigCircleDimension * .2;
        CGFloat yMidPoint = _switchHeight/2.0;//mid point for the two anchors
        _leftCenterPoint = CGPointMake(_bigCircleDimension, yMidPoint);
        _rightCenterPoint = CGPointMake(_switchWidth - _bigCircleDimension, yMidPoint);
        
        _isAnimating = NO;
        _isOn = NO;

        _displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(refresh:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

        CGFloat oneSideOfControlPoint = 4;
        _controlPoint1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, oneSideOfControlPoint,oneSideOfControlPoint)];
        _controlPoint2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, oneSideOfControlPoint, oneSideOfControlPoint)];
        _controlPoint3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, oneSideOfControlPoint, oneSideOfControlPoint)];
        _controlPoint4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, oneSideOfControlPoint, oneSideOfControlPoint)];

        [self addSubview:_controlPoint1];
        [self addSubview:_controlPoint2];
        [self addSubview:_controlPoint3];
        [self addSubview:_controlPoint4];
        
        
        //inital positioning
        [self setView:_controlPoint1 right:NO big:YES top:YES];
        [self setView:_controlPoint2 right:NO big:YES top:NO];
        
        [self setView:_controlPoint3 right:NO big:NO top:YES];
        [self setView:_controlPoint4 right:NO big:NO top:NO];

        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(tapped)];
        [self addGestureRecognizer:_tapGestureRecognizer];

        self.stripColor = STRIP_BACKGROUNDCOLOR;
        self.buttonColor = BACKGROUND_COLOR;
        self.backgroundColor = RG_DEFAULT_BACKGROUND_COLOR;
    }
    [self sizeToFit];
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    for (UIView *view in self.subviews) {
        if (view == self.controlPoint1 ||
            view == self.controlPoint2 ||
            view == self.controlPoint3 ||
            view == self.controlPoint4) {
            continue;
        }
        else {
            [view removeFromSuperview];
        }
    }

    // Drawing code


    _stripHeight = _bigCircleDimension * .8;
    _stripRadius = _stripHeight /2.0;
    CGFloat yMidPoint = _switchHeight/2.0;//Y mid point for the two anchors
    _leftCenterPoint = CGPointMake(_bigCircleDimension, yMidPoint);
    _rightCenterPoint = CGPointMake(_switchWidth - _bigCircleDimension, yMidPoint);
    _distanceBetweenAnchorPoints = _rightCenterPoint.x - _leftCenterPoint.x;
    

    [self drawTabStripWithColor:self.stripColor];
    

    CGPoint circleLeftCenter;
    CGPoint circleRightCenter;
    
    CGFloat circleLeftRadius;
    CGFloat circleRightRadius;

   
    //---------------  -----------------\\ the control point views drive the params
    //and we compute the center and radius for both circles

    CGPoint pointAViewCenter = [self layerCenterForView:self.controlPoint1];
    CGPoint pointBViewCenter = [self layerCenterForView:self.controlPoint2];
    CGPoint pointCViewCenter = [self layerCenterForView:self.controlPoint3];
    CGPoint pointDViewCenter = [self layerCenterForView:self.controlPoint4];


    circleLeftCenter = CGPointMake(pointAViewCenter.x,(pointAViewCenter.y + pointBViewCenter.y) /2.0);
    circleRightCenter = CGPointMake(pointDViewCenter.x,(pointCViewCenter.y + pointDViewCenter.y) /2.0);

    
    r1 = (pointBViewCenter.y - pointAViewCenter.y)/2.0;
    r2 = (pointDViewCenter.y - pointCViewCenter.y)/2.0;

    circleLeftRadius = r1;
    circleRightRadius = r2;

    [self pathWithCenter:circleLeftCenter
               dimension:circleLeftRadius * 2.0
                   color:self.buttonColor];
    

    [self pathWithCenter:circleRightCenter
               dimension:(circleRightRadius * 2.0)
                   color:self.buttonColor];


    //glue view drawing parameters
    r1 = circleLeftRadius;
    r2 = circleRightRadius;

    x1 = circleLeftCenter.x;
    y1 = circleLeftCenter.y;

    x2 = circleRightCenter.x;
    y2 = circleRightCenter.y;


    //compute control point y offset from center for glue view
    //these are "live"
    CGPoint  topCenterOfLeftCirlce = CGPointMake(circleLeftCenter.x, circleLeftCenter.y - circleLeftRadius);
    CGPoint  topCenterOfRightCircle = CGPointMake(circleRightCenter.x, circleRightCenter.y - circleRightRadius);
    
    CGPoint  bottomCenterOfLeftCirlce = CGPointMake(circleLeftCenter.x, circleLeftCenter.y + circleLeftRadius);
    CGPoint  bottomCenterOfRightCircle = CGPointMake(circleRightCenter.x, circleRightCenter.y + circleRightRadius);

    
    CGFloat  horizonatlDistanceBetweenCircleCenters = fabs(circleRightCenter.x - circleLeftCenter.x);
    
    CGFloat distanceBetweenCircleCenters = [self distanceBetweenPoint1:topCenterOfLeftCirlce
                                                                point2:topCenterOfRightCircle];
    
    CGFloat cosineValue = horizonatlDistanceBetweenCircleCenters/distanceBetweenCircleCenters;
    CGFloat angle = acos(cosineValue);
    CGFloat offsetHeight = sin(angle) * distanceBetweenCircleCenters /2.0;

    CGFloat topOffset;
    CGFloat bottomOffset;
    if (circleLeftRadius > circleRightRadius) {//true initally, where the inital state is that the switch is aligned to the left
        topOffset = topCenterOfRightCircle.y;
        bottomOffset = bottomCenterOfRightCircle.y;
    }
    else {
        topOffset = topCenterOfLeftCirlce.y;
        bottomOffset = bottomCenterOfLeftCirlce.y;
    }


    point1 = CGPointMake(circleLeftCenter.x, circleLeftCenter.y - circleLeftRadius);
    point2 = CGPointMake(circleLeftCenter.x, circleLeftCenter.y + circleLeftRadius);
    point3 = CGPointMake(circleRightCenter.x, circleRightCenter.y + circleRightRadius);
    point4 = CGPointMake(circleRightCenter.x, circleRightCenter.y - circleRightRadius);
    
    pointC1 = CGPointMake((circleRightCenter.x + circleLeftCenter.x)/2.0
                         , bottomOffset + offsetHeight);
    pointC2 = CGPointMake((circleRightCenter.x + circleLeftCenter.x)/2.0
                         , topOffset - offsetHeight);


    UIBezierPath *gluePath = [UIBezierPath bezierPath];
    [gluePath moveToPoint: point1];
    [gluePath addQuadCurveToPoint:point4 controlPoint: pointC2];
    [gluePath addLineToPoint: point3];
    [gluePath addQuadCurveToPoint: point2 controlPoint: pointC1];
    [gluePath moveToPoint: point1];



    [[UIColor blackColor] setFill];
    [gluePath fill];
}




- (void)pathWithCenter:(CGPoint)center
             dimension:(CGFloat)dimension
                 color:(UIColor *)color
{
    
    CGFloat centerX = center.x;
    CGFloat centerY = center.y;
    
    CGFloat halfDimension = dimension /2.0;
    
    CGFloat approx = 0.552284749831;
    CGFloat controlPointDimension = approx * halfDimension;
    
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    ovalPath.lineWidth = 9;
    [color setStroke];
    [color setFill];
    
    [ovalPath moveToPoint:CGPointMake(centerX, centerY - halfDimension)];
    
    [ovalPath addCurveToPoint:CGPointMake(centerX + halfDimension, centerY)
                controlPoint1:CGPointMake(centerX + controlPointDimension, centerY - halfDimension)
                controlPoint2:CGPointMake(centerX + halfDimension, centerY - controlPointDimension)];
    

    [ovalPath addCurveToPoint:CGPointMake(centerX, centerY + halfDimension)
                controlPoint1:CGPointMake(centerX + halfDimension, centerY + controlPointDimension)
                controlPoint2:CGPointMake(centerX + controlPointDimension, centerY + halfDimension)];
    
    
    [ovalPath addCurveToPoint:CGPointMake(centerX - halfDimension, centerY)
                controlPoint1:CGPointMake(centerX - controlPointDimension, centerY + halfDimension)
                controlPoint2:CGPointMake(centerX - halfDimension, centerY + controlPointDimension)];
    
    [ovalPath addCurveToPoint:CGPointMake(centerX, centerY - halfDimension)
                controlPoint1:CGPointMake(centerX - halfDimension, centerY - controlPointDimension)
                controlPoint2:CGPointMake(centerX - controlPointDimension, centerY - halfDimension)];
    
    
    [ovalPath stroke];
    [ovalPath fill];
}



- (void)drawTabStripWithColor:(UIColor *)color
{
    UIBezierPath *stripPath = [UIBezierPath bezierPath];
    [stripPath moveToPoint:CGPointMake(_leftCenterPoint.x,_leftCenterPoint.y - _stripRadius)];
    [stripPath addLineToPoint:CGPointMake(_rightCenterPoint.x, _rightCenterPoint.y - _stripRadius)];
    
    [stripPath addArcWithCenter:_rightCenterPoint
                         radius:_stripRadius
                     startAngle:(M_PI * 1.5)
                       endAngle:(M_PI * .5)
                      clockwise:YES];
    
    [stripPath addLineToPoint:CGPointMake(_leftCenterPoint.x,_leftCenterPoint.y + _stripRadius)];
    
    [stripPath addArcWithCenter:_leftCenterPoint
                         radius:_stripRadius
                     startAngle:M_PI_2
                       endAngle:(M_PI * 1.5)
                      clockwise:YES];
    
    [stripPath closePath];
    
    [color setFill];
    [stripPath fill];
}


- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(_switchWidth, _switchHeight);
}


#pragma mark - Helper
- (CGFloat)distanceBetweenPoint1:(CGPoint)p1
                          point2:(CGPoint)p2
{
    return sqrtf ((p2.x-p1.x) * (p2.x-p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
}


#pragma mark - Rerfresh

- (void)refresh:(CADisplayLink *)displayLink
{
    [self setNeedsDisplay];
}


#pragma mark

- (void)animateToOn
{
    _isAnimating = YES;
    _displayLink.paused = NO;
    CGFloat time = TOTAL_ANIMATION_TIME;
     [UIView animateWithDuration:time
                          delay:0
         usingSpringWithDamping:.5
          initialSpringVelocity:.6
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setView:self.controlPoint3 right:YES big:YES top:YES];
                         [self setView:self.controlPoint4 right:YES big:YES top:NO];
                     }
                     completion:^(BOOL finished) {
                         
                     }];


     [UIView animateWithDuration:time
                          delay:(time *.1)
         usingSpringWithDamping:.4//1
          initialSpringVelocity:.6//2
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setView:self.controlPoint1 right:YES big:NO top:YES];
                         [self setView:self.controlPoint2 right:YES big:NO top:NO];
                     }
                     completion:^(BOOL finished) {
                         _isAnimating = NO;
                         _displayLink.paused = YES;
                         _isOn = YES;
                     }];
}


- (void)animateToOff
{
    _isAnimating = YES;
    _displayLink.paused = NO;
    CGFloat time = TOTAL_ANIMATION_TIME;

    [UIView animateWithDuration:time
                          delay:0
         usingSpringWithDamping:.4
          initialSpringVelocity:.6
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setView:_controlPoint1 right:NO big:YES top:YES];
                         [self setView:_controlPoint2 right:NO big:YES top:NO];
                     }
                     completion:^(BOOL finished) {

                     }];


    [UIView animateWithDuration:time
                          delay:(time *.1)
         usingSpringWithDamping:.4
          initialSpringVelocity:.6
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setView:_controlPoint3 right:NO big:NO top:YES];
                         [self setView:_controlPoint4 right:NO big:NO top:NO];
                     }
                     completion:^(BOOL finished) {
                         _isAnimating = NO;
                         _displayLink.paused = YES;
                         _isOn = NO;
                     }];

}

#pragma mark - Helper For setting up the states

- (void)setView:(UIView *)view
          right:(BOOL)right
            big:(BOOL)big
            top:(BOOL)top
{
    CGPoint finalPoint;
    NSInteger offsetType = top ? -1 : 1;
    if (right) {
        if (big) {
           finalPoint = CGPointMake(_rightCenterPoint.x - 3,
                                    _rightCenterPoint.y + (_bigCircleDimension/2.0 * offsetType));
        }
        else {
            finalPoint = CGPointMake(_rightCenterPoint.x - 3,
                                     _rightCenterPoint.y + (_smallCircleDimension/2.0 * offsetType));
        }
    }
    else {
        if (big) {
            finalPoint = CGPointMake(_leftCenterPoint.x + 4,
                                     _leftCenterPoint.y + (_bigCircleDimension/2.0 * offsetType));
        }
        else {
            finalPoint = CGPointMake(_leftCenterPoint.x + 4,
                                     _leftCenterPoint.y + (_smallCircleDimension/2.0 * offsetType));
        }
    }
    view.center = finalPoint;
}

- (CGPoint )layerCenterForView:(UIView *)view
{
    CALayer *layer;
    layer = (CALayer *)view.layer.presentationLayer;
    if (layer) {
        return layer.position;
    }
    return ((CALayer *)view.layer.modelLayer).position;
}

- (CALayer *)layerForView:(UIView *)view
{
    CALayer *layer;
    layer = (CALayer *)view.layer.presentationLayer;
    if (layer) {
        return layer;
    }
    return  view.layer.modelLayer;
}

#pragma mark - Tapped

- (void)tapped
{
    if (!_isAnimating) {
        if (_isOn) {
            [self animateToOff];
        }
        else {
            [self animateToOn];
        }
    }
}

- (void)setButtonColor:(UIColor *)buttonColor
{
    _buttonColor = buttonColor;
    [self setNeedsDisplay];
}

- (void)setStripColor:(UIColor *)stripColor
{
    _stripColor = stripColor;
    [self setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [self setNeedsDisplay];
}

@end
