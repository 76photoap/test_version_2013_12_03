
#import "ArchiveViewController.h"
#import "ArchiveDetailViewController.h"
#import "ArchiveContainerTableCell.h"
#import "ArchiveContainerCellView.h"
#import "Post.h"
#import "NSURL+Attributes.h"


@interface ArchiveViewController ()
{
    UIBarButtonItem *siderbarButtonItem;
    UIBarButtonItem *cameraButtonItem;
    CLLocationManager *locationManager;
    int finishedLoading;
    __weak IBOutlet UIActivityIndicatorView *oActivityIndicator;
    NSString *city;
    BOOL cameraButtonPressed;
}

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
//@property (strong, nonatomic) WallDetailViewController *detailViewController;

@end

@implementation ArchiveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Google Analytics
    self.tracker = [[GAI sharedInstance] defaultTracker];
    [self.tracker set:kGAIScreenName value:@"The Archive"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    [self removeTitle];
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:2];

    self.title = @"THE ARCHIVE";
    UIButton *sidebarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sidebarButton setFrame:CGRectMake(0, 0, 22, 21)];
    [sidebarButton setBackgroundImage:[UIImage imageNamed:@"hamburger.png"] forState:UIControlStateNormal];
    [sidebarButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    siderbarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sidebarButton];
    self.navigationItem.leftBarButtonItem = siderbarButtonItem;
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setFrame:CGRectMake(0, 0, 29, 20)];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(newPost) forControlEvents:UIControlEventTouchUpInside];
    
    cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
    
    self.navigationItem.rightBarButtonItem = cameraButtonItem;
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    [self loadObjects];
    
   /* self.dataArray = @[ @{ @"description": @"Week 1",
                            @"photos": @[ @{ @"title": @"#1" },
                                            @{ @"title": @"#2" },
                                            @{ @"title": @"#3" },
                                            @{ @"title": @"#4" },
                                            ]
                            },
                         @{ @"description": @"Week 2",
                            @"photos": @[ @{ @"title": @"#1" },
                                            @{ @"title": @"#2" },
                                            @{ @"title": @"#3" },
                                            @{ @"title": @"#4" },
                                            ]
                            },
                         ];*/
    
    // Register the table cell
    [self.tableView registerClass:[ArchiveContainerTableCell class] forCellReuseIdentifier:@"ArchiveContainerTableCell"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
    
}

- (void)viewDidAppear:(BOOL)animated{
    self.navigationItem.rightBarButtonItem.enabled = YES;

    // Add observer that will allow the nested collection cell to trigger the view controller select row at index path
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectItemFromCollectionView:) name:@"didSelectItemFromCollectionView" object:nil];
    cameraButtonPressed = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [self removeTitle];
    //self.title = @"Back";
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeTitle{
    for (UIView* view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[UIImageView class]] && (view.tag == 9 || view.tag == 7)) {
            [view removeFromSuperview];
        }
    }
}

- (void)loadObjects{

    PFQuery *query1 = [PFQuery queryWithClassName:@"Archive"];
    query1.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query1 includeKey:@"post"];
    [query1 includeKey:@"post.image"];
    if ([User currentUser].currentLocation) {
        //This solution works, but i need to fetch maybe more than 999. so just temporarily it will only work for Chicago.
        /*PFQuery *postCityInnerQuery = [PFQuery queryWithClassName:@"Post"];
        [postCityInnerQuery whereKey:@"city" equalTo:[User currentUser].currentLocation];
        postCityInnerQuery.limit = 999;
        [query1 whereKey:@"post" matchesQuery:postCityInnerQuery];
        */
        if ([[User currentUser].currentLocation isEqualToString:@"Chicago, IL"]) {
            query1.limit = 80;
        }
        else{
            query1.limit = 0;
        }
        
    }
    else{
        query1.limit = 0;
    }
    
    [query1 orderByDescending:(@"week,position")];

    [oActivityIndicator startAnimating];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count == 0) {
            [oActivityIndicator stopAnimating];
            oActivityIndicator.hidesWhenStopped = YES;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 320, 40)];
            label.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
            label.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
            label.tag = 101;
            label.textAlignment = NSTextAlignmentCenter;
            [self.tableView addSubview:label];
            label.text = @"No posts in your city yet!";
        }
        else{
            NSInteger weekCount = 1;
            NSDate *tmpDate2 = objects[0][@"week"];
            for (int i=0; i<objects.count; i++) {
                if (![tmpDate2 isEqualToDate:objects[i][@"week"]]){
                    weekCount++;
                    tmpDate2 = objects[i][@"week"];
                }
                if (weekCount==5) {
                    finishedLoading = i-1;
                }
            }
            if (weekCount<5) {
                finishedLoading = objects.count-1;
            }
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"LLLL dd"];
            NSDate *tmpDate;
            NSString *formattedDate;
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
            NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:10];
            NSInteger weekIndex = 0;
            NSInteger photoIndex = 0;
            NSInteger amountOfWeeks = MIN(4, weekCount);
            
            tmpDate = objects[0][@"week"];
            formattedDate = [[df stringFromDate:tmpDate] capitalizedString];
            [dictionary setObject:[NSString stringWithFormat:@" Week of %@",formattedDate] forKey:@"description"];
            [dictionary setObject:photos forKey:@"photos"];
            [self.dataArray addObject:dictionary];
            
            for (int i = 0; i < objects.count; i++) {
                if (![tmpDate isEqualToDate:objects[i][@"week"]]){
                    weekIndex++;
                    if (weekIndex == amountOfWeeks) {
                        break;
                    }
                    photoIndex = 0;
                    tmpDate = objects[i][@"week"];
                    formattedDate = [[df stringFromDate:tmpDate] capitalizedString];
                    dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
                    [dictionary setObject:[NSString stringWithFormat:@" Week of %@",formattedDate] forKey:@"description"];
                    photos = [[NSMutableArray alloc] initWithCapacity:10];
                    [dictionary setObject:photos forKey:@"photos"];
                    [self.dataArray addObject:dictionary];
                }
                PFObject *object = objects[i];
                [self loadImage:object forPhotoIndex:photoIndex andWeekIndex:weekIndex];
                photoIndex++;
            }
            [self.tableView reloadData];
        }
    }];
    

}


- (void)loadImage:(PFObject*)object forPhotoIndex:(NSInteger)photoIndex andWeekIndex:(NSInteger)weekIndex{
    
    NSString *path;
    Post *post = object[@"post"];
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
        [self.dataArray[weekIndex][@"photos"] addObject:@{@"title":[NSString stringWithFormat:@"#%@",object[@"position"]],@"id":((Post*)object[@"post"]).objectId,@"image":[UIImage imageWithContentsOfFile:path],@"imageLoaded":[NSNumber numberWithBool:YES],@"typeOfCell":@"Archive"}];
        //return [UIImage imageWithContentsOfFile:path];
    }
    else{

      // UIImage *postImage = [UIImage imageWithData:[post[@"image"][@"image"] getData]];
        NSDictionary *parameters = @{@"object":object,@"photoIndex":[NSNumber numberWithInteger:photoIndex],@"weekIndex":[NSNumber numberWithInteger:weekIndex]};
        [self performSelectorInBackground:@selector(saveImageForPost:) withObject:parameters];
        
        [self.dataArray[weekIndex][@"photos"] addObject:@{@"title":[NSString stringWithFormat:@"#%@",object[@"position"]],@"id":((Post*)object[@"post"]).objectId,@"image":[UIImage new],@"imageLoaded":[NSNumber numberWithBool:NO],@"typeOfCell":@"Archive"}];

       //return [UIImage new];
    }
    
}


- (void)saveImageForPost:(NSDictionary*)parameters
{
    PFObject *object = parameters[@"object"];
    Post *post = object[@"post"];
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
                [self.dataArray[weekIndex][@"photos"] replaceObjectAtIndex:photoIndex withObject:@{@"title":[NSString stringWithFormat:@"#%@",object[@"position"]],@"id":post.objectId,@"image":image,@"imageLoaded":[NSNumber numberWithBool:YES],@"typeOfCell":@"Archive"}];

                //[self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
                [self reload];
            }
        }
        
    }
}

- (void)reload{
    [self.tableView reloadData];
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
    ArchiveContainerTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArchiveContainerTableCell"];

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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    label.font = [UIFont fontWithName:@"CenturyGothic" size:17.0];
    label.textColor = [UIColor colorWithRed:27.0/255.0 green:160.0/255.0 blue:206.0/255.0 alpha:1.0];
    label.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    
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
    NSString *header = [sectionData objectForKey:@"description"];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 164.0;
}

#pragma mark - NSNotification to select table cell

- (void) didSelectItemFromCollectionView:(NSNotification *)notification
{
    NSDictionary *cellData = [notification object];
    if (cellData){
        [self performSegueWithIdentifier:@"detailView" sender:cellData];
    }
   
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"detailView"]) {
       ArchiveDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.detailItem = (NSDictionary*)sender;
        
    }
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
