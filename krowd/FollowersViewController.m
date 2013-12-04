
#import "FollowersViewController.h"
#import "TrendingCell.h"
#import "VenueViewController.h"
#import "UserProfViewController.h"
#import "UIImage+Resize.h"
#import "NSURL+Attributes.h"

@interface FollowersViewController ()
{
    BOOL movedAfterScrolling;
    float yCoordinateConstant;
    UIBarButtonItem *cameraButtonItem;
    BOOL scrollStarted;
}
@end

@implementation FollowersViewController

@synthesize typeOfList;
@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Whether the built-in pagination is enabled
        //self.paginationEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    movedAfterScrolling = NO;
    scrollStarted = NO;
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setFrame:CGRectMake(0, 0, 29, 20)];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(newPost) forControlEvents:UIControlEventTouchUpInside];
    
    cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
    
    self.navigationItem.rightBarButtonItem = cameraButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.notificationCenter addObserver:self selector:@selector(disableTableScroll:) name:@"CameraMovingNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(enableTableScroll:) name:@"CameraNotMovingNotification" object:nil];
    [self.notificationCenter addObserver:self selector:@selector(newPost) name:@"goToCameraNotification" object:nil];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self removeTitle];
    if ([self.typeOfList isEqualToString:@"Followers"]) {
        self.title = @"FOLLOWERS";
    }
    else if ([self.typeOfList isEqualToString:@"Following"]){
        self.title = @"FOLLOWING";
    }
    else{
        self.title = @"LIKERS";
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [self removeTitle];
    //self.title = @"Back";
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
    
    if ([self.typeOfList isEqualToString:@"Followers"]) {
        PFQuery *query = [PFQuery queryWithClassName:@"FollowUser"];
        [query whereKey:@"followee" equalTo:self.user];
        [query includeKey:@"follower"];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        query.limit = 999;
        return query;
    }
    else if ([self.typeOfList isEqualToString:@"Following"]){
        PFQuery *query = [PFQuery queryWithClassName:@"FollowUser"];
        [query whereKey:@"follower" equalTo:self.user];
        [query includeKey:@"followee"];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        query.limit = 999;
        return query;
    } //else Likes
    else{
        PFQuery *query = [User query];
        [query whereKey:@"objectId" containedIn:self.selectedPost.likes];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        query.limit = 999;
        return query;
    }

}


- (void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad:error];
    NSLog(@"%@",self.objects);
    if (self.objects.count == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 180, 200, 40)];
        label.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
        label.textAlignment = NSTextAlignmentCenter;
        if ([self.typeOfList isEqualToString:@"Followers"]) {
            label.text = @"No followers yet";
        }
        else if ([self.typeOfList isEqualToString:@"Following"]){
            label.text = @"Not following anyone yet";
        }
        [self.tableView addSubview:label];
    }
}


#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    
    TrendingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrendingCell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TrendingCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.oLikes.text = @"";
        cell.oLikes.hidden = YES;
        cell.oStarView.hidden = YES;
    }
    else{
        cell.oImageView.image = nil;
        cell.oNameLabel.text = nil;
    }
    
    if ([typeOfList isEqualToString:@"Followers"]) {
        cell.oNameLabel.text = object[@"follower"][@"username"];
        [self fillWithUserImage:object[@"follower"] inCell:cell];
    }
    else if ([typeOfList isEqualToString:@"Following"]){
        cell.oNameLabel.text = object[@"followee"][@"username"];
        [self fillWithUserImage:object[@"followee"] inCell:cell];
    }
    else if([typeOfList isEqualToString:@"Likes"]){
        cell.oNameLabel.text = object[@"username"];
        [self fillWithUserImage:object inCell:cell];
    }
    
    return cell;
}

- (void)fillWithUserImage:(PFObject*)object inCell:(TrendingCell*)cell {
    //Check if images exist in disk
    NSString *avatarPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    avatarPath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"images/avatars/avatar%@.png",((User*)object).objectId]];
    
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"PaginationCell"]) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    else{
        UserProfViewController *userViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
        
        if ([typeOfList isEqualToString:@"Followers"]) {
            userViewController.userToShow = [self.objects[indexPath.row] objectForKey:@"follower"];
        }
        else if ([typeOfList isEqualToString:@"Following"]){
            userViewController.userToShow = [self.objects[indexPath.row] objectForKey:@"followee"];
        }
        else if ([typeOfList isEqualToString:@"Likes"]){
            userViewController.userToShow = self.objects[indexPath.row];
        }
        [self.navigationController pushViewController:userViewController animated:YES];
    }
}


- (void)saveImageForPost:(PFObject*)object
{   
    NSURL *imageURL;
    NSData *avatarImageData;
    UIImage *avatarImage;
    
    imageURL = [NSURL URLWithString:object[@"profile"][@"pictureURL"]];
    avatarImageData = [NSData dataWithContentsOfURL:imageURL];
    avatarImage = [[UIImage imageWithData:avatarImageData] squareImageWithImage:[UIImage imageWithData:avatarImageData] scaledToSize:CGSizeMake(180,180) cropSides:NO profilePic:YES];
    
    //SAVE POST IMAGE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString* folderPath = [cachesDirectory stringByAppendingPathComponent:@"/images/avatars"];
    
    NSString* avatarPath;
    //SAVE VENUE AVATAR
    avatarPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar%@.png",((User*)object).objectId]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:avatarPath]) {
        NSData* data = UIImagePNGRepresentation(avatarImage);
        if([data writeToFile:avatarPath atomically:YES]){
            [[NSURL fileURLWithPath:avatarPath] addSkipBackupAttributeToItem];
            [self performSelectorOnMainThread:@selector(reloadFeed) withObject:nil waitUntilDone:NO];
        }
    }
}

@end
