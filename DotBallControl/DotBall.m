//
//  DotBall.m
//  DotBallControl
//
//  Created by Jialiang Xiang on 2015-05-14.
//  Copyright (c) 2015 Jialiang. All rights reserved.
//

#import "DotBall.h"
#import "Dot.h"

#define BALL_RADIUS 150.0

@implementation DotBall {
    CATransformLayer* ballBackLayer;
    float dotRadius;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // init iVars
        dotRadius = 15;
        
        // add background layer
        ballBackLayer = [CATransformLayer layer];
        ballBackLayer.frame = CGRectMake([self getScreenWidth]/2 - BALL_RADIUS, [self getScreenHeight]/2 - BALL_RADIUS, BALL_RADIUS * 2, BALL_RADIUS * 2);
        [self.layer addSublayer:ballBackLayer];
        
        // add outline layer
        CAShapeLayer* outline = [CAShapeLayer layer];
        outline.frame = CGRectMake([self getScreenWidth]/2 - BALL_RADIUS, [self getScreenHeight]/2 - BALL_RADIUS, BALL_RADIUS, BALL_RADIUS);
        outline.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*BALL_RADIUS, 2.0*BALL_RADIUS) cornerRadius:BALL_RADIUS].CGPath;
        outline.fillColor = [UIColor clearColor].CGColor;
        outline.strokeColor = [UIColor blackColor].CGColor;
        outline.lineWidth = 5;
        [self.layer addSublayer:outline];
        
        // TODO: add alpha mask
        
        [self initGestureRecognizers];
        [self initBall];
    }
    return self;
}

- (void)initGestureRecognizers
{
    // add gesture recognizers
    UIPanGestureRecognizer* oneFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneFingerPan:)];
    oneFingerPanRecognizer.maximumNumberOfTouches = 1;
    oneFingerPanRecognizer.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:oneFingerPanRecognizer];
    
    // TODO: pinch and two finger pan
}

- (void)initBall
{
    // place the dots
    // Step1: put all dots at the origin of the backlayer.
    for (NSInteger i = 0; i < [self getNumOfDotsBasedOnDotRadius]; i++) {
        Dot* d = [[Dot layer]initWithFrame:CGRectMake(ballBackLayer.frame.size.width/2 - dotRadius, ballBackLayer.frame.size.height/2 - dotRadius, dotRadius * 2, dotRadius * 2)];
        [ballBackLayer addSublayer:d];
        [d setNeedsDisplay];
    }
    
    // Step2: all dots transform to the top
    for (Dot* d in ballBackLayer.sublayers) {
        d.transform = CATransform3DMakeTranslation(0, 0, BALL_RADIUS); // not sure up is plus or minus
    }
    
    // Step3: all dots rotate transform evenly along x, y axis
    float stepAngle = 0.5; // the step angle must be the same for theta and phi to make sure the dots are tiled evenly
    float theta = 0;
    float phi = 0;
    for (NSInteger i = 0; i < ballBackLayer.sublayers.count; i++) {
        Dot* d = [ballBackLayer.sublayers objectAtIndex:i];
        //            NSLog(@"phi = %f | theta = %f", phi, theta);
        d.transform = CATransform3DConcat(d.transform, CATransform3DMakeRotation(phi, 0, 1, 0));
        d.transform = CATransform3DConcat(d.transform, CATransform3DMakeRotation(theta, 0, 0, 1));
        
        
        theta += stepAngle;
        phi = stepAngle * (floorf(theta / (M_PI*2)) + 1);
    }
}

- (void) handleOneFingerPan: (UIPanGestureRecognizer*) uigr
{
    static CGPoint prevTranslation;
    
    switch (uigr.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [uigr translationInView:self];
            CGPoint newTranslation = CGPointMake(translation.x - prevTranslation.x, translation.y - prevTranslation.y);
            
            float newDistance = sqrtf(powf(newTranslation.x, 2) + powf(newTranslation.y, 2));
            float angle = [self calcRotationAngleFromDistance:newDistance];
            
            [self rotateBallByAngle:angle AxisX:(newTranslation.y * -1) AxisY:newTranslation.x]; // swapped x and y and negate to make it perpendicular to the translation
            
            prevTranslation = translation;
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            prevTranslation = CGPointZero; // don't forget to reset!
            break;
        }
        default:
            break;
    }
}

- (float) calcRotationAngleFromDistance: (float) d
{
    return d/100;
}

- (void) rotateBallByAngle:(float)angle AxisX:(float)x AxisY:(float)y
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    ballBackLayer.transform = CATransform3DConcat(ballBackLayer.transform, CATransform3DMakeRotation(angle, x, y, 0));
    [CATransaction commit];
}

- (NSInteger) getNumOfDotsBasedOnDotRadius
{
    //stub
    return 70;
}

- (float)getScreenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}
                      
- (float)getScreenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
