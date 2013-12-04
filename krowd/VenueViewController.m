
#import "VenueViewController.h"
#import "UserProfViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "PostViewController.h"
#import "User.h"
#import "Post.h"
#import "PostCell.h"
#import "VenueHeader.h"
#import "OperationSingleton.h"
#import <QuartzCore/QuartzCore.h>

@interface VenueViewController ()
{
    __weak IBOutlet UITableView *oFeedTableView;
    __weak IBOutlet UIBarButtonItem *oRightBarButton;
    UIButton *followButton;
    VenueHeader *header;
    BOOL title;
    BOOL rankingFeed;
    NSMutableArray *trendArray;
}
- (IBAction)didPressedRightBarButton:(id)sender;

@end

@implementation VenueViewController

@synthesize venueToShow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tracker set:kGAIScreenName value:@"Venue Page"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(UIImageView*)navigationItemTile{
    CGRect frame = CGRectMake(111, 10, 98, 24);
    UIImage *titleImage = [UIImage imageNamed:@"navbar_logo_blue.png"];
    
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:frame];
    titleView.tag = 9;
    [titleView setImage:titleImage];
    
    return titleView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [self removeTitle];
    
    [self.navigationController.navigationBar addSubview:[self navigationItemTile]];
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    
    followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [followButton setFrame:CGRectMake(0, 0, 70, 24)];
    [followButton setBackgroundImage:[UIImage imageNamed:@"btn_photo_caption_page_blank.png"] forState:UIControlStateNormal];
    followButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    [followButton setTitleColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [followButton addTarget:self action:@selector(didPressedRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
    followButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:followButton];
    
    [self.notificationCenter addObserver:self selector:@selector(changeFeed) name:@"ChangeFeedNotification" object:nil];
    
    [self buildHeader];
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [self removeTitle];
    //self.title = @"Back";
}

- (void)viewDidAppear:(BOOL)animated{
    if ([self following]) {
        [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
    else{
        [followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    followButton.enabled = YES;
    [self performSelectorInBackground:@selector(fillHeader) withObject:Nil];
}

- (void)buildHeader{

    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VenueHeader" owner:self options:nil];
    header = [nib objectAtIndex:0];
    if (rankingFeed) {
        header.segmentedControl.selectedSegmentIndex = 1;
    }
    else{
        header.segmentedControl.selectedSegmentIndex = 0;
    }
    
    if (((NSString*)self.venueToShow[@"name"]).length > 20){
        
        switch (((NSString*)self.venueToShow[@"name"]).length) {
            case 21:
                header.oNameLabel.font  = [UIFont fontWithName:@"CenturyGothic" size:19.0];
                break;
            case 22:
                header.oNameLabel.font  = [UIFont fontWithName:@"CenturyGothic" size:18.0];
                break;
            default:
                header.oNameLabel.font  = [UIFont fontWithName:@"CenturyGothic" size:17.0];
                break;
        }
    }
    
    header.oNameLabel.text = self.venueToShow[@"name"];
    header.oAddressLabel.text = self.venueToShow[@"location"][@"address"];
    header.oCategoryLabel.text =self.venueToShow[@"categories"][@"name"];
    header.oPhoneLabel.text =self.venueToShow[@"contact"][@"formattedPhone"];
    header.oBackgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    header.oBackgroundView.layer.borderWidth = 0.8f;
    
    self.tableView.tableHeaderView = header;
}

- (void)fillHeader{
    
    PFQuery *followersQuery = [PFQuery queryWithClassName:@"FollowVenue"];
    [followersQuery whereKey:@"venue" equalTo:self.venueToShow];
    
    [followersQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        header.oFollowersLabel.text = [NSString stringWithFormat:@"%i",number];
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"Post"];
    [query2 whereKey:@"venue" equalTo:self.venueToShow];
    [query2 whereKey:@"likeable" equalTo:[NSNumber numberWithBool:true]];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSInteger totalOfLikes = 0;
        for (PFObject *post in objects) {
            totalOfLikes += [((Post*)post).numberOfLikes integerValue];
        }
        
        if (totalOfLikes>999 && totalOfLikes<999999) {
            header.oNumberLikes.text = [NSString stringWithFormat:@"%.2fk",(float)totalOfLikes/1000];
            header.oNumberLikes.font = [UIFont fontWithName:@"CenturyGothic" size:19.0];
        }
        else if (totalOfLikes>99 && totalOfLikes<999){
            header.oNumberLikes.text = [NSString stringWithFormat:@"%i",totalOfLikes];
            header.oNumberLikes.font = [UIFont fontWithName:@"CenturyGothic" size:24.0];
        }
        else{
            header.oNumberLikes.text = [NSString stringWithFormat:@"%i",totalOfLikes];
            header.oNumberLikes.font = [UIFont fontWithName:@"CenturyGothic" size:28.0];
        }
    }];

}


#pragma mark PFTableViewController

- (PFQuery *)queryForTable
{
    if (rankingFeed) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query orderByDescending:@"numberOfLikes"];
        [query whereKey:@"likeable" equalTo:[NSNumber numberWithBool:true]];
        [query whereKey:@"numberOfLikes" greaterThan:@0];
        [query whereKey:@"venue" equalTo:self.venueToShow];
        [query includeKey:@"user"];
        [query includeKey:@"venue"];
        [query includeKey:@"image"];
        //query.limit = 10;
        return query;
    }
    else{
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"user"];
        [query includeKey:@"venue"];
        [query includeKey:@"image"];
        [query whereKey:@"venue" equalTo:self.venueToShow];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        
        return query;
    }
}

- (PFObject*)following{
    PFQuery *query = [PFQuery queryWithClassName:@"FollowVenue"];
    [query whereKey:@"venue" equalTo:self.venueToShow];
    [query whereKey:@"user" equalTo:[User currentUser]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    PFObject *object = [query getFirstObject];
    if (object) {
        return object;
    }

    return nil;
}


- (void)changeFeed{
    if (rankingFeed) {
        rankingFeed = NO;
    }
    else{
        rankingFeed = YES;
    }
    [self loadObjects];
    
}

- (void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad:error];
    if (self.objects.count == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(130, 180, 80, 40)];
        label.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
        label.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
        label.text = @"No posts";
        label.tag = 101;
       // [self.tableView addSubview:label];
    }
    else{
        for (UIView *view in self.tableView.subviews) {
            if (view.tag == 101) {
                [view removeFromSuperview];
            }
        }
    }
    [self loadImages];
}


- (IBAction)didPressedRightBarButton:(id)sender {
    if ([oRightBarButton.title isEqualToString:@"Log Out"]) {
        [User logOut];
        [self performSegueWithIdentifier:@"login" sender:self];
    }
    else{ //Follow
        PFObject *follow = [self following];
        if (follow) {
            [followButton setTitle:@"Follow" forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:followButton];
            [follow deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    header.oFollowersLabel.text = [NSString stringWithFormat:@"%i",[header.oFollowersLabel.text intValue] -1];
            } ];
        }
        else{
            [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:followButton];
            PFObject *follow = [PFObject objectWithClassName:@"FollowVenue"];
            [follow setObject:self.venueToShow forKey:@"venue"];
            [follow setObject:[User currentUser] forKey:@"user"];
            [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                header.oFollowersLabel.text = [NSString stringWithFormat:@"%i",[header.oFollowersLabel.text intValue] +1];
                
            }];
        }
        
    }
}

#pragma mark UITableViewDataSource


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Posts";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
    label.font = [UIFont fontWithName:@"CenturyGothic" size:28.0];
    label.textColor = [UIColor colorWithRed:27.0/255.0 green:160.0/255.0 blue:206.0/255.0 alpha:1.0];
    label.text = @"POSTS";
    [label setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:238.0/255.0 blue:239.0/255.0 alpha:1.0]];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:238.0/255.0 blue:239.0/255.0 alpha:1.0]];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}


- (void)goToVenue:(NSNotification*)notification{
}


- (void)goToProfile:(NSNotification*)notification{
    UserProfViewController *userViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    
    Post *selectedPost = [self.objects objectAtIndex:[self.tableView indexPathForCell:((PostCell*)notification.object)].row];
    
    userViewController.userToShow = [selectedPost objectForKey:@"user"];
    [self.navigationController pushViewController:userViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
