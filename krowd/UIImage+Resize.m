//
//  UIImage+Resize.m
//  krowd
//
//  Created by Julie Caccavo on 8/14/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "UIImage+Resize.h"
//#import "UIImage+RoundedCorner.h"
//#import "UIImage+Alpha.h"

@implementation UIImage (Resize)


- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize cropSides:(BOOL)cropSides profilePic:(BOOL)profilePic{
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.height / image.size.height;
        delta = ((ratio*image.size.height) - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
        
    }
    CGRect clipRect;
    if (profilePic || cropSides) {
        //make the final clipping rect based on the calculated values
         clipRect = CGRectMake(-offset.x, -offset.y,(ratio * image.size.width) + delta,
                                     (ratio * image.size.height) + delta );
    }
    else{
        clipRect = CGRectMake(-offset.x, -offset.y-20,(ratio * image.size.width) + delta,
                              (ratio * image.size.height) + delta );
    }
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    if (cropSides) {
        //After making it square, I need to crop the sides, cause the camera is showing
        //less on the sides than what the picture actually has.
        
        CGSize sz2 = CGSizeMake(400, 400);
        CGRect clipRect2 = CGRectMake(-21, -21,newImage.size.width,newImage.size.height);
        
        
        //start a new context, with scale factor 0.0 so retina displays get
        //high quality image
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            UIGraphicsBeginImageContextWithOptions(sz2, YES, 0.0);
        } else {
            UIGraphicsBeginImageContext(sz2);
        }
        UIRectClip(clipRect2);
        [newImage drawInRect:clipRect2];
        UIImage *newImage2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage2;
    }

    return newImage;

}
@end
