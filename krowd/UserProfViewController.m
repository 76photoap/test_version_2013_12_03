
#import "UserProfViewController.h"
#import "UserContainerTableCell.h"
#import "UserContainerCellView.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "PostViewController.h"
#import "User.h"
#import "Post.h"
#import "PostCell.h"
#import "ProfileHeader.h"
#import "OperationSingleton.h"
#import "FollowersViewController.h"
#import "VenueViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"
#import "ArchiveDetailViewController.h"
#import "NSURL+Attributes.h"

@interface UserProfViewController ()
{
    __weak IBOutlet UIActivityIndicatorView *oActivityIndicator;
    __weak IBOutlet UITableView *oFeedTableView;
    __weak IBOutlet UIBarButtonItem *oRightBarButton;
    UIBarButtonItem *sidebarButtonItem;
    UIBarButtonItem *cameraButtonItem;
    NSNotificationCenter *notificationCenter;
    UIButton *followButton;
    ProfileHeader *header;
    BOOL title;
    int finishedLoading;
    BOOL avatarOk;
}

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation UserProfViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        notificationCenter = [NSNotificationCenter defaultCenter];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Google Analytics
    self.tracker = [[GAI sharedInstance] defaultTracker];
    
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:2];
    avatarOk = NO;
    [self removeTitle];
    
    if (self.navigationController.viewControllers.count >1) {
        self.navigationItem.hidesBackButton = NO;
    }
    else{
        UIButton *sidebarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sidebarButton setFrame:CGRectMake(0, 0, 22, 21)];
        [sidebarButton setBackgroundImage:[UIImage imageNamed:@"hamburger.png"] forState:UIControlStateNormal];
        [sidebarButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        sidebarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sidebarButton];
        
        self.navigationItem.leftBarButtonItem = sidebarButtonItem;
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];

    [self loadObjects];
    
    // Register the table cell
    [self.tableView registerClass:[UserContainerTableCell class] forCellReuseIdentifier:@"UserContainerTableCell"];
    

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
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self removeTitle];
    oRightBarButton.tintColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar addSubview:[self navigationItemTile]];
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    
    if (!self.userToShow) {
        self.userToShow = [User currentUser];
        self.dataArray = [[NSMutableArray alloc] initWithCapacity:2];
        [self.tableView reloadData];
        [self buildHeader];
        [self loadObjects];
        [self connectToFB];
    }
    else if ([self.userToShow.objectId isEqualToString:[User currentUser].objectId]) {
        [self buildHeader];
        [self.tracker set:kGAIScreenName value:@"My Profile"];
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
        
        UIButton *logOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [logOutButton setFrame:CGRectMake(0, 0, 24, 24)];
        
        //[logOutButton setTitle:@"Log Out" forState:UIControlStateNormal];
        logOutButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
        [logOutButton setTitleColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [logOutButton addTarget:self action:@selector(didPressedRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logOutButton];
        
        [logOutButton setBackgroundImage:[UIImage imageNamed:@"settings_icon.png"] forState:UIControlStateNormal];

        [self connectToFB];
    }
    else{
        [self buildHeader];
        [self.tracker set:kGAIScreenName value:@"Other User Profile"];
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
        
        followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [followButton setFrame:CGRectMake(0, 0, 70, 24)];
        [followButton setBackgroundImage:[UIImage imageNamed:@"btn_photo_caption_page_blank.png"] forState:UIControlStateNormal];
        followButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
        [followButton setTitleColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [followButton addTarget:self action:@selector(didPressedRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:followButton];
        [self updateUserProfile];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFollowers:) name:@"showFollowersNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFollowing:) name:@"showFollowingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectItemFromCollectionView:) name:@"didSelectItemFromCollectionView" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [[User currentUser] refresh];
    if (![self.userToShow.objectId isEqualToString:[User currentUser].objectId]) {
        if ([self following]) {
            [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }
        else{
            [followButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
    }

    [self performSelectorInBackground:@selector(fillHeader) withObject:Nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self removeTitle];
    //self.title = @"Back";
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildHeader{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileHeader" owner:self options:nil];
    header = [nib objectAtIndex:0];
    header.oNameLabel.text = self.userToShow[@"username"];
    header.oBackgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    header.oBackgroundView.layer.borderWidth = 0.8f;
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString* path2 = [cachesDirectory stringByAppendingPathComponent:@"/images/avatars"];
    NSString* avatarPath = [path2 stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar%@.png",self.userToShow.objectId ]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:avatarPath]) {
        header.oProfilePictureView.image = [UIImage imageWithContentsOfFile:avatarPath];
        avatarOk = YES;
    }
    
    self.tableView.tableHeaderView = header;
}

- (void)fillHeader{

    if (!avatarOk) {
        NSURL *imageURL = [NSURL URLWithString:self.userToShow [@"profile"][@"pictureURL"]];
        NSData *profileImageData = [NSData dataWithContentsOfURL:imageURL];
        header.oProfilePictureView.image = [[UIImage imageWithData:profileImageData] squareImageWithImage:[UIImage imageWithData:profileImageData] scaledToSize:CGSizeMake(180,180) cropSides:NO profilePic:YES];
    }
    
    //Query number of Posts
    
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"user" equalTo:self.userToShow];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        UIFont *numberFont = [UIFont fontWithName:@"CenturyGothic-Bold" size:12.0];
        NSDictionary *numberDict = [NSDictionary dictionaryWithObject: numberFont forKey:NSFontAttributeName];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",number] attributes: numberDict];
        
        UIFont *textFont = [UIFont fontWithName:@"CenturyGothic" size:12.0];
        NSDictionary *textDict = [NSDictionary dictionaryWithObject:textFont forKey:NSFontAttributeName];
        NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc]initWithString:@" Posts" attributes:textDict];
        [attrString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] range:(NSMakeRange(0, attrString2.length))];
        
        [attrString appendAttributedString:attrString2];
        
        header.oNumberPostsLabel.attributedText = attrString;
    }];
    
    //Query number of Followers
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"FollowUser"];
    [query2 whereKey:@"followee" equalTo:self.userToShow];
    query2.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query2 countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        UIFont *numberFont = [UIFont fontWithName:@"CenturyGothic-Bold" size:12.0];
        NSDictionary *numberDict = [NSDictionary dictionaryWithObject: numberFont forKey:NSFontAttributeName];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",number] attributes: numberDict];
        
        UIFont *textFont = [UIFont fontWithName:@"CenturyGothic" size:12.0];
        NSDictionary *textDict = [NSDictionary dictionaryWithObject:textFont forKey:NSFontAttributeName];
        NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc]initWithString:@" Followers" attributes:textDict];
        [attrString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] range:(NSMakeRange(0, attrString2.length))];
        
        [attrString appendAttributedString:attrString2];
        
        header.oNumberFollowersLabel.attributedText = attrString;
    }];
    
    //Query number of following
    
    PFQuery *query3 = [PFQuery queryWithClassName:@"FollowUser"];
    [query3 whereKey:@"follower" equalTo:self.userToShow];
    query3.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query3 countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        UIFont *numberFont = [UIFont fontWithName:@"CenturyGothic-Bold" size:12.0];
        NSDictionary *numberDict = [NSDictionary dictionaryWithObject: numberFont forKey:NSFontAttributeName];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",number] attributes:numberDict];
        
        UIFont *textFont = [UIFont fontWithName:@"CenturyGothic" size:12.0];
        NSDictionary *textDict = [NSDictionary dictionaryWithObject:textFont forKey:NSFontAttributeName];
        NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc]initWithString:@" Following" attributes:textDict];
        [attrString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] range:(NSMakeRange(0, attrString2.length))];
        
        [attrString appendAttributedString:attrString2];
        
        header.oNumberFollowingLabel.attributedText = attrString;
    }];
    
    //Query number of Likes
    
    PFQuery *query4 = [PFQuery queryWithClassName:@"Post"];
    [query4 whereKey:@"user" equalTo:self.userToShow];
    [query4 whereKey:@"likeable" equalTo:[NSNumber numberWithBool:true]];
    query4.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query4 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSInteger totalOfLikes = 0;
        for (PFObject *post in objects) {
            totalOfLikes += [((Post*)post).numberOfLikes integerValue];
        }
        
        if (totalOfLikes>999 && totalOfLikes<999999) {
            header.oNumberLikesLabel.text = [NSString stringWithFormat:@"%.2fk",(float)totalOfLikes/1000];
            header.oNumberLikesLabel.font = [UIFont fontWithName:@"CenturyGothic" size:19.0];
        }
        else if (totalOfLikes>99 && totalOfLikes<999){
            header.oNumberLikesLabel.text = [NSString stringWithFormat:@"%i",totalOfLikes];
            header.oNumberLikesLabel.font = [UIFont fontWithName:@"CenturyGothic" size:24.0];
        }
        else{
            header.oNumberLikesLabel.text = [NSString stringWithFormat:@"%i",totalOfLikes];
            header.oNumberLikesLabel.font = [UIFont fontWithName:@"CenturyGothic" size:28.0];
        }
        
    }];
    
    
}


- (void)removeTitle{
    for (UIView* view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[UIImageView class]] && (view.tag == 9 || view.tag == 7)) {
            [view removeFromSuperview];
        }
    }
}

- (void)loadObjects{
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"Post"];
    query1.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query1 orderByDescending:@"createdAt"];
    [query1 includeKey:@"image"];
    if (!self.userToShow) {
        self.userToShow = [User currentUser];
    }
    [query1 whereKey:@"user" equalTo:self.userToShow];
    [query1 orderByDescending:(@"week")];
    query1.limit = 999;
    
    [oActivityIndicator startAnimating];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            finishedLoading = objects.count;
            for (UIView *view in self.tableView.subviews) {
                if (view.tag == 101) {
                    [view removeFromSuperview];
                }
            }
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"LLLL dd"];
            NSDate *tmpDate, *tmpDate2;
            NSString *formattedDate, *formattedDate2;
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
            NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:10];
            NSInteger weekIndex = 0;
            NSInteger photoIndex = 0;
            
            tmpDate = objects[0][@"week"];
            formattedDate = [[df stringFromDate:tmpDate] capitalizedString];
            [dictionary setObject:[NSString stringWithFormat:@" Week of %@",formattedDate] forKey:@"description"];
            [dictionary setObject:photos forKey:@"photos"];
            [self.dataArray addObject:dictionary];
            
            for (int i = 0; i < objects.count; i++) {
                tmpDate2 = objects[i][@"week"];
                formattedDate2 = [[df stringFromDate:tmpDate2] capitalizedString];
                if (![formattedDate isEqualToString:formattedDate2]){
                    weekIndex++;
                    photoIndex = 0;
                    tmpDate = objects[i][@"week"];
                    formattedDate = [[df stringFromDate:tmpDate] capitalizedString];
                    dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
                    [dictionary setObject:[NSString stringWithFormat:@" Week of %@",formattedDate] forKey:@"description"];
                    photos = [[NSMutableArray alloc] initWithCapacity:10];
                    [dictionary setObject:photos forKey:@"photos"];
                    [self.dataArray addObject:dictionary];
                }
                Post *post = objects[i];
                [self loadImage:post forPhotoIndex:photoIndex andWeekIndex:weekIndex];
                photoIndex++;
            }
            [self.tableView reloadData];
            
        }
        else{
            oActivityIndicator.hidesWhenStopped = YES;
            [oActivityIndicator stopAnimating];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(130, 180, 80, 40)];
            label.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
            label.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
            label.text = @"No posts";
            label.tag = 101;
            [self.tableView addSubview:label];
            
        }
    }];
}


- (void)loadImage:(Post*)post forPhotoIndex:(NSInteger)photoIndex andWeekIndex:(NSInteger)weekIndex{
    
    NSString *path;
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
    NSString *formattedDateString2 = [dateFormatter2 stringFromDate:post.createdAt];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    path = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/%@/image%@.png",[NSString stringWithFormat:@"/%@",formattedDateString2],post.objectId]];
    
    
    //If post image stored in device, load it from device
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        finishedLoading--;
        if (finishedLoading == 0) {
            oActivityIndicator.hidesWhenStopped = YES;
            [oActivityIndicator stopAnimating];
        }
        [self.dataArray[weekIndex][@"photos"] addObject:@{@"title":@"",@"id":post.objectId,@"image":[UIImage imageWithContentsOfFile:path],@"imageLoaded":[NSNumber numberWithBool:YES]}];
    }
    else{
        NSDictionary *parameters = @{@"post":post,@"photoIndex":[NSNumber numberWithInteger:photoIndex],@"weekIndex":[NSNumber numberWithInteger:weekIndex]};
        [self performSelectorInBackground:@selector(saveImageForPost:) withObject:parameters];
        
        [self.dataArray[weekIndex][@"photos"] addObject:@{@"title":@"",@"id":post.objectId,@"image":[UIImage new],@"imageLoaded":[NSNumber numberWithBool:NO]}];
    }
    
}


- (void)saveImageForPost:(NSDictionary*)parameters
{
   // PFObject *object = parameters[@"object"];
    Post *post = parameters[@"post"];
    NSInteger photoIndex = [parameters[@"photoIndex"] integerValue];
    NSInteger weekIndex = [parameters[@"weekIndex"] integerValue];
    
    UIImage *image = [UIImage imageWithData:[post[@"image"][@"image"] getData]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *formattedDateString = [dateFormatter stringFromDate:post.createdAt];
    
    if (image != nil)
    {
        //SAVE POST IMAGE
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                             NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        NSString* path = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/%@",formattedDateString]];
        
        //CREATE DATE DIRECTORY IF NECESSARY
        if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            [[NSURL fileURLWithPath:path] addSkipBackupAttributeToItem];
        }
        
        NSString* imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"image%@.png",post.objectId]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            NSData* data = UIImagePNGRepresentation(image);
            if([data writeToFile:imagePath atomically:YES]){
                [[NSURL fileURLWithPath:imagePath] addSkipBackupAttributeToItem];
                finishedLoading--;
                if (finishedLoading == 0) {
                    oActivityIndicator.hidesWhenStopped = YES;
                    [oActivityIndicator stopAnimating];
                }
                [self.dataArray[weekIndex][@"photos"] replaceObjectAtIndex:photoIndex withObject:@{@"title":@"",@"id":post.objectId,@"image":[UIImage imageWithContentsOfFile:imagePath],@"imageLoaded":[NSNumber numberWithBool:YES]}];

                
                //[self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
                [self reload];
            }
        }
        
    }
}

- (void)reload{
    [self.tableView reloadData];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserContainerTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserContainerTableCell"];
    NSDictionary *cellData = [self.dataArray objectAtIndex:[indexPath section]];
    NSArray *photoData = [cellData objectForKey:@"photos"];
    [cell setCollectionData:photoData];
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    label.font = [UIFont fontWithName:@"CenturyGothic" size:19.0];
    label.textColor = [UIColor colorWithRed:27.0/255.0 green:160.0/255.0 blue:206.0/255.0 alpha:1.0];
    label.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    //colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    NSDictionary *sectionData = [self.dataArray objectAtIndex:section];
    label.text = [sectionData objectForKey:@"description"];
    label.textAlignment = NSTextAlignmentLeft;
    
    //[label setBackgroundColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
    [view addSubview:label];
    return view;
}


#pragma mark UITableViewDelegate methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionData = [self.dataArray objectAtIndex:section];
    NSString *header2 = [sectionData objectForKey:@"description"];
    return header2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 135.0;
}

#pragma mark - NSNotification to select table cell

- (void) didSelectItemFromCollectionView:(NSNotification *)notification
{
    NSDictionary *cellData = [notification object];
    if (cellData){
        [self performSegueWithIdentifier:@"detailView" sender:cellData];
    }
}

- (PFObject*)following{
    PFQuery *query = [PFQuery queryWithClassName:@"FollowUser"];
    [query whereKey:@"followee" equalTo:self.userToShow];
    [query whereKey:@"follower" equalTo:[User currentUser]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    PFObject *object = [query getFirstObject];
    
    if (object) {
        return object;
    }
    return nil;
}

- (IBAction)didPressedRightBarButton:(id)sender {
    if ([self.userToShow.objectId isEqualToString:[User currentUser].objectId]) {
        //[User logOut];
        //[self performSegueWithIdentifier:@"login" sender:self];
        [self performSegueWithIdentifier:@"settings" sender:self];
    }
    else{ //Follow
        PFObject *follow = [self following];
        if (follow) {
            [followButton setTitle:@"Follow" forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:followButton];
            
            [follow deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                UIFont *numberFont = [UIFont fontWithName:@"CenturyGothic-Bold" size:12.0];
                NSDictionary *numberDict = [NSDictionary dictionaryWithObject: numberFont forKey:NSFontAttributeName];
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",[header.oNumberFollowersLabel.text intValue] -1] attributes:numberDict];
                
                UIFont *textFont = [UIFont fontWithName:@"CenturyGothic" size:12.0];
                NSDictionary *textDict = [NSDictionary dictionaryWithObject:textFont forKey:NSFontAttributeName];
                NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc]initWithString:@" Followers" attributes:textDict];
                [attrString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] range:(NSMakeRange(0, attrString2.length))];
                
                [attrString appendAttributedString:attrString2];
                
                header.oNumberFollowersLabel.attributedText = attrString;
            }];
        }
        else{
            [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:followButton];
            
            PFObject *follow = [PFObject objectWithClassName:@"FollowUser"];
            [follow setObject:self.userToShow forKey:@"followee"];
            [follow setObject:[User currentUser] forKey:@"follower"];
            [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIFont *numberFont = [UIFont fontWithName:@"CenturyGothic-Bold" size:12.0];
                NSDictionary *numberDict = [NSDictionary dictionaryWithObject: numberFont forKey:NSFontAttributeName];
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",[header.oNumberFollowersLabel.text intValue] +1] attributes:numberDict];
                
                UIFont *textFont = [UIFont fontWithName:@"CenturyGothic" size:12.0];
                NSDictionary *textDict = [NSDictionary dictionaryWithObject:textFont forKey:NSFontAttributeName];
                NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc]initWithString:@" Followers" attributes:textDict];
                [attrString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] range:(NSMakeRange(0, attrString2.length))];
                
                [attrString appendAttributedString:attrString2];
                
                header.oNumberFollowersLabel.attributedText = attrString;
            }];
        }
    }
}

- (void)updateUserProfile{
    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init];
    
    if ([self.userToShow objectForKey:@"profile"][@"pictureURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:[self.userToShow objectForKey:@"profile"][@"pictureURL"]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        if (!urlConnection) {
            NSLog(@"Failed to download picture");
        }
    }
}

#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    //oImageView.image = [UIImage imageWithData:self.imageData];
}


- (void)showFollowers:(NSNotification*)notification{
    [self performSegueWithIdentifier:@"followers" sender:self];
}

- (void)showFollowing:(NSNotification*)notification{
    [self performSegueWithIdentifier:@"following" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"followers"]) {
        FollowersViewController *followersController = segue.destinationViewController;
        followersController.user = self.userToShow;
        followersController.typeOfList = @"Followers";
    }
    else if([segue.identifier isEqualToString:@"following"]){
        FollowersViewController *followersController = segue.destinationViewController;
        followersController.user = self.userToShow;
        followersController.typeOfList = @"Following";
    }
    else if ([segue.identifier isEqualToString:@"detailView"]) {
        ArchiveDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.detailItem = (NSDictionary*)sender;
    }
}


- (void)connectToFB{
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else if (session.isOpen) {
                [self loadUserInfo];
            }
        }];
    }
    else{
        [self loadUserInfo];
    }
}

- (void)loadUserInfo{
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:6];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                userProfile[@"birthday"] = userData[@"birthday"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            [[User currentUser] setObject:userProfile forKey:@"profile"];
            
            if (userData[@"email"]) {
                [User currentUser].email = userData[@"email"];
            }
            
            if (userData[@"name"]) {
                [User currentUser].name = userData[@"name"];
            }
            
            
            [[User currentUser] saveInBackground];
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"]) {
            NSLog(@"The facebook session was invalidated");
        }
        else{
            NSLog(@"Some other error: %@", error);
        }
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectItemFromCollectionView" object:nil];
}
@end
