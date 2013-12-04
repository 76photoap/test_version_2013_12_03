

#import "FeedViewController.h"
#import "UserProfViewController.h"
#import "VenueViewController.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "InnapropriateReportView.h"
#import "FollowersViewController.h"
#import "NSURL+Attributes.h"

@interface FeedViewController ()
{
    UIBarButtonItem *sidebarButtonItem;
    CLLocationManager *locationManager;
    BOOL scrollStarted;
    BOOL movedAfterScrolling;
    float yCoordinateConstant;
    float scrollPosition;
    NSString *city;
    BOOL cameraButtonPressed;
}

@end

@implementation FeedViewController

@synthesize imageData;
@synthesize postToDelete;
@synthesize notificationCenter;

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
        // The className to query on
        self.parseClassName = @"Post";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"caption";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;

        self.notificationCenter = [NSNotificationCenter defaultCenter];
        scrollStarted = NO;
        movedAfterScrolling = NO;
        scrollPosition = 0;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tracker = [[GAI sharedInstance] defaultTracker];
    //floatingCamera = [[FloatingCamera alloc] initWithFrame:CGRectMake(130, 0, 60, 60)];
    //[self.view addSubview:floatingCamera];
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
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollPosition = scrollView.contentOffset.y;
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


- (void)removeTitle{
    for (UIView* view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[UIImageView class]] && (view.tag == 9 || view.tag == 7)) {
            [view removeFromSuperview];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self.notificationCenter addObserver:self selector:@selector(likePost:) name:@"LikeNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(deletePost:) name:@"DeletePostNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(confirmDeletePost:) name:@"ConfirmDeleteNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(cancelDeletePost:) name:@"CancelDeleteNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(goToProfile:) name:@"GoToProfileNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(goToVenue:) name:@"GoToVenueNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(disableTableScroll:) name:@"CameraMovingNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(enableTableScroll:) name:@"CameraNotMovingNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(newPost) name:@"goToCameraNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(displayLikes:) name:@"SeeLikesNotification" object:nil];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    cameraButtonPressed = NO;

}

- (void)viewDidAppear:(BOOL)animated{
   // [self reloadFeed];
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.notificationCenter removeObserver:self];
}

- (void)disableTableScroll:(NSNotification*)notification{
    self.tableView.scrollEnabled = NO;
    movedAfterScrolling = YES;
}

- (void)enableTableScroll:(NSNotification*)notification{
    self.tableView.scrollEnabled = YES;
}

- (void)newPost{
    if ([city isEqualToString:@"Chicago"]) {
        [self performSegueWithIdentifier:@"newPost" sender:self];
    }
    else if(!city){
        if ([CLLocationManager authorizationStatus] !=kCLAuthorizationStatusAuthorized) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services is Disabled" message:@"You will only be able to post a photo on Krowdx if you tag the venue where you took it. For that reason, location services needs to be enabled. Please go to Settings-Privacy-LocationServices and turn it on for Krowdx." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else{
            cameraButtonPressed = YES;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            [locationManager startUpdatingLocation];
        }
    }
    else{
        [[[UIAlertView alloc]initWithTitle:@"Photo sharing not available" message:@"Sharing currently only available in Chicago, IL. Sorry for the inconvenience." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [locationManager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];
    //CLLocation *location2 = [[CLLocation alloc] initWithLatitude:41.894355 longitude:-87.635114];
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        city = ([placemarks count] > 0) ? [[placemarks objectAtIndex:0] locality] : @"Not Found";
        
        if (cameraButtonPressed) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            cameraButtonPressed = NO;
             if ([city isEqualToString:@"Chicago"]) {
                 [self performSegueWithIdentifier:@"newPost" sender:self];
             }
             else{
                 [[[UIAlertView alloc]initWithTitle:@"Photo sharing not available" message:@"Sharing currently only available in Chicago, IL. Sorry for the inconvenience." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             }
        }

    }];
    
}

- (void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad:error];

}


- (void)reloadFeed{
    [self loadObjects];
    [self.tableView reloadData];
}

#pragma mark PFTableViewController

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    [query includeKey:@"venue"];
    [query includeKey:@"image"];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{

    PostCell *cell;
    cell =[tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    
    //Create Cell with nib
    if ( cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else{
        cell.oPostImageView.image = nil;
        cell.oProfilePictureView.image = nil;
        [cell.oVenueButton setTitle:@"" forState:UIControlStateNormal];
    }
    
    if ([User currentUser]) {
        if ([object[@"likes"] containsObject:[User currentUser].objectId]) {
            [cell.oLikeButton setTitle:@"UNLIKE" forState:UIControlStateNormal];
        }
        else{
            [cell.oLikeButton setTitle:@"LIKE" forState:UIControlStateNormal];
        }
    }
    
    //If post older than 1 week, no more likable.
    if ([object[@"likeable"] boolValue]) {
        cell.oLikeButton.enabled = YES;
        [cell.oLikesStarImage setImage:[UIImage imageNamed:@"star_60x60.png"] forState:UIControlStateNormal];
    }
    else{
        cell.oLikeButton.enabled = NO;
        [cell.oLikesStarImage setImage:[UIImage imageNamed:@"star_60x60_grey.png"] forState:UIControlStateNormal];
    }
    
    [cell.oUsernameLabel setTitle:object[@"user"][@"username"] forState:UIControlStateNormal];
    
    cell.oDateLabel.text = [self calculateTime:object.createdAt];
    
    if ([object objectForKey:@"numberOfLikes"]) {
        [cell createCustomLikesLabel:[object[@"numberOfLikes"] integerValue]];
    }
    else{
        [cell.oLikesLabel setTitle:@"0" forState:UIControlStateNormal];
    }
    
    if (((NSString*)object[@"caption"]).length == 0 || [((NSString*)object[@"caption"]) isEqualToString:@" "]) {
        cell.oCaptionLabel.hidden = YES;
    }
    else{
        [cell createCustomCaptionLabel:object[@"caption"]];
    }
    
    if ([object objectForKey:@"venue"]) {
        [cell createCustomLabel:object[@"venue"][@"name"]];
    }
    
    [self fillWithImages:object inCell:cell forIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.objects count]) {
        return 70;
    }
    else{
        return 430;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


- (NSString*)calculateTime:(NSDate*)date{
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    if(interval < 86400.0){
        if (interval < 3600.0){
            return [NSString stringWithFormat:@"%im",(((int)interval)/60)+1];
        }else{
            return [NSString stringWithFormat:@"%ih",((int)interval)/3600];
            
        }
    }else{
        [dateFormat setDateFormat:@"dd MMM"];
        return [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:date]];
    }
}


- (PFTableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaginationCell"];
    
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PaginationCell"];
    }
    
    cell.textLabel.text = @"Load more..";
    cell.textLabel.textColor = [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}


//Initial loading of the first 10 images
- (void)loadImages{

    for (Post *post in self.objects) {
        BOOL loadFromServer = NO;
        NSString *path, *avatarPath;
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
        NSString *formattedDateString2 = [dateFormatter2 stringFromDate:post.createdAt];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        
        path = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/%@/image%@.png",[NSString stringWithFormat:@"/%@",formattedDateString2],post.objectId]];
        
        avatarPath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/avatars/avatar%@.png",((User*)post[@"user"]).objectId]];
        
        //If post image stored in device, load it from device
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            loadFromServer = YES;
        }
        
        //If avatar image stored in device, load it from device
        if (![[NSFileManager defaultManager] fileExistsAtPath:avatarPath]){
            loadFromServer = YES;
        }
        
        if (loadFromServer) {
            [self performSelectorInBackground:@selector(saveImageForPost:) withObject:post];
        }
    }
}


//Loading on demand
- (void)fillWithImages:(PFObject*)object inCell:(PostCell*)cell forIndex:(NSInteger) index{
    
    //Check if images exist in disk
    BOOL loadFromServer = NO;
    NSString *path, *avatarPath;
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
    NSString *formattedDateString2 = [dateFormatter2 stringFromDate:object.createdAt];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    path = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/%@/image%@.png",[NSString stringWithFormat:@"/%@",formattedDateString2],object.objectId]];
    
    avatarPath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/avatars/avatar%@.png",((User*)object[@"user"]).objectId]];
    
    [cell.oActivityIndicator startAnimating];
    
    //If post image stored in device, load it from device
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        cell.oPostImageView.image = [UIImage imageWithContentsOfFile:path];
        [cell.oActivityIndicator stopAnimating];
        cell.oActivityIndicator.hidesWhenStopped = YES;
    }
    else{
        loadFromServer = YES;
    }
    
    //If avatar image stored in device, load it from device
    if ([[NSFileManager defaultManager] fileExistsAtPath:avatarPath]){
        cell.oProfilePictureView.image = [UIImage imageWithContentsOfFile:avatarPath];
    }
    else{
        loadFromServer = YES;
    }
    
    if (loadFromServer) {        
        //In background load pictures from parse and facebook, and then store them in local directory
        [[OperationSingleton sharedOperation] performBlockOnPrivateQueue:^{
            
            NSURL *imageURL = [NSURL URLWithString:object[@"user"][@"profile"][@"pictureURL"]];
            NSData *profileImageData = [NSData dataWithContentsOfURL:imageURL];
            
            //Check if cell is still visible after loading from server. If YES, then assign it to cell image; otherwise, just save it.
            
            UIImage *profilePictureImage = [[UIImage imageWithData:profileImageData] squareImageWithImage:[UIImage imageWithData:profileImageData] scaledToSize:CGSizeMake(180,180) cropSides:NO profilePic:YES];
           // UIImage *postImage = [UIImage imageWithData:[object[@"image"][@"image"] getData]];
            
            float yPosition;
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;

            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                yPosition = scrollPosition + 44.0;
            }
            else{
                yPosition = scrollPosition;
            }
            
            if (yPosition > ((430*index) - screenSize.height - 44) && yPosition < 430*(index+1)) {
                cell.oProfilePictureView.image = profilePictureImage;
              //  cell.oPostImageView.image = postImage;
                [cell.oActivityIndicator stopAnimating];
                cell.oActivityIndicator.hidesWhenStopped = YES;
            }

            [self performSelectorInBackground:@selector(saveImageForPost:) withObject:object];
        }];
    } 

}


- (void)saveImageForPost:(PFObject*)object
{
    UIImage *image = [UIImage imageWithData:[object[@"image"][@"image"] getData]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *formattedDateString = [dateFormatter stringFromDate:object.createdAt];
    
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
        
        NSString* imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/image%@.png",object.objectId]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            NSData* data = UIImagePNGRepresentation(image);
            if([data writeToFile:imagePath atomically:YES])
                [[NSURL fileURLWithPath:imagePath] addSkipBackupAttributeToItem];
        }
        
        //SAVE USER AVATAR
        NSString* path2 = [cachesDirectory stringByAppendingPathComponent:@"/images/avatars"];
        NSString* avatarPath = [path2 stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar%@.png",((User*)object[@"user"]).objectId ]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:avatarPath]) {
            NSURL *imageURL = [NSURL URLWithString:object[@"user"][@"profile"][@"pictureURL"]];
            NSData *profileImageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *avatarImage = [[UIImage imageWithData:profileImageData] squareImageWithImage:[UIImage imageWithData:profileImageData] scaledToSize:CGSizeMake(180,180) cropSides:NO profilePic:YES];
            NSData* data = UIImagePNGRepresentation(avatarImage);
            
            if([data writeToFile:avatarPath atomically:YES])
                [[NSURL fileURLWithPath:avatarPath] addSkipBackupAttributeToItem];
        }
    }
}


- (void)likePost:(NSNotification*)notification{
    Post *selectedPost = [self.objects objectAtIndex:[self.tableView indexPathForCell:((PostCell*)notification.object)].row];
    
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

- (void)deletePost:(NSNotification*)notification{
    UIActionSheet *popupQuery;
    self.postToDelete = [self.objects objectAtIndex:[self.tableView indexPathForCell:((PostCell*)notification.object)].row];
    
    if ([self.postToDelete.user.objectId isEqualToString:[User currentUser].objectId]) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
    }
    else{
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report Inappropriate" otherButtonTitles:nil, nil];
    }
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"goToProfile"]) {
        UserProfViewController *userProfileViewController = segue.destinationViewController;
        userProfileViewController.userToShow = [sender objectForKey:@"user"];
    }
    else if ([segue.identifier isEqualToString:@"goToVenue"]){
        VenueViewController *venueController = segue.destinationViewController;
        venueController.venueToShow = [sender objectForKey:@"venue"];
    }
    else if([segue.identifier isEqualToString:@"displayLikes"]) {
        FollowersViewController *likesVC = segue.destinationViewController;
        likesVC.selectedPost = sender;
        likesVC.typeOfList = @"Likes";
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        if ([self.postToDelete.user.objectId isEqualToString:[User currentUser].objectId]) {
            [self.postToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self reloadFeed];
                PFQuery *imageQuery = [PFQuery queryWithClassName:@"PostImage"];
                [imageQuery whereKey:@"objectId" equalTo:((PFObject*)self.postToDelete[@"image"]).objectId];
                [imageQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [object deleteInBackground];
                }];
            }];
        }
        else{
            NSLog(@"Send mail for inappropriate");
            
            NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"InnapropriateReportView" owner:self options:nil];
            
            InnapropriateReportView *reportView = [nibViews objectAtIndex:0];
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            float yPosition;
            
            reportView.post = self.postToDelete;
            reportView.delegate = self;
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                yPosition = scrollPosition + 44.0;
            }
            else{
                yPosition = scrollPosition;
            }
            
            if (screenSize.height > 480.0f) {
                reportView.frame = CGRectMake(0,scrollPosition,320,568);
            }
            else{
                reportView.frame = CGRectMake(0,scrollPosition,320,480);
            }
            self.tableView.scrollEnabled = NO;
            [self.view addSubview:reportView];

        }
        
    } else if (buttonIndex == 1) {
        
    }
}

- (void)didSendReport{
    self.tableView.scrollEnabled = YES;
}

- (void)displayLikes:(NSNotification*)notification{
    Post *selectedPost = [self.objects objectAtIndex:[self.tableView indexPathForCell:((PostCell*)notification.object)].row];
    if ([selectedPost.numberOfLikes integerValue] > 0) {
        [self performSegueWithIdentifier:@"displayLikes" sender:selectedPost];
    }
}

- (void)goToProfile:(NSNotification*)notification{
    Post *selectedPost = [self.objects objectAtIndex:[self.tableView indexPathForCell:((PostCell*)notification.object)].row];
    [self performSegueWithIdentifier:@"goToProfile" sender:selectedPost];
}


- (void)goToVenue:(NSNotification*)notification{
    Post *selectedPost = [self.objects objectAtIndex:[self.tableView indexPathForCell:((PostCell*)notification.object)].row];
    [self performSegueWithIdentifier:@"goToVenue" sender:selectedPost];
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
}


@end