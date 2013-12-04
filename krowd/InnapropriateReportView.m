//
//  InnapropriateReportView.m
//  krowd
//
//  Created by Julie Caccavo on 9/23/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "InnapropriateReportView.h"

@interface InnapropriateReportView ()
{
    
    __weak IBOutlet UILabel *oTitleLabel;
    __weak IBOutlet UIButton *oSendButton;
    __weak IBOutlet UIPickerView *oPickerView;
    __weak IBOutlet UIButton *oCancelButton;
    __weak IBOutlet UIView *oBackgroundView;
    NSArray *optionsArray;
}
- (IBAction)sendReport:(id)sender;
- (IBAction)cancelReport:(id)sender;

@end

@implementation InnapropriateReportView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib{
    optionsArray = @[@"I don't like this photo",@"This post is spam",@"This shouldn't be on Krowdx"];
    oSendButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:15.0];
    [oSendButton setTitle:@"SEND" forState:UIControlStateNormal];
    oCancelButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:15.0];
    [oCancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    oTitleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:24.0];
    
    oPickerView.showsSelectionIndicator = YES;
    oPickerView.dataSource = self;
    oPickerView.delegate = self;
    

    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.alpha = 0.95;
    }
    else{
        self.alpha = 0.9;
        oBackgroundView.alpha = 0.97;

    }

}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [optionsArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [optionsArray objectAtIndex:row];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)sendReport:(id)sender {
    PFObject *reportObject = [PFObject objectWithClassName:@"InnapropriateReport"];
    reportObject[@"post"] = self.post;
    reportObject[@"user"] = [User currentUser];
    reportObject[@"reason"] = optionsArray[[oPickerView selectedRowInComponent:0]];
    reportObject[@"reviewed"] = [NSNumber numberWithBool:NO];
    [reportObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self removeFromSuperview];
        [self.delegate didSendReport];
    }];

    
}

- (IBAction)cancelReport:(id)sender {
    [self removeFromSuperview];
    [self.delegate didSendReport];
}
@end
