//
//  CameraViewController.h
//  krowd
//
//  Created by Julie Caccavo on 9/15/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostPhotoDelegate.h"

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic)id <PostPhotoDelegate> delegate;

@end
