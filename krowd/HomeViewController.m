

#import "HomeViewController.h"
#import "PostCell.h"
#import "PostViewController.h"
#import "NetworkClient.h"

@interface HomeViewController ()
{
    UIBarButtonItem *cameraButtonItem;
    BOOL allObjectesLoaded;
    UIImage *image;
}
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToWeekMap;

@end

@implementation HomeViewController

@synthesize following;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;

}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        self.following = NO;
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    allObjectesLoaded = NO;
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setFrame:CGRectMake(0, 0, 29, 20)];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(newPost) forControlEvents:UIControlEventTouchUpInside];
    
    cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
    
    self.navigationItem.rightBarButtonItem = cameraButtonItem;
    
    [self addTableHeader];
    
}


-(UIImageView*)navigationItemTile{
    CGRect frame = CGRectMake(111, 10, 98, 24);
    UIImage *titleImage = [UIImage imageNamed:@"navbar_logo_blue.png"];
    
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:frame];
    titleView.tag = 7;
    [titleView setImage:titleImage];
    
    return titleView;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [self removeTitle];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.navigationController.navigationBar addSubview:[self navigationItemTile]];
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    
    if (!following) {
        [self.tracker set:kGAIScreenName value:@"City Feed"];
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
    else if (following){
        [self.tracker set:kGAIScreenName value:@"Following Feed"];
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
    
    if ([User currentUser]) {
        [self connectToFB];
    }
    [self.notificationCenter addObserver:self selector:@selector(didUploadPhoto:) name:@"PhotoUploadedNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(didFailUploadingImg:) name:@"IMGUploadFailedNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(didFailUploadingPost:) name:@"POSTUploadFailedNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self removeTitle];
    //self.title = @"Back";
}

- (void)didFailUploadingImg:(NSNotification*)notification{
    image = notification.object;
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    background.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(65, 5, 100, 50)];
    header.text = @"Failed";
    header.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    header.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    header.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    header.textAlignment = NSTextAlignmentLeft;
    
    UIButton *retryButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 14, 32, 32)];
    [retryButton setImage:[UIImage imageNamed:@"retryIcon.png"] forState:UIControlStateNormal] ;
    [retryButton addTarget:self action:@selector(retryUploadingImg) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(274, 14, 32, 32)];
    [cancelButton setImage:[UIImage imageNamed:@"crossIcon.png"] forState:UIControlStateNormal] ;
    [cancelButton addTarget:self action:@selector(cancelUpload) forControlEvents:UIControlEventTouchUpInside];
    
    [background addSubview:header];
    [background addSubview:retryButton];
    [background addSubview:cancelButton];
    self.tableView.tableHeaderView = background;
}

- (void)didFailUploadingPost:(NSNotification*)notification{
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    background.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(65, 5, 100, 50)];
    header.text = @"Failed";
    header.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    header.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    header.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    header.textAlignment = NSTextAlignmentLeft;
    
    UIButton *retryButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 14, 32, 32)];
    [retryButton setImage:[UIImage imageNamed:@"retryIcon.png"] forState:UIControlStateNormal] ;
    [retryButton addTarget:self action:@selector(retryUploadingPost) forControlEvents:UIControlEventTouchUpInside];
    [retryButton showsTouchWhenHighlighted];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(274, 14, 32, 32)];
    [cancelButton setImage:[UIImage imageNamed:@"crossIcon.png"] forState:UIControlStateNormal] ;
    [cancelButton addTarget:self action:@selector(cancelUpload) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton showsTouchWhenHighlighted];
    
    [background addSubview:header];
    [background addSubview:retryButton];
    [background addSubview:cancelButton];
    self.tableView.tableHeaderView = background;
}

- (void)retryUploadingImg{

    [[NetworkClient sharedInstance] retryUploadingPhoto];
    self.uploadingPhoto = YES;
    [self addTableHeader];
}

- (void)retryUploadingPost{
    [[NetworkClient sharedInstance] retryUploadingPost];
    self.uploadingPhoto = YES;
    [self addTableHeader];
}

- (void)cancelUpload{
    self.uploadingPhoto = NO;
    [self addTableHeader];
}

- (void)didUploadPhoto:(NSNotification*)notification{
    self.uploadingPhoto = NO;
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    background.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(65, 5, 255, 50)];
    header.text = @"Done";
    header.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    header.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    header.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    header.textAlignment = NSTextAlignmentLeft;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 32, 32)];
    imageView.image = [UIImage imageNamed:@"checkIcon.png"];
    
    [background addSubview:imageView];
    [background addSubview:header];
    self.tableView.tableHeaderView = background;
    
    [self performSelector:@selector(addTableHeader) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(reloadFeed) withObject:nil afterDelay:2.0];
}

- (void)addTableHeader{
    if (self.uploadingPhoto) {
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        background.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 255, 50)];
        header.text = @"Uploading Photo..";
        header.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        header.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
        header.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        header.textAlignment = NSTextAlignmentLeft;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator setFrame:CGRectMake(0, 5, 30, 30)];
        [view addSubview:indicator];
        indicator.hidesWhenStopped = YES;
        [indicator startAnimating];
        [background addSubview:view];
        [background addSubview:header];
        self.tableView.tableHeaderView = background;
    }
    else{
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        background.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238.0/255.0 blue:239.0/255.0 alpha:1.0];
        
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 40)];
        if (!following) {
            header.text = @"Chicago Feed";
        }
        else{
            header.text = @"Following Feed";
        }
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
}


#pragma mark PFTableViewController

- (PFQuery *)queryForTable
{
    if (following) {
        
        PFQuery *innerQuery1 = [PFQuery queryWithClassName:@"FollowUser"];
        [innerQuery1 whereKey:@"follower" equalTo:[User currentUser]];
        
        PFQuery *userPostQuery = [PFQuery queryWithClassName:@"Post"];
        [userPostQuery whereKey:@"user" matchesKey:@"followee" inQuery:innerQuery1];
        if ([User currentUser].currentLocation) {
            [userPostQuery whereKey:@"city" equalTo:[User currentUser].currentLocation];
        }
        userPostQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        
        PFQuery *innerQuery2 = [PFQuery queryWithClassName:@"FollowVenue"];
        [innerQuery2 whereKey:@"user" equalTo:[User currentUser]];

        PFQuery *venuePostQuery = [PFQuery queryWithClassName:@"Post"];
        [venuePostQuery whereKey:@"venue" matchesKey:@"venue" inQuery:innerQuery2];
        if ([User currentUser].currentLocation) {
            [venuePostQuery whereKey:@"city" equalTo:[User currentUser].currentLocation];
        }
        venuePostQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        
        PFQuery *userVenuePostQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userPostQuery,venuePostQuery,nil]];
        userVenuePostQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [userVenuePostQuery orderByDescending:@"createdAt"];
        [userVenuePostQuery includeKey:@"user"];
        [userVenuePostQuery includeKey:@"venue"];
        [userVenuePostQuery includeKey:@"image"];
        
        return userVenuePostQuery;
    }
    else{
        PFQuery *query = [PFQuery queryWithClassName:@"Post"];
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        if ([User currentUser].currentLocation) {
            [query whereKey:@"city" equalTo:[User currentUser].currentLocation];
        }
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"user"];
        [query includeKey:@"venue"];
        [query includeKey:@"image"];
        
         return query;
    }
}

- (void)objectsDidLoad:(NSError *)error{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"LLLL dd"];
    
    [super objectsDidLoad:error];
    if (self.objects.count == 0) {
        allObjectesLoaded = YES;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 320, 40)];
        label.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
        label.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"No Posts";
        label.tag = 101;
        [self.tableView addSubview:label];
    }
    else{
        for (UIView *view in self.tableView.subviews) {
            if (view.tag == 101) {
                [view removeFromSuperview];
            }
        }
        
        //Fill section dictionaries
        self.sections = [[NSMutableDictionary alloc] init];
        self.sectionToWeekMap = [[NSMutableDictionary alloc] init];
        
        NSInteger section = 0;
        NSInteger rowIndex = 0;
        for (int i=0; i<self.objects.count; i++) {
            Post *post = self.objects[i];
            NSString *formattedDate = [[df stringFromDate:(NSDate*)post[@"week"]] capitalizedString];
            NSString *week = [NSString stringWithFormat:@" Week of %@",formattedDate];
            
            NSMutableArray *objectsInSection = self.sections[week];
            if (!objectsInSection) {
                objectsInSection = [NSMutableArray array];
                [self.sectionToWeekMap setObject:week forKey:[NSNumber numberWithInt:section++]];
            }
            [objectsInSection addObject:[NSNumber numberWithInt:rowIndex++]];
            [self.sections setObject:objectsInSection forKey:week];
            
        }
        
        if (self.objects.count %10 != 0) {
            allObjectesLoaded = YES;
        }
    }

    [self.tableView reloadData];
    [self loadImages];
}

#pragma mark tableview delegate

//As this feed uses sections for weeks, i need to add manually "load more" cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    
    //If last section and last element, cell will be "Load More"
    if(indexPath.section == self.sections.allKeys.count-1 && indexPath.row > ((NSArray*)self.sections[[self weekForSection:indexPath.section]]).count-1){
        UITableViewCell *cell = [super tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }

    PostCell* cell = (PostCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath object:object];
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    //Need to implement "Load More" manually
    if(indexPath.section == self.sections.allKeys.count-1 && indexPath.row > ((NSArray*)self.sections[[self weekForSection:indexPath.section]]).count-1){
        [self loadNextPage];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If last section and last element, cell will be "Load More"
    if (indexPath.section == self.sections.allKeys.count-1 && indexPath.row > ((NSArray*)self.sections[[self weekForSection:indexPath.section]]).count-1) {
        return 55;
    }
    else{
        return 430;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *week = [self weekForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:week];
    
    //If last section return one more cell for "Load More"
    if (section == self.sections.allKeys.count - 1 && !allObjectesLoaded) {
        return rowIndecesInSection.count + 1;
    }
    return rowIndecesInSection.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *week = [self weekForSection:section];
    return week;
}

- (NSString *)weekForSection:(NSInteger)section {
    return self.sectionToWeekMap[[NSNumber numberWithInt:section]];
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *week = [self weekForSection:indexPath.section];
    
    NSArray *rowIndecesInSection = self.sections[week];
    
    //If last section and last element, cell will be "Load More"
    if (indexPath.section == self.sections.allKeys.count-1 && indexPath.row > ((NSArray*)self.sections[week]).count-1) {
        return nil;
    }
    else{
        NSNumber *rowIndex = rowIndecesInSection[indexPath.row];
        return self.objects[[rowIndex intValue]];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    label.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    label.textColor = [UIColor colorWithRed:27.0/255.0 green:160.0/255.0 blue:206.0/255.0 alpha:1.0];
    label.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    label.text = [self weekForSection:section];
    label.textAlignment = NSTextAlignmentLeft;
    
    //[label setBackgroundColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}


//Need to override deletePost method from FeedViewController to get correct index of post to delete
- (void)deletePost:(NSNotification*)notification{
    UIActionSheet *popupQuery;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:((PostCell*)notification.object)];
    NSString *week = [self weekForSection:indexPath.section];
    
    NSInteger row = [self.sections[week][indexPath.row] integerValue];
    
    self.postToDelete = [self.objects objectAtIndex:row];
    
    if ([self.postToDelete.user.objectId isEqualToString:[User currentUser].objectId]) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
    }
    else{
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report Inappropriate" otherButtonTitles:nil, nil];
    }
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

- (void)displayLikes:(NSNotification*)notification{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:((PostCell*)notification.object)];
    NSString *week = [self weekForSection:indexPath.section];
    
    NSInteger row = [self.sections[week][indexPath.row] integerValue];
    
    Post *selectedPost = [self.objects objectAtIndex:row];
    
    if ([selectedPost.numberOfLikes integerValue] > 0) {
        [self performSegueWithIdentifier:@"displayLikes" sender:selectedPost];
    }
}

- (void)goToProfile:(NSNotification*)notification{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:((PostCell*)notification.object)];
    NSString *week = [self weekForSection:indexPath.section];
    
    NSInteger row = [self.sections[week][indexPath.row] integerValue];
    
    Post *selectedPost = [self.objects objectAtIndex:row];
    [self performSegueWithIdentifier:@"goToProfile" sender:selectedPost];
}


- (void)goToVenue:(NSNotification*)notification{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:((PostCell*)notification.object)];
    NSString *week = [self weekForSection:indexPath.section];
    
    NSInteger row = [self.sections[week][indexPath.row] integerValue];
    
    Post *selectedPost = [self.objects objectAtIndex:row];
    [self performSegueWithIdentifier:@"goToVenue" sender:selectedPost];
}

- (void)likePost:(NSNotification*)notification{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:((PostCell*)notification.object)];
    NSString *week = [self weekForSection:indexPath.section];
    
    NSInteger row = [self.sections[week][indexPath.row] integerValue];
    
    Post *selectedPost = [self.objects objectAtIndex:row];
    
    if ([selectedPost[@"likeable"] boolValue]) {
        
        //If current user is not in Likes array, add it, and "like" photo
        if (![selectedPost.likes containsObject:[User currentUser].objectId]) {
            [selectedPost.likes addObject:[User currentUser].objectId];
            selectedPost.numberOfLikes = [NSNumber numberWithInt:[selectedPost.likes count]];
            [((PostCell*)notification.object).oLikeButton setTitle:@"UNLIKE" forState:UIControlStateNormal];
            [self.tableView reloadData];
            
            PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
            [postQuery whereKey:@"objectId" equalTo:selectedPost.objectId];
            [postQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [((Post*)object).likes addObject:[User currentUser].objectId];
                ((Post*)object).numberOfLikes = [NSNumber numberWithInt:[((Post*)object).likes count]];
                [object saveInBackground];
            }];
            
        }
        else{  //Else, unlike photo
            [selectedPost.likes removeObject:[User currentUser].objectId];
            selectedPost.numberOfLikes = [NSNumber numberWithInt:[selectedPost.likes count]];
            [((PostCell*)notification.object).oLikeButton setTitle:@"LIKE" forState:UIControlStateNormal];
            [self.tableView reloadData];
            
            PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
            [postQuery whereKey:@"objectId" equalTo:selectedPost.objectId];
            [postQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [((Post*)object).likes removeObject:[User currentUser].objectId];
                ((Post*)object).numberOfLikes = [NSNumber numberWithInt:[((Post*)object).likes count]];
                [object saveInBackground];
            }];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
