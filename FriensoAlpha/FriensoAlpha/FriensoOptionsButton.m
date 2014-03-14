//
//  FriensoOptionsButton.m
//  Frienso
//
//  Created by Sal Aguinaga on 2/23/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FriensoOptionsButton.h"

@implementation FriensoOptionsButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
//        _hue = 0.5;
//        _saturation = 0.5;
//        _brightness = 0.5;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 1.5);
    

    
    CGContextMoveToPoint(context, 4,9); //start at this point
    CGContextAddLineToPoint(context, 23, 9); //draw to this point
    
    CGContextMoveToPoint(context, 4,13.5); //start at this point
    CGContextAddLineToPoint(context, 23, 13.5); //draw to this point
    
    CGContextMoveToPoint(context, 4,18); //start at this point
    CGContextAddLineToPoint(context, 23, 18); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}
//-(void) setHue:(CGFloat)hue
//{
//    _hue = hue;
//    [self setNeedsDisplay];
//}
//
//-(void) setSaturation:(CGFloat)saturation
//{
//    _saturation = saturation;
//    [self setNeedsDisplay];
//}
//
//-(void) setBrightness:(CGFloat)brightness
//{
//    _brightness = brightness;
//    [self setNeedsDisplay];
//}
@end
