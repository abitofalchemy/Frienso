//
//  FRStringImage.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/12/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRStringImage : UIImage
- (UIImage *)imageTextBubbleOfSize:(CGSize)size;       // Size of the desired image.

- (UIImage *)imageWithString:(NSString *)string // What we want an image of.
                        font:(UIFont *)font     // The font we'd like it in.
                        size:(CGSize)size;       // Size of the desired image.
- (UIImage *)imageWithString:(NSString *)string // What we want an image of.
               overlayString:(NSString *)overlayText
                        font:(UIFont *)font     // The font we'd like it in.
                        size:(CGSize)size;
- (UIImage *)calendarDrawRectImage:(CGSize)size;

@end
