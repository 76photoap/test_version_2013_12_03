
#import "PostViewController.h"
#import "UIImage+Resize.h"
#import "Post.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <QuartzCore/QuartzCore.h>
#import "CameraViewController.h"
#import "NetworkClient.h"
#import "HomeViewController.h"

@interface PostViewController ()
{
    // Foursquare URL Component Variables
    NSString *latLong;
    NSString *queryPartOne;
    NSString *queryPartTwo;
    NSString *queryPartThree;
    NSString *queryTotal;
    
    NSDictionary *queryDictionary;
    NSMutableArray *tagVenuesArray;
    NSMutableArray *venueTitlesArray;
    NSMutableArray *venueIDArray;
    NSInteger venueIndex;
    
    __weak IBOutlet UITextView *oInsertCaptionTF;
    __weak IBOutlet UIImageView *oImageView;
    IBOutlet UIBarButtonItem *oPostButton;
    __weak IBOutlet UILabel *oCaptionTextLabel;
    __weak IBOutlet UIButton *oFBShareButton;
    __weak IBOutlet UIButton *oTwitterShareButton;
    IBOutlet UIBarButtonItem *oCancelButton;
    __weak IBOutlet UIActivityIndicatorView *oActivityIndicator;
    __weak IBOutlet UIView *oImageBorderView;
    __weak IBOutlet UIButton *selectVenueButton;
    UIButton *postButton;
    UIButton *cancelButton;
    
    
    BOOL shareToFacebook;
    BOOL shareToTwitter;
    BOOL photoTaken;
    BOOL photoUploaded;
    BOOL postButtonPressed;
    BOOL uploadCancelled;
    BOOL postUploaded;

    UIPickerView *pickerView;
    UINavigationBar *bar;
    
    NSArray *items;
    
    CLLocationManager *locationManager;
    NSString *userLocation;
//    NSTimer *timer;
//    NSNumber *uploadInterval;
    
    CameraViewController *camViewController;
    PFObject *imageObject;
}
- (IBAction)postButtonPressed:(id)sender;
- (IBAction)showPickerView:(id)sender;
- (IBAction)shareToTwitter:(id)sender;
- (IBAction)shareToFacebook:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;



@property (strong, nonatomic)AFPhotoEditorController *editorController;

@end

@implementation PostViewController

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
    
    //Google Analytics
    self.tracker = [[GAI sharedInstance] defaultTracker];
    [self.tracker set:kGAIScreenName value:@"New Post Screen"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    photoTaken = NO;
    shareToFacebook = NO;
    shareToTwitter = NO;
    postButtonPressed = NO;
    photoUploaded = NO;
    uploadCancelled = NO;
    postUploaded = NO;
    venueTitlesArray = [[NSMutableArray alloc]initWithCapacity:10];
    venueIDArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

}

- (void)viewWillAppear:(BOOL)animated{
    for (UIView* view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[UIImageView class]] && (view.tag == 9 || view.tag == 7)) {
            [view removeFromSuperview];
        }
    }
    
    [self addUIElements];

    // Get user location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    
    // Photo
    if (!photoTaken) {
        [self performSegueWithIdentifier:@"goToCamera" sender:self];
        photoTaken = YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"goToCamera"]) {
        camViewController = segue.destinationViewController;
        camViewController.delegate = self;
    }

}

- (void)addUIElements{
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    
    postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setFrame:CGRectMake(0, 0, 62, 24)];
    [postButton setBackgroundImage:[UIImage imageNamed:@"btn_post_off.png"] forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    oPostButton = [[UIBarButtonItem alloc] initWithCustomView:postButton];
    self.navigationItem.rightBarButtonItem = oPostButton;
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(0, 0, 62, 24)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    oCancelButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = oCancelButton;

    
    oPostButton.enabled = NO;
    oPostButton.image = [UIImage imageNamed:@"btn_post_off.png"];
    oPostButton.tintColor = [UIColor whiteColor];
    oCancelButton.image = [UIImage imageNamed:@"btn_cancel.png"];
    oCancelButton.tintColor = [UIColor whiteColor];

    
    selectVenueButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [selectVenueButton setTitle:@"ADD VENUE" forState:UIControlStateNormal];
    [selectVenueButton setBackgroundImage:[UIImage imageNamed:@"btn_photo_caption_page_blank.png"] forState:UIControlStateNormal];
    selectVenueButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:15.0];
    
    [oActivityIndicator hidesWhenStopped];
    oActivityIndicator.hidden = YES;
    oImageBorderView.layer.borderColor = [[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0] CGColor];
    oImageBorderView.layer.borderWidth = 0.8;
    
    oFBShareButton.selected = NO;
    oTwitterShareButton.selected = NO;
    
    oInsertCaptionTF.layer.borderColor = [[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0] CGColor];
    oInsertCaptionTF.layer.borderWidth = 1.5;
    oInsertCaptionTF.font = [UIFont fontWithName:@"CenturyGothic" size:14.0];
    
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([oInsertCaptionTF.text isEqualToString:@"Add your caption..."]) {
        oInsertCaptionTF.text = @"";
        oInsertCaptionTF.textColor = [UIColor blackColor];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ((textView.text.length > 69 && text.length > 0) || [text isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}


#pragma mark takePhotoDelegate

- (void)didTakePhoto:(UIImage*)image {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    UIImage *chosenImage = image;
    UIImage *croppedImage;
    
    //Camera is different in 4S and 5. Need to crop in different ways in order to make it square
    if (screenSize.height > 480.0) {
        croppedImage = [chosenImage squareImageWithImage:chosenImage scaledToSize:CGSizeMake(400, 400) cropSides:NO profilePic:NO];
    }
    else{
        croppedImage = [chosenImage squareImageWithImage:chosenImage scaledToSize:CGSizeMake(442, 442) cropSides:YES profilePic:NO];
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self displayEditorForImage:croppedImage];
    }];
    
    [self getVenuesFromFourSquare];
}

- (void)didCancelPhoto {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self.navigationController popToRootViewControllerAnimated:NO];
    photoTaken = NO;
}


#pragma Mark Aviary Photo Editor

- (void)displayEditorForImage:(UIImage *)imageToEdit{
    [AFOpenGLManager beginOpenGLLoad];
    
    self.editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [self.editorController setDelegate:self];
    [self setPhotoEditorCustomizationOptions];
    
    [self presentViewController:self.editorController animated:NO completion:nil];
    oImageView.image = imageToEdit;
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions{
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFOrientation, kAFAdjustments];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Disable Cropping
    [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
    [AFPhotoEditorCustomization setCropToolInvertEnabled:NO];
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setLeftNavigationBarButtonTitle:kAFLeftNavigationTitlePresetBack];
    [AFPhotoEditorCustomization setRightNavigationBarButtonTitle:kAFRightNavigationTitlePresetNext];

}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image{
    oImageView.image = image;
    [editor dismissViewControllerAnimated:YES completion:NULL];
    [self uploadPhoto:image];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor{
    _ME_WEAK
    [editor dismissViewControllerAnimated:NO completion:^{
        camViewController = [[CameraViewController alloc] init];
        camViewController.delegate = me;
        [me presentViewController:camViewController animated:NO completion:nil];
        photoTaken = YES;
    }];
}


- (void)uploadPhoto:(UIImage*)image{
    imageObject = [PFObject objectWithClassName:@"PostImage"];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd_hh-mm-ss"];
    
    if (imageData && [User currentUser].objectId) {
        imageObject[@"image"] = [PFFile fileWithName:[NSString stringWithFormat:@"%@_%@.png",[User currentUser].objectId,[df stringFromDate:[NSDate date]]] data:imageData];
        NSLog(@"Imagen: %@",((PFFile*)imageObject[@"image"]).name);
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
//    //Calculate uploading time and send to google analytics.
//    uploadInterval = 0;
//    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timer) userInfo:nil repeats:YES];
    
    _ME_WEAK
    [NetworkClient sharedInstance].image = image;
    [[NetworkClient sharedInstance] uploadPhoto:imageObject successBlock:^(NSString *response) {
        
        photoUploaded = YES;
        if (postButtonPressed) {
            [me post];
        }
        if (uploadCancelled) {
            [imageObject deleteInBackground];
        }
        
    } failBlock:^(NSString *requestErrorMsg) {
        //If image upload fails, alert user only if he pressed Post button. Otherwise try uploading again without warning.
        if (postButtonPressed) {
            [me.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Upload Photo" action:@"Upload failed" label:@"Failed" value:nil] build]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IMGUploadFailedNotification" object:image];
        }
        else{
            [me uploadPhoto:image];
        }
    }];
}
//
//- (void)timer{
//    //Google analytics takes 1000 and shows 1 sec, thats why I increment by 1000 every second.
//    uploadInterval = [NSNumber numberWithInteger:[uploadInterval integerValue] + 1000];
//    
//    //If uploading takes more than 1 minute, cancel and retry
//    if ([uploadInterval integerValue] >= 10000) {
//        [self cancelUpload];
//    }
//}

- (void)cancelUpload{
    if (!photoUploaded) {
        [[NetworkClient sharedInstance] cancelUpload];
        photoUploaded = NO;
    }
}

- (IBAction)postButtonPressed:(id)sender {
    postButtonPressed = YES;
    [locationManager stopUpdatingLocation];
    oPostButton.enabled = NO;
    oCancelButton.enabled = NO;
    oFBShareButton.enabled = NO;
    oTwitterShareButton.enabled = NO;
    selectVenueButton.enabled = NO;
    oInsertCaptionTF.editable = NO;
    
    UIImageWriteToSavedPhotosAlbum(oImageView.image, nil, nil, nil);
    
    if (photoUploaded) {
        [self post];
    }
    else{
        if (shareToFacebook) {
            [self postToFacebook];
        }
        else if (shareToTwitter) {
            [self postToTwitter];
        }
        else{
            HomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
            homeVC.uploadingPhoto = YES;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeVC];
            [self.revealViewController setFrontViewController:navController animated:NO];
        }
    }
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
    oInsertCaptionTF.hidden = NO;
    photoTaken = NO;
    uploadCancelled = YES;
    if (photoUploaded) {
        [imageObject deleteInBackground];
    }
    else{
        [self cancelUpload];
    }
}

- (void)post{
    //Create new post to store
    
    Post *newPost = [Post object];
    newPost.user = [User currentUser];
    if (oInsertCaptionTF.textColor == [UIColor blackColor] && ![oInsertCaptionTF.text isEqualToString:@"Add your caption..."]) {
        newPost.caption = oInsertCaptionTF.text;
    }
    else{
        newPost.caption = @" ";
    }
    newPost.likes = [[NSMutableArray alloc] init];
    newPost.likeable = true;
    newPost.numberOfLikes = [NSNumber numberWithInt:0];
    newPost.city = @"Chicago, IL";
    newPost[@"image"] = imageObject;
    
    //ADD WEEK OF COMPETITION TO THE POST
    NSCalendar*calObject = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    [calObject setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CDT"]];
    NSDateComponents* comp = [calObject components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger day = [comp weekday];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    if (day<=3) {
        dayComponent.day = 3-day;
    }
    else{
        dayComponent.day = 3-day+7;
    }
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"CDT"];
    //NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:[NSDate date]];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:[NSDate date]];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:[NSDate date]];
    NSDate *dateToBeIncremented = [calObject dateByAddingComponents:dayComponent toDate:destinationDate options:0];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: dateToBeIncremented];
    [components setHour: 14];
    [components setMinute: 00];
    [components setSecond: 00];
    
    NSDate *newDate = [gregorian dateFromComponents: components];
    newPost[@"week"] = newDate;
    
    [NetworkClient sharedInstance].post = newPost;
    [[NetworkClient sharedInstance] uploadPost:newPost inVenue:tagVenuesArray[venueIndex] successBlock:^(NSString *response) {
        postUploaded = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoUploadedNotification" object:nil];
        photoTaken = NO;
        oPostButton.enabled = NO;
        
    } failBlock:^(NSString *requestErrorMsg) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"POSTUploadFailedNotification" object:nil];
    }];
    
    if (shareToFacebook) {
        [self postToFacebook];
    }
    else if (shareToTwitter) {
        [self postToTwitter];
    }
    else{
        HomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
        homeVC.uploadingPhoto = YES;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeVC];
        [self.revealViewController setFrontViewController:navController animated:NO];
    }
    
}

- (IBAction)shareToTwitter:(id)sender {
    if (shareToTwitter == YES) {
        shareToTwitter = NO;
        NSLog(@"TW SHARE no");
        oTwitterShareButton.selected = NO;
    }
    else{
        shareToTwitter = YES;
        oTwitterShareButton.selected = YES;
        NSLog(@"TW SHARE YES");
    }
}

- (IBAction)shareToFacebook:(id)sender {
    if (shareToFacebook == YES) {
        shareToFacebook = NO;
        NSLog(@"FB SHARE NO");
        oFBShareButton.selected = NO;
    }
    else{
        shareToFacebook = YES;
        NSLog(@"FB SHARE YES");
        oFBShareButton.selected = YES;
    }
}


- (void)postToFacebook{
    shareToFacebook = NO;
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Social" action:@"Facebook" label:@"Share" value:nil] build]];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        if (oInsertCaptionTF.textColor == [UIColor blackColor] && ![oInsertCaptionTF.text isEqualToString:@"Add your caption..."]) {
            [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"%@ #KrowdxChicago", oInsertCaptionTF.text]];
        }
        else{
            [mySLComposerSheet setInitialText:@"#KrowdxChicago"];
        }
        [mySLComposerSheet addImage:oImageView.image];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Successful");
                    break;
                default:
                    break;
            }
            if (shareToTwitter) {
                [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Social" action:@"Twitter" label:@"Share" value:nil] build]];
                [self postToTwitter];
            }
            else{
                HomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
                if (postUploaded) {
                   homeVC.uploadingPhoto = NO;
                }else{
                    homeVC.uploadingPhoto = YES;
                }
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeVC];
                [self.revealViewController setFrontViewController:navController animated:NO];
            }
        }];
        [self presentViewController:mySLComposerSheet animated:YES completion:^{
            
        }];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Facebook account not linked" message:@"In order to be able to share photos to Facebook, you need to link your facebook account. Please go to Settings-Facebook and log in with your Facebook account." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
}

- (void)postToTwitter{
    shareToTwitter = NO;

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        if (oInsertCaptionTF.textColor == [UIColor blackColor] && ![oInsertCaptionTF.text isEqualToString:@"Add your caption..."]) {
            [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"%@ #KrowdxChicago", oInsertCaptionTF.text]];
        }
        else{
            [mySLComposerSheet setInitialText:@"#KrowdxChicago"];
        }
        [mySLComposerSheet addImage:oImageView.image];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Successful");
                    break;
                default:
                    break;
            }
            HomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
            if (postUploaded) {
                homeVC.uploadingPhoto = NO;
            }else{
                homeVC.uploadingPhoto = YES;
            }            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeVC];
            [self.revealViewController setFrontViewController:navController animated:NO];
        }];
        [self presentViewController:mySLComposerSheet animated:YES completion:^{
        }];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Twitter account not linked" message:@"In order to be able to share photos to Twitter, you need to link your twitter account. Please go to Settings-Twitter and log in with your Twitter account." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
}


#pragma mark - location call back method

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    userLocation = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
}

- (void)getVenuesFromFourSquare{
    queryPartOne = @"https://api.foursquare.com/v2/venues/search?ll=";
    queryPartThree = @"&categoryId=4d4b7105d754a06376d81259,4bf58dd8d48988d14e941735,4bf58dd8d48988d107941735,4bf58dd8d48988d142941735,4bf58dd8d48988d1df931735,4bf58dd8d48988d16b941735,4bf58dd8d48988d144941735,4bf58dd8d48988d145941735,4bf58dd8d48988d146941735,4bf58dd8d48988d154941735,4bf58dd8d48988d147941735,4e0e22f5a56208c4ea9a85a0,4bf58dd8d48988d109941735,4bf58dd8d48988d10c941735,4bf58dd8d48988d155941735,4bf58dd8d48988d10d941735,4bf58dd8d48988d10f941735,4bf58dd8d48988d10e941735,4bf58dd8d48988d110941735,4bf58dd8d48988d111941735,4bf58dd8d48988d113941735,4bf58dd8d48988d1be941735,4bf58dd8d48988d1c0941735,4bf58dd8d48988d1c1941735,4bf58dd8d48988d157941735,4eb1bfa43b7b52c0e1adc2e8,4bf58dd8d48988d1ca941735,4bf58dd8d48988d1ce941735,4bf58dd8d48988d150941735,4bf58dd8d48988d1cc941735,4bf58dd8d48988d1d2941735,4bf58dd8d48988d1db931735,4bf58dd8d48988d14b941735&intent=browse&radius=75&client_id=XHQJ4Y4PZ0V0PZO2ASBR4FGJPUPFE4VYSH2UY0JEVZLIJRNG&client_secret=B013BVFMOTYIR1JMR3ARP14F2YVCOVUAXSZSM5JSOKEZRD1M&v=20130815";
    
    //queryPartThree =@"&intent=browse&radius=400&client_id=XHQJ4Y4PZ0V0PZO2ASBR4FGJPUPFE4VYSH2UY0JEVZLIJRNG&client_secret=B013BVFMOTYIR1JMR3ARP14F2YVCOVUAXSZSM5JSOKEZRD1M&v=20130815";
    
    queryTotal = [NSString stringWithFormat:@"%@%@%@",queryPartOne,userLocation, queryPartThree];
    
    NSURL *url = [NSURL URLWithString:queryTotal];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (data) {
             [venueTitlesArray removeAllObjects];
             [venueIDArray removeAllObjects];
             queryDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
             tagVenuesArray = [[queryDictionary objectForKey:@"response"] objectForKey:@"venues"];
             
             for (int iCounter=0; iCounter < tagVenuesArray.count; iCounter ++) {
                 [venueTitlesArray addObject:tagVenuesArray[iCounter][@"name"]];
                 [venueIDArray addObject:tagVenuesArray[iCounter][@"id"]];
             }
         }

     }];
}

#pragma mark - Show UIPickerView with Foursquare Data
- (IBAction)showPickerView:(id)sender {
    if (venueIDArray.count > 0) {
        selectVenueButton.enabled = NO;
        [self.view endEditing:YES];
        [self showActionPickerView];
    }
    else{
        [[[UIAlertView alloc]initWithTitle:@"Krowdx user not in nightlife venue" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

        //BOOL locationAllowed = [CLLocationManager authorizationStatus];
       // NSLog(@"%u",[CLLocationManager authorizationStatus]);
        if ([CLLocationManager authorizationStatus] !=kCLAuthorizationStatusAuthorized) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services is Disabled" message:@"You will only be able to post a photo on Krowdx if you tag the venue where you took it. For that reason, location services needs to be enabled. Please go to Settings-Privacy-LocationServices and turn it on for Krowdx." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        [self getVenuesFromFourSquare];
    }

}

- (void)showActionPickerView{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 35, 320, 180);
    
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [actionSheet addSubview:pickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Done"]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(confirmVenue:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(75, 205, 180,45)];
    imageView.image = [UIImage imageNamed:@"poweredByFoursquare_gray.png"];
    [actionSheet addSubview:imageView];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [venueTitlesArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return[venueTitlesArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)_pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //venueIndex = row;
}

- (void)confirmVenue:(UISegmentedControl*)sender{
    UIActionSheet *actionSheet = (UIActionSheet*)[sender superview];    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        venueIndex = [((UIPickerView*)actionSheet.subviews[0]) selectedRowInComponent:0];
    }
    else{
      venueIndex = [((UIPickerView*)actionSheet.subviews[1]) selectedRowInComponent:0];
    }
    
    if ([venueIDArray count]>0) {
        oPostButton.enabled = YES;
        [postButton setBackgroundImage:[UIImage imageNamed:@"btn_post_on.png"] forState:UIControlStateNormal];
        oPostButton = [[UIBarButtonItem alloc] initWithCustomView:postButton];
        selectVenueButton.enabled = YES;
        
        if (!venueIndex) {
            venueIndex = 0;
        }
        selectVenueButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
        [selectVenueButton setTitle:[[venueTitlesArray objectAtIndex:venueIndex] uppercaseString] forState:UIControlStateNormal];
        [selectVenueButton setBackgroundImage:[UIImage imageNamed:@"btn_photo_caption_page__white.png"] forState:UIControlStateNormal];
    }
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [oInsertCaptionTF resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
