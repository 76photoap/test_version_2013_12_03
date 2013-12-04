
#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()
{
    __weak IBOutlet UIButton *oFBLoginButton;
    __weak IBOutlet UILabel *oUsernameLabel;
    __weak IBOutlet UIActivityIndicatorView *oActivityIndicator;
    UIImageView *oImageView;
    UIImageView *secondImageView;
    int slide;
    CGSize screenSize;
}

- (IBAction)facebookLogIn:(id)sender;
- (IBAction)swipeRight:(UISwipeGestureRecognizer*)sender;
- (IBAction)swipeLeft:(UISwipeGestureRecognizer*)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    screenSize = [[UIScreen mainScreen] bounds].size;
    
    [super viewDidLoad];
    slide = 0;
    //Google Analytics
    self.tracker = [[GAI sharedInstance] defaultTracker];
    [self.tracker set:kGAIScreenName value:@"Login Screen"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    oActivityIndicator.hidesWhenStopped = YES;
   
    oImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,10,320,screenSize.height-20)];
    [self.view addSubview:oImageView];
    
    secondImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320,10,320,screenSize.height-20)];
    [self.view addSubview:secondImageView];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(101, screenSize.height-55, 119, 39)];
    [loginButton setImage:[UIImage imageNamed:@"fbLogin.png"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(facebookLogIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    
    if (screenSize.height <= 480.0) {
        oImageView.image = [UIImage imageNamed:@"Intro_Slide_1_4s.png"];
    }
    else{
        oImageView.image = [UIImage imageNamed:@"Intro_Slide_1.png"];
    }
    
    if ([User currentUser]) {
        if (![User currentUser][@"hasUsername"]) {
            [User logOut];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    //If user exists but has no username, choose username. Otherwise sign up.
    /*if ([User currentUser] && ([[User currentUser].username isEqualToString:[NSString stringWithFormat:@"%@",[User currentUser][@"profile"][@"facebookId"]]] || ![User currentUser][@"hasUsername"])) {
        [self chooseUsername];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)facebookLogIn:(id)sender {
    oFBLoginButton.enabled = NO;
    [self logIn];
}

- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender {
    switch (slide) {
        case 1:
            if (screenSize.height <= 480.0) {
                [UIView animateWithDuration:0.4 animations:^{
                    secondImageView.center = CGPointMake(480, secondImageView.center.y); // or wherever
                }];
                oImageView.frame = CGRectMake(-320, 10, 320, screenSize.height-20);
                oImageView.image = [UIImage imageNamed:@"Intro_Slide_1_4s.png"];
                [UIView animateWithDuration:0.4 animations:^{
                    oImageView.center = CGPointMake(160, oImageView.center.y); // or wherever
                }];
            }
            else{
                [UIView animateWithDuration:0.4 animations:^{
                    secondImageView.center = CGPointMake(480, secondImageView.center.y); // or wherever
                }];
                oImageView.frame = CGRectMake(-320, 10, 320, screenSize.height-20);
                oImageView.image = [UIImage imageNamed:@"Intro_Slide_1.png"];
                [UIView animateWithDuration:0.4 animations:^{
                    oImageView.center = CGPointMake(160, oImageView.center.y); // or wherever
                }];
            }
            slide--;
            break;
        case 2:
            if (screenSize.height <= 480.0) {
                [UIView animateWithDuration:0.4 animations:^{
                    oImageView.center = CGPointMake(480, oImageView.center.y); // or wherever
                }];
                secondImageView.frame = CGRectMake(-320, 10, 320, screenSize.height-20);
                secondImageView.image = [UIImage imageNamed:@"Intro_Slide_2_4s.png"];
                [UIView animateWithDuration:0.4 animations:^{
                    secondImageView.center = CGPointMake(160, secondImageView.center.y); // or wherever
                }];
            }
            else{
                [UIView animateWithDuration:0.4 animations:^{
                    oImageView.center = CGPointMake(480, oImageView.center.y); // or wherever
                }];
                secondImageView.frame = CGRectMake(-320, 10, 320, screenSize.height-20);
                secondImageView.image = [UIImage imageNamed:@"Intro_Slide_2.png"];
                [UIView animateWithDuration:0.4 animations:^{
                    secondImageView.center = CGPointMake(160, secondImageView.center.y); // or wherever
                }];
            }
            slide--;
            break;
        default:
            break;
    }

}

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
    switch (slide) {
        case 0:
            if (screenSize.height <= 480.0) {
                [UIView animateWithDuration:0.4 animations:^{
                    oImageView.center = CGPointMake(-160, oImageView.center.y); // or wherever
                }];
                secondImageView.frame = CGRectMake(320, 10, 320, screenSize.height-20);
                secondImageView.image = [UIImage imageNamed:@"Intro_Slide_2_4s.png"];
                [UIView animateWithDuration:0.4 animations:^{
                    secondImageView.center = CGPointMake(160, secondImageView.center.y); // or wherever
                }];
            }
            else{
                [UIView animateWithDuration:0.4 animations:^{
                    oImageView.center = CGPointMake(-160, oImageView.center.y); // or wherever
                }];
                secondImageView.frame = CGRectMake(320, 10, 320, screenSize.height-20);
                secondImageView.image = [UIImage imageNamed:@"Intro_Slide_2.png"];
                [UIView animateWithDuration:0.4 animations:^{
                    secondImageView.center = CGPointMake(160, secondImageView.center.y); // or wherever
                }];
            }
            slide++;
            break;
        case 1:
            if (screenSize.height <= 480.0) {
                [UIView animateWithDuration:0.4 animations:^{
                    secondImageView.center = CGPointMake(-160, secondImageView.center.y); // or wherever
                }];
                oImageView.frame = CGRectMake(320, 10, 320, screenSize.height-20);
                oImageView.image = [UIImage imageNamed:@"Intro_Slide_3_4s.png"];
                [UIView animateWithDuration:0.4 animations:^{
                    oImageView.center = CGPointMake(160, oImageView.center.y); // or wherever
                }];
            }
            else{
                [UIView animateWithDuration:0.4 animations:^{
                    secondImageView.center = CGPointMake(-160, secondImageView.center.y); // or wherever
                }];
                oImageView.frame = CGRectMake(320, 10, 320, screenSize.height-20);
                oImageView.image = [UIImage imageNamed:@"Intro_Slide_3.png"];
                [UIView animateWithDuration:0.4 animations:^{
                    oImageView.center = CGPointMake(160, oImageView.center.y); // or wherever
                }];
            }
            slide++;
            break;
        default:
            break;
    }
}

- (void)logIn{
    [oActivityIndicator startAnimating];

    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. An error occurred: %@", error);
            [self fbResync];
            [self logIn];
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self connectToFB];
        } else if([user.username isEqualToString:[NSString stringWithFormat:@"%@",[User currentUser][@"profile"][@"facebookId"]]] || ![User currentUser][@"hasUsername"]) {
            [self chooseUsername];
        } else {
            NSLog(@"User with facebook logged in!");
            [oActivityIndicator stopAnimating];
            if (self.firstLogin) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
            else{
                [self dismissViewControllerAnimated:NO completion:^{
                    [self.delegate didLogin];
                }];
            }
        }
    }];
}

- (void)chooseUsername{

    [oActivityIndicator stopAnimating];
    [self performSegueWithIdentifier:@"signUp" sender:self];
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
            [User currentUser].username = [NSString stringWithFormat:@"%@",facebookID];
            [User currentUser][@"hasUsername"] = [NSNumber numberWithBool:NO];
            [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self chooseUsername];
                }
                else{
                    //[[User currentUser] saveEventually];
                }
            } ];
            
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"]) {
            NSLog(@"The facebook session was invalidated");
        }
        else{
            NSLog(@"Some other error: %@", error);
        }
    }];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"signUp"]) {
        SignUpViewController *signViewController = segue.destinationViewController;
        signViewController.delegate = self;
    }
}




- (void)fbResync{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) &&
        (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 &&
            (account = [fbAccounts objectAtIndex:0])){
            
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    
                }
            }];
        }
    }
}

- (void)userDidSignUp{
    if (self.firstLogin) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate didLogin];
        }];
        
    }
}



@end
