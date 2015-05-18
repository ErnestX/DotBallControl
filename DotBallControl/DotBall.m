//
//  DotBall.m
//  DotBallControl
//
//  Created by Jialiang Xiang on 2015-05-14.
//  Copyright (c) 2015 Jialiang. All rights reserved.
//

#import "POP.h"
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
        
        [self initGestureRecognizers];
        [self initBall];
        
        // add outline layer
        CAShapeLayer* outline = [CAShapeLayer layer];
        outline.frame = CGRectMake([self getScreenWidth]/2 - BALL_RADIUS, [self getScreenHeight]/2 - BALL_RADIUS, BALL_RADIUS, BALL_RADIUS);
        outline.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*BALL_RADIUS, 2.0*BALL_RADIUS) cornerRadius:BALL_RADIUS].CGPath;
        outline.fillColor = [UIColor clearColor].CGColor;
        outline.strokeColor = [UIColor blackColor].CGColor;
        outline.lineWidth = 5;
        [self.layer addSublayer:outline];
        
        // TODO: add alpha mask
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
    // add back transform layer
    ballBackLayer = [CATransformLayer layer];
    ballBackLayer.frame = CGRectMake([self getScreenWidth]/2 - BALL_RADIUS, [self getScreenHeight]/2 - BALL_RADIUS, BALL_RADIUS * 2, BALL_RADIUS * 2);
    [self.layer addSublayer:ballBackLayer];
    
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
    float stepAngle = M_PI / 6;
    float theta = 0;
    float phi = 0;
    for (NSInteger i = 0; i < ballBackLayer.sublayers.count; i++) {
        Dot* d = [ballBackLayer.sublayers objectAtIndex:i];
        NSLog(@"phi = %f | theta = %f", phi, theta);
        d.transform = CATransform3DConcat(d.transform, CATransform3DMakeRotation(phi, 0, 1, 0));
        d.transform = CATransform3DConcat(d.transform, CATransform3DMakeRotation(theta, 0, 0, 1));
        
        //NSInteger numOfDotForThisLevel = roundf((M_PI*2)/(fabs(phi - M_PI/2.0) * 4));
        //NSInteger numOfDotForThisLevel = roundf((M_PI * 2) / (cos(phi * 2) + 1.3));
        NSInteger numOfDotForThisLevel = roundf((M_PI*2)/(fabs(phi - M_PI/2.0)/2));
        theta += stepAngle + M_PI * 2 / numOfDotForThisLevel;
        phi = stepAngle * (floorf(theta / (M_PI*2)) + 1);
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // interrupt ongoing rotation
    [self pop_removeAnimationForKey:@"momentum_rotation"];
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
            
            [self rotateBallNotAnimatedByAngle:angle AxisX:(newTranslation.y * -1) AxisY:newTranslation.x]; // swapped x and y and negate one of them to make it perpendicular to the translation
            
            prevTranslation = translation;
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            prevTranslation = CGPointZero; // don't forget to reset!
            
            // decay animation
            __block CGPoint v = [uigr velocityInView:self];

            v = CGPointMake(v.x / 30, v.y / 30); // translate distance per time unit to distance per frame
            POPCustomAnimation *customAnimation = [POPCustomAnimation animationWithBlock:^BOOL(id obj, POPCustomAnimation *animation) {
                float angle = [self calcRotationAngleFromDistance:sqrtf(powf(v.x, 2) + powf(v.y, 2))];
                [self rotateBallAnimatedByAngle:angle AxisX:(v.y * -1) AxisY:v.x];
                
                v = CGPointMake(v.x * 0.97, v.y * 0.97); // exponential decay
                
                if (fabsf(angle) < 0.001) { // min rotate speed
                    return NO;
                } else {
                    return YES;
                }
            }];
                                                   
            [self pop_addAnimation:customAnimation forKey:@"momentum_rotation"];
            break;
        }
        default:
            break;
    }
}

- (float) calcRotationAngleFromDistance: (float) d
{
    return d / (2 * BALL_RADIUS) * M_PI; // rotate 180 if pan through the diameter
}

- (void) rotateBallAnimatedByAngle:(float)angle AxisX:(float)x AxisY:(float)y
{
    ballBackLayer.transform = CATransform3DConcat(ballBackLayer.transform, CATransform3DMakeRotation(angle, x, y, 0));
}

- (void) rotateBallNotAnimatedByAngle:(float)angle AxisX:(float)x AxisY:(float)y
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self rotateBallAnimatedByAngle:angle AxisX:x AxisY:y];
    [CATransaction commit];
}

- (NSInteger) getNumOfDotsBasedOnDotRadius
{
    //stub
    return 41;
}

- (float)getScreenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}
                      
- (float)getScreenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

@end
