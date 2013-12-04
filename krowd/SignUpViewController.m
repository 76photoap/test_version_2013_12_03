
#import "SignUpViewController.h"
#import "TrendingPostsViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "PolicyViewController.h"

@interface SignUpViewController ()
{
    __weak IBOutlet UITextField *oLocationTextField;
    __weak IBOutlet UITextField *oUsernameTF;
    __weak IBOutlet UIButton *oSignUpButton;
    __weak IBOutlet UILabel *oUsernameLabel;
    CLLocationManager *locationManager;
    __weak IBOutlet UILabel *oLabel;
    __weak IBOutlet UILabel *oTitle2Label;
    __weak IBOutlet UIButton *oPrivacyButton;
    __weak IBOutlet UIButton *oTermsButton;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIButton *cityButton;
    UIActivityIndicatorView *cityIndicator;
}

- (IBAction)signUp:(id)sender;
- (IBAction)dismissKeyboard:(UIGestureRecognizer*)sender;
@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Google Analytics
    self.tracker = [[GAI sharedInstance] defaultTracker];
    [self.tracker set:kGAIScreenName value:@"Sign Up Screen"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Krowd_background.png"]];
    oSignUpButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
    oUsernameTF.font = [UIFont fontWithName:@"CenturyGothic" size:14.0];
    oLocationTextField.font = [UIFont fontWithName:@"CenturyGothic" size:14.0];
    oLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    oTitle2Label.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
    oUsernameLabel.font =[UIFont fontWithName:@"CenturyGothic" size:16.0];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    oTermsButton.titleLabel.font =[UIFont fontWithName:@"CenturyGothic" size:11.0];
    oTermsButton.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Terms of Service" attributes:underlineAttribute];
    [oTermsButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Terms of Service" attributes:underlineAttribute] forState:UIControlStateNormal];
    
    oPrivacyButton.titleLabel.font =[UIFont fontWithName:@"CenturyGothic" size:11.0];
    [oPrivacyButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Privacy Policy" attributes:underlineAttribute] forState:UIControlStateNormal];
}
   /* cityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cityIndicator.frame = CGRectMake(4, 4, cityIndicator.frame.size.width, cityIndicator.frame.size.height);
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
    
    [cityIndicator startAnimating];
    [cityButton setImage:nil forState:UIControlStateNormal];
    [cityButton addSubview:cityIndicator];
    
    [self performSelector:@selector(checkLocationServices) withObject:nil afterDelay:10.0];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [locationManager stopUpdatingLocation];
    [cityIndicator stopAnimating];
    [cityIndicator removeFromSuperview];
    [cityButton setImage:[UIImage imageNamed:@"updateIcon.png"] forState:UIControlStateNormal];
    
    //CLLocation *location2 = [[CLLocation alloc] initWithLatitude:41.894355 longitude:-87.635114];
    CLLocation *location = [locations lastObject];
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString *city, *state;
        if (placemarks.count > 0) {
            city = [[placemarks objectAtIndex:0] locality];
            state = [[placemarks objectAtIndex:0] administrativeArea];
            [User currentUser].currentLocation = [NSString stringWithFormat:@"%@, %@",city,state];
            [User currentUser].cityOfResidence = [NSString stringWithFormat:@"%@, %@",city,state];
            oLocationTextField.text = [NSString stringWithFormat:@"%@, %@",city,state];
            oSignUpButton.enabled = YES;
        }
        else{
            city = @"";
            state = @"";
        }
    }];
    
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)updateLocation:(id)sender{
    
    if ([CLLocationManager authorizationStatus] !=kCLAuthorizationStatusAuthorized) {
        [cityIndicator stopAnimating];
        [cityIndicator removeFromSuperview];
        [cityButton setImage:[UIImage imageNamed:@"updateIcon.png"] forState:UIControlStateNormal];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services is Disabled" message:@"Krowdx is a competitive photo-sharing app that allows users to upload nightlife pictures and see the most ""liked"" photos, venues, and users in their city. For that reason, user location is required. To re-enable location services please go to Settings-Privacy-LocationServices and turn it on for Krowdx." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    [locationManager startUpdatingLocation];
}

- (void)checkLocationServices{
    if ([CLLocationManager authorizationStatus] !=kCLAuthorizationStatusAuthorized) {
        [cityIndicator stopAnimating];
        [cityIndicator removeFromSuperview];
        [cityButton setImage:[UIImage imageNamed:@"updateIcon.png"] forState:UIControlStateNormal];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services is Disabled" message:@"Krowdx is a competitive photo-sharing app that allows users to upload nightlife pictures and see the most ""liked"" photos, venues, and users in their city. For that reason, user location is required. To re-enable location services please go to Settings-Privacy-LocationServices and turn it on for Krowdx." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)dismissKeyboard:(id)sender {
    [oUsernameTF resignFirstResponder];
}


- (IBAction)signUp:(id)sender {
    if ([oUsernameTF.text length] > 0 && !([oUsernameTF.text isEqualToString:@" "])) {
        PFQuery *usernameQuery = [User query];
        [usernameQuery whereKey:@"username" equalTo:oUsernameTF.text];
        PFObject *result = [usernameQuery getFirstObject];
        if (result || ([oUsernameTF.text isEqualToString:@"undefined"])) {
            oUsernameTF.text = @"";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry.." message:@"The username you entered already exists. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            [activityIndicator startAnimating];
            [User currentUser].username = oUsernameTF.text;
            [User currentUser][@"hasUsername"] = [NSNumber numberWithBool:YES];
            [User currentUser].currentLocation = @"Chicago, IL";
            [User currentUser].cityOfResidence = @"Chicago, IL";
            [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [activityIndicator stopAnimating];
                if (!succeeded) {
                    [[User currentUser] saveEventually];
                }
            } ];
            [self dismissViewControllerAnimated:NO completion:^{[self.delegate userDidSignUp];}];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username required" message:@"Please enter a username." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"privacyPolicy"]) {
        PolicyViewController *policyViewController = segue.destinationViewController;
        policyViewController.type = @"PrivacyPolicy2";
    }
    else if ([segue.identifier isEqualToString:@"termsOfService"]) {
        PolicyViewController *policyViewController = segue.destinationViewController;
        policyViewController.type = @"TermsOfService2";
    }
}

@end
