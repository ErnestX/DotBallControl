//
//  Dot.m
//  DotBallControl
//
//  Created by Jialiang Xiang on 2015-05-14.
//  Copyright (c) 2015 Jialiang. All rights reserved.
//

#import "Dot.h"

@implementation Dot {
    float width;
    float height;
}

- (Dot*)initWithFrame:(CGRect)f
{
    self.frame = f;
    width = f.size.width;
    height = f.size.height;
    
    self.doubleSided = NO;
//    self.backgroundColor = [UIColor redColor].CGColor;
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    [self setContentsScale:[UIScreen mainScreen].scale];
    
    UIGraphicsPushContext(ctx);
    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, width, height));//self.frame.size.width, self.frame.size.height));
    
    UIGraphicsPopContext();
}

@end
