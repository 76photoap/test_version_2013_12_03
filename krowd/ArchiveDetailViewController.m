//
//  WallDetailViewController.m
//  krowd
//
//  Created by Julie Caccavo on 9/25/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "ArchiveDetailViewController.h"
#import "UserProfViewController.h"

@interface ArchiveDetailViewController ()
{
}
@end

@implementation ArchiveDetailViewController

@synthesize detailItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self removeTitle];
    self.tableView.scrollEnabled = NO;
    self.title = @"PHOTO";
}

- (void)viewWillDisappear:(BOOL)animated{
    [self removeTitle];
    //self.title = @"Back";
}

- (void)removeTitle{
    for (UIView* view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[UIImageView class]] && (view.tag == 9 || view.tag == 7)) {
            [view removeFromSuperview];
        }
    }
}
#pragma mark PFTableViewController

- (PFQuery *)queryForTable
{
    PFQuery *query1 = [PFQuery queryWithClassName:@"Post"];
    [query1 whereKey:@"objectId" equalTo:self.detailItem[@"id"]];
    [query1 includeKey:@"user"];
    [query1 includeKey:@"venue"];
    [query1 includeKey:@"image"];

    return query1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (screenSize.height > 480.0f) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        /* Create custom view to display section header... */
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        label.font = [UIFont fontWithName:@"CenturyGothic" size:28.0];
        label.textColor = [UIColor colorWithRed:27.0/255.0 green:160.0/255.0 blue:206.0/255.0 alpha:1.0];
        [label setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:238.0/255.0 blue:239.0/255.0 alpha:1.0]];
        [view addSubview:label];
        [view setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:238.0/255.0 blue:239.0/255.0 alpha:1.0]];
        return view;
    }
    
    return nil;

}

- (void)goToProfile:(NSNotification*)notification{
    Post *selectedPost = [self.objects lastObject];
    UserProfViewController *userViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    userViewController.userToShow = [selectedPost objectForKey:@"user"];
    [self.navigationController pushViewController:userViewController animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (screenSize.height > 480.0f) {
        return 50;
    }
    return 0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
