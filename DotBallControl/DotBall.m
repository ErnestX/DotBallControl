//
//  DotBall.m
//  DotBallControl
//
//  Created by Jialiang Xiang on 2015-05-14.
//  Copyright (c) 2015 Jialiang. All rights reserved.
//

#import "DotBall.h"
#import "Dot.h"

#define BALL_RADIUS 200.0

@implementation DotBall {
    float dotRadius;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        dotRadius = 20;
        NSLog(@"screen height: %f", [self getScreenHeight]);
        // place the dots
        
        // Step1: put all dots at the origin.
        for (NSInteger i = 0; i < 10; i++) {
            Dot* d = [[Dot layer]initWithFrame:CGRectMake([self getScreenWidth]/2 - dotRadius, [self getScreenHeight]/2 - dotRadius, dotRadius * 2, dotRadius * 2)];
            [self.layer addSublayer:d];
            [d setNeedsDisplay];
        }
        
        // Step2: all dots transform to the top
        for (Dot* d in self.layer.sublayers) {
            d.transform = CATransform3DMakeTranslation(0, BALL_RADIUS, 0); // not sure up is plus or minus
        }
        
        // Step3: all dots transform evenly along x axis
        float theta = 0;
        for (Dot* d in self.layer.sublayers) {
            
            d.transform = CATransform3DConcat(d.transform, CATransform3DMakeRotation(theta, 1, 0, 0));
            
            theta += M_PI * 2 / self.layer.sublayers.count;
        }
        
    }
    
    return self;
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
