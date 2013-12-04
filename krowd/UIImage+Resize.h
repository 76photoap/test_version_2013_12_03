//
//  UIImage+Resize.h
//  krowd
//
//  Created by Julie Caccavo on 8/14/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize cropSides:(BOOL)cameraPhoto profilePic:(BOOL)profilePic;

@end
