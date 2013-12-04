//
//  SignUpViewController.h
//  krowd
//
//  Created by Julie Caccavo on 10/15/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SignUpDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h" 

@interface SignUpViewController : UIViewController <UIGestureRecognizerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic)id <SignUpDelegate> delegate;
@property (strong, nonatomic) id tracker;

@end
