//
//  FRStringImage.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/12/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FRStringImage.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation FRStringImage
- (UIImage *)calendarDrawRectImage:(CGSize)size
{
    // Create a context to render into.
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 1.0);
    
    CGContextMoveToPoint(context, 0,size.height*.25); //start at this point
    CGContextAddLineToPoint(context, size.width, size.height*.25); //draw to this point
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(context, size.width*0.2, 0);
    
    CGContextAddLineToPoint(context, size.width*0.9, 0);
    CGContextAddArc(context, size.width*0.80, size.height*.2, size.height*.2,M_PI*1.5,0,NO);
    CGContextAddLineToPoint(context, size.width, size.height*0.80);
    CGContextAddArc(context, size.width*0.80, size.height*0.8, size.height*.2,0,M_PI/2.0,NO);
    CGContextAddLineToPoint(context, size.width*0.2, size.width);
    CGContextAddArc(context, size.width*0.2, size.height*0.80, size.height*.2,M_PI/2.0,M_PI,NO);
    CGContextAddLineToPoint(context, 0, size.height*0.2);
    CGContextAddArc(context, size.width*0.2, size.height*0.2, size.height*.2,M_PI,M_PI*1.5,NO);
    
    // and now draw the Path!
    CGContextStrokePath(context);
    
    
    
    // setting the date
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat:@"dd"];
    //[weekday setLocale:NSLocale];
    NSString * dateString = [weekday stringFromDate:now];
    
    UIFont*       font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16];
    UIColor* textColor = [UIColor redColor];
    NSDictionary* stringAttrs = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: textColor };
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:dateString
                                                                  attributes:stringAttrs];
    CGFloat txtX = (size.width - attrStr.size.width)/2;
    [attrStr drawAtPoint:CGPointMake(txtX, 7.0f)];
    
    // We're done!  Grab the image and return it!
    // (Don't forget to end the image context first though!)
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

- (UIImage *)imageTextBubbleOfSize:(CGSize)size       // Size of the desired image.
{
    // Create a context to render into.
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext(); // get a reference to the context
    //UIColor * color = [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:1.0];
    CGContextSetFillColorWithColor(context, UIColorFromRGB(0x9B90C8).CGColor);
    
    // Circle
    //CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor); // set the fill color of the context
    // make circle rect 5 px from border
    CGRect circleRect = CGRectMake(0, 0,
                                   size.width,
                                   size.height);
    circleRect = CGRectInset(circleRect, 5, 5);
    CGContextFillEllipseInRect(context, circleRect);
    
    // We're done!  Grab the image and return it!
    // (Don't forget to end the image context first though!)
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}
- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width < image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
//- (void)drawRect:(CGRect)rect {
//    // Make sure the UIView's background is set to clear either in code or in a storyboard/nib
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    [[UIColor whiteColor] setFill];
//    CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect)/2, 0, 2*M_PI, YES);
//    CGContextFillPath(context);
//    
//    // Manual offset may need to be adjusted depending on the length of the text
//    [self drawSubtractedText:@"Foo" inRect:rect inContext:context];
//}
//
//- (void)drawSubtractedText:(NSString *)text inRect:(CGRect)rect inContext:(CGContextRef)context {
//    // Save context state to not affect other drawing operations
//    CGContextSaveGState(context);
//    
//    // Magic blend mode
//    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
//    
//    // This seemingly random value adjusts the text
//    // vertically so that it is centered in the circle.
//    CGFloat Y_OFFSET = -2 * (float)[text length] + 5;
//    
//    // Context translation for label
//    CGFloat LABEL_SIDE = CGRectGetWidth(rect);
//    CGContextTranslateCTM(context, 0, CGRectGetHeight(rect)/2-LABEL_SIDE/2+Y_OFFSET);
//    
//    // Label to center and adjust font automatically
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LABEL_SIDE, LABEL_SIDE)];
//    label.font = [UIFont boldSystemFontOfSize:120];
//    label.adjustsFontSizeToFitWidth = YES;
//    label.text = text;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor clearColor];
//    [label.layer drawInContext:context];
//    
//    // Restore the state of other drawing operations
//    CGContextRestoreGState(context);
//}
- (UIImage *)imageWithString:(NSString *)string // What we want an image of.
                        font:(UIFont *)font     // The font we'd like it in.
                        size:(CGSize)size       // Size of the desired image.
{
    // Create a context to render into.
    UIGraphicsBeginImageContext(size);
    
    // Work out what size of font will give us a rendering of the string
    // that will fit in an image of the desired size.
    
    // We do this by measuring the string at the given font size and working
    // out the ratio scale to it by to get the desired size of image.
    NSDictionary *attributes = @{NSFontAttributeName:font};
    // Measure the string size.
    CGSize stringSize = [string sizeWithAttributes:attributes];
    
    // Work out what it should be scaled by to get the desired size.
    CGFloat xRatio = size.width / stringSize.width;
    CGFloat yRatio = size.height / stringSize.height;
    CGFloat ratio = MIN(xRatio, yRatio);
    
    // Work out the point size that'll give us the desired image size, and
    // create a UIFont that size.
    CGFloat oldFontSize = font.pointSize;
    CGFloat newFontSize = floor(oldFontSize * ratio);
    ratio = newFontSize / oldFontSize;
    font = [font fontWithSize:newFontSize];
    
    // What size is the string with this new font?
    stringSize = [string sizeWithAttributes:attributes];
    
    // Work out where the origin of the drawn string should be to get it in
    // the centre of the image.
    CGPoint textOrigin = CGPointMake((size.width - stringSize.width) / 2,
                                     (size.height - stringSize.height) / 2);
    
    // Draw the string into out image!
    [string drawAtPoint:textOrigin withAttributes:attributes];
    
    // Circle
    CGContextRef context = UIGraphicsGetCurrentContext(); // get a reference to the context
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor); // set the fill color of the context
    // make circle rect 5 px from border
    CGRect circleRect = CGRectMake(0, 0,
                                   size.width,
                                   size.height);
    circleRect = CGRectInset(circleRect, 5, 5);
    CGContextStrokeEllipseInRect(context, circleRect);
    
    // We're done!  Grab the image and return it!
    // (Don't forget to end the image context first though!)
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}
- (UIImage *)imageWithString:(NSString *)string // What we want an image of.
               overlayString:(NSString *)overlayText
                        font:(UIFont *)font     // The font we'd like it in.
                        size:(CGSize)size       // Size of the desired image.
{
    // Create a context to render into.
    UIGraphicsBeginImageContext(size);
    
    // Work out what size of font will give us a rendering of the string
    // that will fit in an image of the desired size.
    
    // We do this by measuring the string at the given font size and working
    // out the ratio scale to it by to get the desired size of image.
    NSDictionary *attributes = @{NSFontAttributeName:font};
    // Measure the string size.
    CGSize stringSize = [string sizeWithAttributes:attributes];
    
    // Work out what it should be scaled by to get the desired size.
    CGFloat xRatio = size.width / stringSize.width;
    CGFloat yRatio = size.height / stringSize.height;
    CGFloat ratio = MIN(xRatio, yRatio);
    
    // Work out the point size that'll give us the desired image size, and
    // create a UIFont that size.
    CGFloat oldFontSize = font.pointSize;
    CGFloat newFontSize = floor(oldFontSize * ratio);
    ratio = newFontSize / oldFontSize;
    font = [font fontWithSize:newFontSize];
    
    // What size is the string with this new font?
    stringSize = [string sizeWithAttributes:attributes];
    
    // Work out where the origin of the drawn string should be to get it in
    // the centre of the image.
    CGPoint textOrigin = CGPointMake((size.width - stringSize.width) / 2,
                                     (size.height - stringSize.height) / 2);
    
    // Draw the string into out image!
    [string drawAtPoint:textOrigin withAttributes:attributes];
    
    // Circle
    CGContextRef context = UIGraphicsGetCurrentContext(); // get a reference to the context
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor); // set the fill color of the context
    // make circle rect 5 px from border
    CGRect circleRect = CGRectMake(0, 0,
                                   size.width,
                                   size.height);
    circleRect = CGRectInset(circleRect, 5, 5);
    CGContextStrokeEllipseInRect(context, circleRect);
    // We're done!  Grab the image and return it!
    // (Don't forget to end the image context first though!)
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

@end
