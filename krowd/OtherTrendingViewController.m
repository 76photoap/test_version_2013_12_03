

#import "OtherTrendingViewController.h"
#import "TrendingCell.h"
#import "VenueViewController.h"
#import "UserProfViewController.h"
#import "UIImage+Resize.h"
#import "MBProgressHUD.h"
#import "NSURL+Attributes.h"

@interface OtherTrendingViewController ()
{
    NSMutableArray *newObjectList;
    NSMutableArray *numberOfLikesList;
    NSMutableArray *idOfObjectList;
    UIBarButtonItem *sidebarButtonItem;
    UIBarButtonItem *cameraButtonItem;
    BOOL movedAfterScrolling;
    float yCoordinateConstant;
    BOOL scrollStarted;
    BOOL sorted;
}
@end

@implementation OtherTrendingViewController

@synthesize typeOfTrending;

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];

    // Change button color
    UIButton *sidebarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sidebarButton setFrame:CGRectMake(0, 0, 22, 21)];
    [sidebarButton setBackgroundImage:[UIImage imageNamed:@"hamburger.png"] forState:UIControlStateNormal];
    [sidebarButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    sidebarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sidebarButton];
    
    self.navigationItem.leftBarButtonItem = sidebarButtonItem;
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    
    movedAfterScrolling = NO;
    scrollStarted = NO;
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setFrame:CGRectMake(0, 0, 29, 20)];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(newPost) forControlEvents:UIControlEventTouchUpInside];
    
    cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
    
    self.navigationItem.rightBarButtonItem = cameraButtonItem;
    
    
    //Custom refresh control. I need to change sorted value after refreshing, or it wont update.
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)refreshFeed{
    sorted = NO;
    [self loadObjects];
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.rightBarButtonItem.enabled = YES;

    [self.notificationCenter addObserver:self selector:@selector(disableTableScroll:) name:@"CameraMovingNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(enableTableScroll:) name:@"CameraNotMovingNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(newPost) name:@"goToCameraNotification" object:nil];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self removeTitle];
    if ([self.typeOfTrending isEqualToString:@"Venues"]) {
        [self.tracker set:kGAIScreenName value:@"Trending Venues"];
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
        self.title = @"TRENDING VENUES";
    }
    else{
        [self.tracker set:kGAIScreenName value:@"Trending People"];
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
        self.title = @"TRENDING PEOPLE";
    }

}

- (void)viewWillDisappear:(BOOL)animated{
    [self removeTitle];
   // self.title = @"Back";
}

- (void)disableTableScroll:(NSNotification*)notification{
    self.tableView.scrollEnabled = NO;
    movedAfterScrolling = YES;
}

- (void)enableTableScroll:(NSNotification*)notification{
    self.tableView.scrollEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollStarted) {
        if (movedAfterScrolling) {
            CGRect fixedFrame = floatingCamera.frame;
            yCoordinateConstant = fixedFrame.origin.y - scrollView.contentOffset.y;
            fixedFrame.origin.y = yCoordinateConstant + scrollView.contentOffset.y;
            floatingCamera.frame = fixedFrame;
            movedAfterScrolling = NO;
            
        }
        else{
            CGRect fixedFrame = floatingCamera.frame;
            fixedFrame.origin.y = yCoordinateConstant + scrollView.contentOffset.y;
            floatingCamera.frame = fixedFrame;
        }
    }
    else{
        CGRect fixedFrame = floatingCamera.frame;
        fixedFrame.origin.y = fixedFrame.origin.y + scrollView.contentOffset.y;
        floatingCamera.frame = fixedFrame;
        scrollStarted = YES;
        yCoordinateConstant = fixedFrame.origin.y;
    }
    
}

#pragma mark PFTableViewController

- (PFQuery *)queryForTable{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];

    [query whereKey:@"numberOfLikes" greaterThan:@0];
    [query whereKey:@"likeable" equalTo:[NSNumber numberWithBool:true]];
    if ([User currentUser].currentLocation) {
        [query whereKey:@"city" equalTo:[User currentUser].currentLocation];
    }
    if ([self.typeOfTrending isEqualToString:@"Venues"]) {
        [query includeKey:@"venue"];
    }
    else{
        [query includeKey:@"user"];
    }
    query.limit = 999;
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    return query;
}

//Need to process posts retrieved in query, to build rankings

- (void)objectsDidLoad:(NSError *)error{
    
    if (!sorted) {
        [super objectsDidLoad:error];

        newObjectList = [[NSMutableArray alloc] initWithCapacity:10];
        numberOfLikesList = [[NSMutableArray alloc] initWithCapacity:10];
        idOfObjectList = [[NSMutableArray alloc] initWithCapacity:10];
        
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
            
            NSMutableArray *allObjects = [[NSMutableArray alloc] initWithArray:self.objects];
            //If query reached max 999, load more.
            if (self.objects.count >= 999) {
                int i = 1;
                BOOL load = YES;
                
                PFQuery *query = [PFQuery queryWithClassName:@"Post"];
                [query whereKey:@"numberOfLikes" greaterThan:@0];
                [query whereKey:@"likeable" equalTo:[NSNumber numberWithBool:true]];
                
                if ([self.typeOfTrending isEqualToString:@"Venues"]) {
                    [query includeKey:@"venue"];
                }
                else{
                    [query includeKey:@"user"];
                }
                query.limit = 999;
                query.cachePolicy = kPFCachePolicyNetworkElseCache;
                
                while (load) {
                    query.skip = 999*i;
                    NSArray *results = [[NSArray alloc] initWithArray:[query findObjects]];
                    if (results.count > 0) {
                        [allObjects addObjectsFromArray:results];
                    }
                    else{
                        load = NO;
                    }
                    i++;
                }
                
                
            }
            
            if ([self.typeOfTrending isEqualToString:@"Venues"]) {
                for (Post* post in allObjects) {
                    if (post[@"venue"]) {
                        if ([idOfObjectList containsObject:post[@"venue"][@"foursquareId"]]) {
                            int i = [idOfObjectList indexOfObject:post[@"venue"][@"foursquareId"]];
                            numberOfLikesList[i] = [NSNumber numberWithInt:[numberOfLikesList[i] integerValue] + [((NSNumber*)post[@"numberOfLikes"]) integerValue]];
                        }
                        else{
                            [idOfObjectList addObject:post[@"venue"][@"foursquareId"]];
                            [numberOfLikesList addObject:(NSNumber*)post[@"numberOfLikes"]]
                            ;
                            [newObjectList addObject:post[@"venue"]];
                        }
                    }
                }
            }
            else{
                for (Post* post in allObjects) {
                    if ([idOfObjectList containsObject:((User*)post[@"user"]).objectId]) {
                        int i = [idOfObjectList indexOfObject:((User*)post[@"user"]).objectId];
                        numberOfLikesList[i] = [NSNumber numberWithInt:[numberOfLikesList[i] integerValue] + [((NSNumber*)post[@"numberOfLikes"]) integerValue]];
                    }
                    else{
                        [idOfObjectList addObject:((User*)post[@"user"]).objectId];
                        [numberOfLikesList addObject:(NSNumber*)post[@"numberOfLikes"]]
                        ;
                        [newObjectList addObject:post[@"user"]];
                    }
                    
                }
            }
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self sortByLikes];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        [self.tableView reloadData];
    }
}


- (void)sortByLikes{
    BOOL flag = YES;
    for (int counter=0; counter < newObjectList.count && flag && counter < 100; counter++) {
        flag = NO;
        for (int index = 0; index < newObjectList.count-1; index++) {
            NSInteger integer1 = [((NSNumber*)numberOfLikesList[index]) integerValue];
            NSInteger integer2 = [((NSNumber*)numberOfLikesList[index+1]) integerValue];
            
            if (integer1 > integer2) {
                numberOfLikesList[index] = [NSNumber numberWithInteger:integer2];
                numberOfLikesList[index+1] = [NSNumber numberWithInteger:integer1];
                
                NSString *tmp = newObjectList[index];
                newObjectList[index] = newObjectList[index+1];
                newObjectList[index+1] = tmp;
                
                NSString *tmp2 = idOfObjectList[index];
                idOfObjectList[index] = idOfObjectList[index+1];
                idOfObjectList[index+1] = tmp2;
                flag = YES;
            }
        }
    }
    sorted = YES;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    
    TrendingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrendingCell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TrendingCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.oLikes.text = @"";
    }
    else{
        cell.oImageView.image = nil;
        cell.oNameLabel.text = nil;
        cell.oLikes.text = @"";
    }

    if (numberOfLikesList[numberOfLikesList.count - indexPath.row - 1]) {
        cell.oLikes.text = [NSString stringWithFormat:@"%@",numberOfLikesList[numberOfLikesList.count - indexPath.row - 1]];
        [cell createCustomLikesLabel:[numberOfLikesList[numberOfLikesList.count - indexPath.row - 1] integerValue]];
    }
    else{
        cell.oLikes.text = @"0";
    }
    
    if ([typeOfTrending isEqualToString:@"Venues"]) {
        if (newObjectList[newObjectList.count - indexPath.row - 1]) {
            cell.oNameLabel.text = newObjectList[newObjectList.count - indexPath.row - 1][@"name"];
        }
        [self fillWithVenueImage:newObjectList[newObjectList.count - indexPath.row - 1] inCell:cell];
    }
    else{
        if (newObjectList[newObjectList.count - indexPath.row - 1]) {
            cell.oNameLabel.text = newObjectList[newObjectList.count - indexPath.row - 1][@"username"];
        }
        [self fillWithUserImage:newObjectList[newObjectList.count - indexPath.row - 1] inCell:cell];

    }

    cell.oRankingLabel.text = [NSString stringWithFormat:@"#%i",indexPath.row + 1];
    
    return cell;
}

- (void)fillWithVenueImage:(PFObject*)object inCell:(TrendingCell*)cell {
    
    //Check if images exist in disk
    NSString *avatarPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    avatarPath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/avatars/avatar%@.png",object.objectId]];
    
    
    //If post image stored in device, load it from device
    if ([[NSFileManager defaultManager] fileExistsAtPath:avatarPath]) {
        cell.oImageView.image = [UIImage imageWithContentsOfFile:avatarPath];
    }
    else{
        [[OperationSingleton sharedOperation] performBlockOnPrivateQueue:^{
            NSRange lastUnderscore = [[[[object objectForKey:@"categories"] objectForKey:@"icon"] objectForKey:@"prefix"] rangeOfString:@"_" options:NSBackwardsSearch];
            NSString *preURL = [object[@"categories"][@"icon"][@"prefix"] stringByReplacingCharactersInRange:lastUnderscore withString:object[@"categories"][@"icon"][@"suffix"]];
            NSURL *imageURL = [NSURL URLWithString:preURL];
            NSData *avatarImageData = [NSData dataWithContentsOfURL:imageURL];
            
            if ([UIImage imageWithData:avatarImageData]) {
                UIImage *avatarImage = [UIImage imageWithData:avatarImageData];
                cell.oImageView.image = avatarImage;
            }
            else{
                NSURL *URL = [NSURL URLWithString:@"https://foursquare.com/img/categories_v2/nightlife/wine.png"];
                if (URL) {
                    NSData *avatarImageData = [NSData dataWithContentsOfURL:URL];
                    UIImage *avatarImage = [UIImage imageWithData:avatarImageData];
                    cell.oImageView.image = avatarImage;
                }
            }
            [self performSelectorInBackground:@selector(saveImageForPost:) withObject:object];
        }];
    }
}

- (void)fillWithUserImage:(PFObject*)object inCell:(TrendingCell*)cell {
    //Check if images exist in disk
    NSString *avatarPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    avatarPath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/avatars/avatar%@.png",((User*)object).objectId]];
        
    if ([[NSFileManager defaultManager] fileExistsAtPath:avatarPath]) {
        cell.oImageView.image = [UIImage imageWithContentsOfFile:avatarPath];
    }
    else{
        //In background load pictures from facebook, and then store it in local directory
        [[OperationSingleton sharedOperation] performBlockOnPrivateQueue:^{
            NSURL *imageURL = [NSURL URLWithString:object[@"profile"][@"pictureURL"]];
            NSData *profileImageData = [NSData dataWithContentsOfURL:imageURL];
            cell.oImageView.image = [[UIImage imageWithData:profileImageData] squareImageWithImage:[UIImage imageWithData:profileImageData] scaledToSize:CGSizeMake(180,180) cropSides:NO profilePic:YES];
            [self performSelectorInBackground:@selector(saveImageForPost:) withObject:object];
        }];
    }

}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MIN(newObjectList.count,50);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([typeOfTrending isEqualToString:@"Venues"]) {
        [self performSegueWithIdentifier:@"goToVenue" sender:indexPath];
    }
    else{
        [self performSegueWithIdentifier:@"goToProfile" sender:indexPath];
    }
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"goToVenue"]) {
        VenueViewController *venueController = segue.destinationViewController;
        venueController.venueToShow = newObjectList[newObjectList.count - ((NSIndexPath*)sender).row - 1];
    }
    else if ([segue.identifier isEqualToString:@"goToProfile"]){
        UserProfViewController *userController = segue.destinationViewController;
        userController.userToShow = newObjectList[newObjectList.count - ((NSIndexPath*)sender).row - 1];
    }
}


- (void)saveImageForPost:(PFObject*)object
{    
    NSURL *imageURL;
    NSData *avatarImageData;
    UIImage *avatarImage;
    
    if ([typeOfTrending isEqualToString:@"Venues"]) {
        NSRange lastUnderscore = [object[@"categories"][@"icon"][@"prefix"] rangeOfString:@"_" options:NSBackwardsSearch];
        NSString *preURL = [object[@"categories"][@"icon"][@"prefix"] stringByReplacingCharactersInRange:lastUnderscore withString:object[@"categories"] [@"icon"][@"suffix"]];
        
        imageURL = [NSURL URLWithString:preURL];
        avatarImageData = [NSData dataWithContentsOfURL:imageURL];
        if (avatarImageData) {
            avatarImage = [UIImage imageWithData:avatarImageData];
        }
        else{
            NSURL *defaultURL = [NSURL URLWithString:@"https://foursquare.com/img/categories_v2/nightlife/wine.png"];
            NSData *defaultImageData = [NSData dataWithContentsOfURL:defaultURL];
            avatarImage = [UIImage imageWithData:defaultImageData];
        }
    }
    else{
        imageURL = [NSURL URLWithString:object[@"profile"][@"pictureURL"]];
        avatarImageData = [NSData dataWithContentsOfURL:imageURL];
        avatarImage = [[UIImage imageWithData:avatarImageData] squareImageWithImage:[UIImage imageWithData:avatarImageData] scaledToSize:CGSizeMake(180,180) cropSides:NO profilePic:YES];
    }
    
    
    //SAVE POST IMAGE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString* folderPath = [cachesDirectory stringByAppendingPathComponent:@"/images/avatars"];
    
    
    NSString* avatarPath;
    //SAVE VENUE AVATAR
    if ([typeOfTrending isEqualToString:@"Venues"]) {
         avatarPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar%@.png",object.objectId]];
    }
    else{
        avatarPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar%@.png",((User*)object).objectId]];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:avatarPath]) {
        NSData* data = UIImagePNGRepresentation(avatarImage);
        if([data writeToFile:avatarPath atomically:YES])
            [[NSURL fileURLWithPath:avatarPath] addSkipBackupAttributeToItem];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
