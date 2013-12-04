//
//  PostPhotoDelegate.h
//  krowd
//
//  Created by Julie Caccavo on 9/15/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PostPhotoDelegate <NSObject>

- (void)didTakePhoto:(UIImage*)image;
- (void)didCancelPhoto;

@end
