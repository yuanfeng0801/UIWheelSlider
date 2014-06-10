//
//  UIWheelSlider.m
//  UIWheelSlider
//
//  Created by yuanfeng on 14-6-10.
//  Copyright (c) 2014年 yuanfeng. All rights reserved.
//

#import "UIWheelSlider.h"

#define FLASH_ANIMATION_KEY     @"FLASH_ANIMATION_KEY"

#define BOUND(VALUE, MAXIMIM, MINIMIM)	MIN(MAX(VALUE, MINIMIM), MAXIMIM)

#define GENERATE_SETTER(PROPERTY, TYPE, SETTER, UPDATER) \
- (void)SETTER:(TYPE)PROPERTY { \
if (_##PROPERTY != PROPERTY) { \
_##PROPERTY = PROPERTY; \
[self UPDATER]; \
} \
}

@interface UIWheelSlider()
{
    double _radius;           //wheel radius
    double _width;            //wheel width
    double _curDeltaRadian;   //the radian that the nearest gear from x-axis
    
    double _diffViewAngle;    //the angle of invisible arc
    
    CGPoint _previousTouchPoint;         // previous touch point
    
    float _innerMiniValue;      //inner using MiniValue, maping self.minimumValue
    float _innerMaxValue;       //inner using MaxValue, maping self.maxmumValue
    float _innerValue;          //inner using value, maping self.value
    
    BOOL isPan;                 // did pan?
    
    //line color
    float colorRed;             //  0~1.0
    float colorGreen;           //  0~1.0
    float colorBlue;            //  0~1.0
    float colorAlpha;           //  0~1.0
}

@property (strong ,nonatomic) NSArray * lines ;       //the lines' position in y-axis

@end

@implementation UIWheelSlider
GENERATE_SETTER(value, float, setValue, redrawLayers)
GENERATE_SETTER(minimumValue, float, setMinimumValue, redrawLayers)
GENERATE_SETTER(maximumValue, float, setMaximumValue, redrawLayers)
GENERATE_SETTER(deltaRadian, double, setDeltaRadian, redrawLayers)
GENERATE_SETTER(minimumTintColor, UIColor*, setMinimumTintColor, redrawLayers)
GENERATE_SETTER(maximumTintColor, UIColor*, setMaximumTintColor, redrawLayers)

- (void) redrawLayers{
    [self calculateInnerValue];
    [self calculateColor];
    [self.layer setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _radius = frame.size.height/2;
        _width  = frame.size.width;
        _deltaRadian = M_PI/30;
        _curDeltaRadian = 0;
        _diffViewAngle = 0;
        
        _innerMiniValue = 0;
        _innerMaxValue = frame.size.height;
        _innerValue = 0;
        
        isPan = NO;
        
        colorRed  = 1.0;
        colorGreen = 1.0;
        colorBlue  = 1.0;
        colorAlpha = 0.0;
        
        _value = 0;
        _minimumValue = 0;
        _maximumValue = 1.0;
        _continuous = YES;
        _minimumTintColor = [UIColor colorWithRed:72.0/255.0 green:211.0/255.0 blue:199.0/255.0 alpha:1.0];
        _maximumTintColor = [UIColor colorWithRed:1.0 green:67.0/255.0 blue:85.0/255.0 alpha:1.0];
        
        [self addFrostedGlass];
        _lines = [self linesPositionForRadian:-_curDeltaRadian];
        
        self.layer.delegate  = self;
        
        [self redrawLayers];
    }
    return self;
}

//frosted glass
-(void)addFrostedGlass{
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.colors = @[(id)[[UIColor clearColor] CGColor],
                         (id)[[UIColor blackColor] CGColor],
                         (id)[[UIColor blackColor] CGColor],
                         (id)[[UIColor clearColor] CGColor],];
    maskLayer.locations = @[@0.0, @0.1, @0.9, @1.0];
    maskLayer.startPoint = CGPointMake(0.0, 0.0);
    maskLayer.endPoint = CGPointMake(0.0, 1.0);
    self.layer.mask = maskLayer;
}


-(NSArray *)linesPositionForRadian:(double)rad{
    NSMutableArray * positions = [[NSMutableArray alloc] initWithCapacity:0];
    
    int i =(int) ((M_PI_2 - rad - _diffViewAngle)/self.deltaRadian);
    
    
    while (self.deltaRadian*i+rad > -M_PI_2 + _diffViewAngle) {
        double y = _radius* sin(self.deltaRadian*i+rad);
        [positions addObject:[NSNumber numberWithFloat:_radius -y ]];
        i--;
    }
    
    return positions;
}

#pragma mark overwrite Calayer method

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    if (layer == self.layer) {
        for (NSNumber * num in _lines) {
            //white color
            double y = [num floatValue];
            CGContextMoveToPoint(ctx, 0, y);
            CGContextAddLineToPoint(ctx, _width, y);
            CGContextClosePath(ctx);
            CGContextSetLineWidth(ctx, 1);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGContextSetStrokeColorWithColor(ctx,[UIColor colorWithWhite:1.0 alpha:(isPan ? 0.75 : 0.5)].CGColor);
            CGContextStrokePath(ctx);
            
            //tint color ;
            if (colorAlpha) {
                CGContextMoveToPoint(ctx, 0, y);
                CGContextAddLineToPoint(ctx, _width, y);
                CGContextClosePath(ctx);
                CGContextSetLineWidth(ctx, 1);
                CGContextSetLineCap(ctx, kCGLineCapRound);
                CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:colorRed green:colorGreen blue:colorBlue alpha:(isPan ? 1.0 : 0.5)*colorAlpha].CGColor);
                CGContextStrokePath(ctx);
            }
        }
    }
}

#pragma mark calculate color
-(void)calculateColor{
    float innerValueDelta = _innerMaxValue-_innerMiniValue;
    float factor = _innerValue/innerValueDelta;
    factor = BOUND(factor, 1.0, 0.0);
    
    //calculate color；
    if (factor > 0.8) {
        [self.maximumTintColor getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&colorAlpha];
        colorAlpha = (factor-0.8)*5;
    }
    else if (factor <0.2){
        [self.minimumTintColor getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&colorAlpha];
        colorAlpha = (0.2-factor)*5;
    }
    else{
        [[UIColor whiteColor] getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&colorAlpha];
        colorAlpha = 0;
    }
}

#pragma mark calculate value and innerValue
-(void)calculateValue
{
    float innerValueDelta = _innerMaxValue-_innerMiniValue;
    float factor = _innerValue/innerValueDelta;
    factor = BOUND(factor, 1.0, 0.0);
    
    self.value =self.minimumValue + (self.maximumValue - self.minimumValue)*factor;
    self.value = BOUND(self.value, self.maximumValue, self.minimumValue);
}

-(void)calculateInnerValue{
    float valueDelta = self.maximumValue -self.minimumValue;
    float factor = self.value/valueDelta;
    factor = BOUND(factor, 1.0, 0.0);
    _innerValue = _innerMiniValue + (_innerMaxValue-_innerMiniValue)*factor;
    _innerValue = BOUND(_innerValue, _innerMaxValue, _innerMiniValue);
}

#pragma mark - overwrite UIControl methods

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _previousTouchPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(self.layer.bounds, _previousTouchPoint))
    {
        isPan = YES;
        [self.layer setNeedsDisplay];
        return YES;
    }
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    // 1. determine by how much the user has dragged
    float deltaY = touchPoint.y - _previousTouchPoint.y;
    float radiusDelta = deltaY/_radius;
    _previousTouchPoint = touchPoint;
    
    // 2. update the values and animation
    float innervalueTemp = _innerValue + deltaY;
    innervalueTemp = BOUND(innervalueTemp, _innerMaxValue, _innerMiniValue);
    
    //error correction
    float diffInnerValue = innervalueTemp-_innerValue;
    //    NSLog(@"\ninnervalueTemp:%lf,\n_innerValue:%lf\ndiffInnerValue:%lf",innervalueTemp,_innerValue,diffInnerValue);
    if (innervalueTemp == _innerMiniValue || innervalueTemp == _innerMaxValue) {
        radiusDelta = diffInnerValue /_radius;
    }
    
    if (innervalueTemp == _innerMaxValue) {
        _innerValue = _innerMaxValue;
        [self addFlashAnimation];
        NSLog(@"max");
    }
    else if (innervalueTemp == _innerMiniValue){
        _innerValue = _innerMiniValue;
        [self addFlashAnimation];
        NSLog(@"mini");
    }
    else{
        _innerValue = innervalueTemp;
        
        [self removeFlashAnimation];
    }
    
    //3.  update the UI
    if (radiusDelta != 0) {
        
        _curDeltaRadian += radiusDelta;
        
        _lines = [self linesPositionForRadian:-_curDeltaRadian];
        
        [self calculateColor];
        [self calculateValue];
        
        [self.layer setNeedsDisplay];
    }
    
    // notification
    if (_continuous) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self removeFlashAnimation];
    
    isPan = NO;
    [self.layer setNeedsDisplay];
    
    if (!_continuous) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark flash animation
-(void)addFlashAnimation{
    if ([self.layer animationForKey:FLASH_ANIMATION_KEY]) {
        return;
    }
    
    CABasicAnimation* animation = [self animationFromValue:@1.0 toValue:@0.2 duration:0.4 autoreverses:YES repeat:YES];
    animation.beginTime = 1.0;
    [self.layer addAnimation:animation forKey:FLASH_ANIMATION_KEY];
}

-(void)removeFlashAnimation{
    if ([self.layer animationForKey:FLASH_ANIMATION_KEY]) {
        [self.layer removeAnimationForKey:FLASH_ANIMATION_KEY];
    }
}

-(CABasicAnimation *) animationFromValue:(id)fromValue toValue:(id)toValue duration:(CFTimeInterval)duration autoreverses:(BOOL)autoreverses repeat:(BOOL)repeat{
    CABasicAnimation* animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.autoreverses = autoreverses;
    animation.repeatCount = repeat? CGFLOAT_MAX: 0;
    animation.duration = duration;
    
    return animation;
}

@end
