//
//  InnapropriateReportView.h
//  krowd
//
//  Created by Julie Caccavo on 9/23/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DidSendReportDelegate.h"
#import "Post.h"

@interface InnapropriateReportView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic)Post *post;
@property (strong, nonatomic)id<DidSendReportDelegate>delegate;

@end
