

#import "TrendingPostsViewController.h"
#import "LoginViewController.h"
#import "UserProfViewController.h"
#import "User.h"
#import "Post.h"
#import "PostCell.h"
#import "OperationSingleton.h"

@interface TrendingPostsViewController ()
{
    NSNotificationCenter *notificationCenter;
    UIBarButtonItem *cameraButtonItem;
    NSMutableData *imageData;
    NSString *trendingType;
    CLLocationManager *locationManager;
}
@end

@implementation TrendingPostsViewController

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
        // The className to query on
        self.parseClassName = @"Post";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"caption";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tracker set:kGAIScreenName value:@"Trending Photos"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (![User currentUser] || ![PFFacebookUtils isLinkedWithUser:[User currentUser]] || [[User currentUser].username isEqualToString:[NSString stringWithFormat:@"%@",[User currentUser][@"profile"][@"facebookId"]]] || ![[User currentUser][@"hasUsername"] boolValue]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setFrame:CGRectMake(0, 0, 29, 20)];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(newPost) forControlEvents:UIControlEventTouchUpInside];
    
    cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
    
    self.navigationItem.rightBarButtonItem = cameraButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    self.navigationItem.rightBarButtonItem.enabled = YES;

    [self removeTitle];
    [self addTableHeader];
    [self.navigationController.navigationBar addSubview:[self navigationItemTile]];
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    //self.title = @"TRENDING PHOTOS";
}

- (void)viewWillDisappear:(BOOL)animated{
    [self removeTitle];
    //self.title = @"Back";
}

-(UIImageView*)navigationItemTile{
    CGRect frame = CGRectMake(111, 10, 98, 24);
    UIImage *titleImage = [UIImage imageNamed:@"navbar_logo_blue.png"];
    
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:frame];
    titleView.tag = 7;
    [titleView setImage:titleImage];
    
    return titleView;
}

- (void)addTableHeader{
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    background.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238.0/255.0 blue:239.0/255.0 alpha:1.0];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 40)];
    header.text = @"Trending Photos";
    header.backgroundColor = [UIColor whiteColor];
    header.layer.borderColor = [[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] CGColor];
    header.layer.borderWidth = 1.0;
    //colorWithRed:240.0/255.0 green:238.0/255.0 blue:239.0/255.0 alpha:1.0];
    header.font = [UIFont fontWithName:@"CenturyGothic" size:22.0];
    header.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    header.textAlignment = NSTextAlignmentCenter;
    
    [background addSubview:header];
    self.tableView.tableHeaderView = background;
}

- (void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad:error];
    if (self.objects.count == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 320, 40)];
        label.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
        label.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
        label.tag = 101;
        label.textAlignment = NSTextAlignmentCenter;
        [self.tableView addSubview:label];
        if ([[User currentUser].currentLocation isEqualToString:@"Chicago, IL"]) {
            label.text = @"Krowdx competition has been reset!";
        }
        else{
            label.text = @"No posts in your city yet!";
        }
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


#pragma mark PFTableViewController

- (PFQuery *)queryForTable
{
    trendingType = @"Posts";
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    if ([trendingType isEqualToString:@"Posts"]) {
        [query orderByDescending:@"numberOfLikes"];
    }
    [query whereKey:@"likeable" equalTo:[NSNumber numberWithBool:true]];
    [query whereKey:@"numberOfLikes" greaterThan:@0];
    if ([User currentUser]) {
        if ([User currentUser].currentLocation) {
            [query whereKey:@"city" equalTo:[User currentUser].currentLocation];
        }
        else{
            [User currentUser].currentLocation = @"Chicago, IL";
        }
    }
    [query includeKey:@"user"];
    [query includeKey:@"venue"];
    [query includeKey:@"image"];

    //query.limit = 10;
    return query;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    BOOL hasRankingLabel = NO;
    PostCell* cell = (PostCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath object:object];
    
    for (UIView* view in cell.oPostImageView.subviews) {
        if (view.tag == 337) {
            ((UILabel*)[view.subviews lastObject]).text = [NSString stringWithFormat:@"#%i",indexPath.row + 1];
            hasRankingLabel = YES;
        }
    }
    
    if (!hasRankingLabel) {
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(5,5,80,45)];
        backgroundView.backgroundColor = [UIColor grayColor];
        backgroundView.alpha = 0.65;
        backgroundView.opaque = NO;
        backgroundView.tag = 337;
        [backgroundView.layer setCornerRadius:10.0];
        
        UILabel *rankingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 45)];
        rankingLabel.textColor = [UIColor whiteColor];
        rankingLabel.font = [UIFont fontWithName:@"CenturyGothic" size:35.0];
        rankingLabel.textAlignment = NSTextAlignmentCenter;
        rankingLabel.backgroundColor = [UIColor clearColor];
        rankingLabel.text = [NSString stringWithFormat:@"#%i",indexPath.row + 1];
        
        [backgroundView addSubview:rankingLabel];
        [cell.oPostImageView addSubview:backgroundView];
    }

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"login"]) {
        LoginViewController *loginController = segue.destinationViewController;
        loginController.firstLogin = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

