//
//  FRUserGenContentButton.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/7/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FRUserGenContentButton.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation FRUserGenContentButton

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
     
     //CGContextRef context = UIGraphicsGetCurrentContext();
     CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0x006bb6).CGColor);
     
     // Draw them with a 2.0 stroke width so they are a bit more visible.
     CGContextSetLineWidth(context, 2.0);
     
     
     CGContextMoveToPoint(context, 4,9); //start at this point
     CGContextAddLineToPoint(context, 23, 9); //draw to this point
     
     CGContextMoveToPoint(context, 4,13.5); //start at this point
     CGContextAddLineToPoint(context, 23, 13.5); //draw to this point
     
     CGContextMoveToPoint(context, 4,18); //start at this point
     CGContextAddLineToPoint(context, 23, 18); //draw to this point
     
     // and now draw the Path!
     CGContextStrokePath(context);
 }
@end
