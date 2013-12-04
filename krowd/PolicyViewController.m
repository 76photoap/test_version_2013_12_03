//
//  PolicyViewController.m
//  krowd
//
//  Created by Julie Caccavo on 10/10/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "PolicyViewController.h"

@interface PolicyViewController ()
{
    UIWebView *oWebView;
    __weak IBOutlet UIBarButtonItem *oBackButton;
    __weak IBOutlet UINavigationBar *oNavBar;
    
}
- (IBAction)goBack:(id)sender;

@end

@implementation PolicyViewController

@synthesize type;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    int y;
    
    oWebView = [[UIWebView alloc] init];
    oWebView.delegate = self;
    oWebView.scrollView.bounces = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        y = 20;
    }
    else{
        y = 0;
    }
    
    
    if ([type isEqualToString:@"TermsOfService"]) {
        oNavBar.topItem.title = @"";
        self.title = @"SETTINGS";
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44+ y, 310, 40)];
        titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
        titleLabel.text = @"Terms Of Service";
        [self.view addSubview:titleLabel];
        
        oWebView.frame = CGRectMake(0, 84 + y, 320, [[UIScreen mainScreen] bounds].size.height-84-y);
        [self.view addSubview:oWebView];
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *indexFileURL = [bundle URLForResource:@"TermsOfService" withExtension:@"html"];
        [oWebView loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
    }
    else if ([type isEqualToString:@"TermsOfService2"]) {
        oNavBar.topItem.title = @"Terms Of Service";
        self.title = @"Terms Of Service";
        oWebView.frame = CGRectMake(0, 44 + y, 320, [[UIScreen mainScreen] bounds].size.height-44-y);
        [self.view addSubview:oWebView];
        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *indexFileURL = [bundle URLForResource:@"TermsOfService" withExtension:@"html"];
        [oWebView loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
    }
    else if ([type isEqualToString:@"PrivacyPolicy"]) {
        oNavBar.topItem.title = @"";
        self.title = @"SETTINGS";
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44+ y, 310, 40)];
        titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
        titleLabel.text = @"Privacy Policy";
        [self.view addSubview:titleLabel];
        
        oWebView.frame = CGRectMake(0, 84 + y, 320, [[UIScreen mainScreen] bounds].size.height-84-y);
        [self.view addSubview:oWebView];
        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *indexFileURL = [bundle URLForResource:@"PrivacyPolicy" withExtension:@"html"];
        [oWebView loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
    }
    else{
        oNavBar.topItem.title = @"Privacy Policy";
        self.title = @"Privacy Policy";
        oWebView.frame = CGRectMake(0, 44 + y, 320, [[UIScreen mainScreen] bounds].size.height-44-y);
        [self.view addSubview:oWebView];
        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *indexFileURL = [bundle URLForResource:@"PrivacyPolicy" withExtension:@"html"];
        [oWebView loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
    }

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
