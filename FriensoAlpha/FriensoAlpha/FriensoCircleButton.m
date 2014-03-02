//
//  FriensoCircleButton.m
//  Frienso
//
//  Created by Sal Aguinaga on 2/23/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FriensoCircleButton.h"

@implementation FriensoCircleButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    UIColor * color = [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:1.0];
    //    CGContextSetFillColorWithColor(context, color.CGColor);
    //    CGContextFillRect(context, self.bounds);
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 1.0);
    CGFloat lineWidth = 2;
    CGRect smallRect = CGRectMake(rect.size.width * .125,
                                  rect.size.width * .125,rect.size.width * 0.75f, rect.size.height * 0.75f);
    
    CGRect borderRect = CGRectInset(smallRect, lineWidth * 0.5, lineWidth * 0.5);
    //CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
    
    CGRect microRect = CGRectMake(rect.size.width * .33,1,10,10);
    CGRect microRect1 = CGRectMake(rect.size.width * .125,
                                  rect.size.width * .125,10,10);
    CGRect microRect2 = CGRectMake(rect.size.width * .125,
                                   rect.size.width * .125,10,10);
    CGRect tinyRect = CGRectInset(microRect, lineWidth * 0.5, lineWidth * 0.5);
    CGContextFillEllipseInRect  (context, tinyRect);
    CGContextStrokeEllipseInRect(context, tinyRect);
    CGContextFillPath(context);

    microRect1.origin = CGPointMake(rect.size.width * 0.6, rect.size.height * .45);
    CGRect tinyRect1 = CGRectInset(microRect1, lineWidth * 0.5, lineWidth * 0.5);
    CGContextFillEllipseInRect  (context, tinyRect1);
    CGContextStrokeEllipseInRect(context, tinyRect1);
    CGContextFillPath(context);
    
    microRect2.origin = CGPointMake(rect.size.width * 0.05, rect.size.height * .45);
    CGRect tinyRect2 = CGRectInset(microRect2, lineWidth * 0.5, lineWidth * 0.5);
    CGContextFillEllipseInRect  (context, tinyRect2);
    CGContextStrokeEllipseInRect(context, tinyRect2);
    CGContextFillPath(context);
}

@end
