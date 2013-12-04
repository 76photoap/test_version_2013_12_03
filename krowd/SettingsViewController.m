

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "PolicyViewController.h"
#import "LoginViewController.h"
#import "UserProfViewController.h"
#import "TrendingPostsViewController.h"
#import "SidebarViewController.h"

@interface SettingsViewController ()
{
    UITextField *selectedTF;
    UIBarButtonItem *doneBarButton, *cancelBarButton;
    UIButton *doneButton, *cancelButton;

}

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[User currentUser] refresh];
    //Google Analytics
    self.tracker = [[GAI sharedInstance] defaultTracker];
    [self.tracker set:kGAIScreenName value:@"Settings Screen"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    self.title = @"SETTINGS";
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:240.0/255.0 green:238./255.0 blue:239./255.0 alpha:1.0];
    
    _menuItems = @[@"Title1",@"Username", @"Email",@"Title2", @"TermsService", @"PrivacyPolicy", @"Title3",@"LogOut"];
}

- (void)viewWillAppear:(BOOL)animated{

    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake(0, 0, 62, 24)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[UIImage imageNamed:@"btn_photo_caption_page_blank.png"] forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    [doneButton setTitleColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
    doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(0, 0, 62, 24)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_photo_caption_page_blank.png"] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    
    cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;

    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIView *cellView;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        cellView = (UIView*)cell.subviews[0];
    }
    else{
        cellView = ((UIView*)(UIView*)cell.subviews[0]).subviews[0];
    }
    
    switch (indexPath.row) {
        case 0:
            ((UILabel*)cellView.subviews[0]).font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
            break;
        case 1:
            ((UITextField*)cellView.subviews[0]).font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
            if ([User currentUser].username) {
                ((UITextField*)cellView.subviews[0]).text = [NSString stringWithFormat:@"%@",[User currentUser].username];
            }
            break;
        case 2:
            ((UITextField*)cellView.subviews[0]).font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
            if ([User currentUser].email) {
                ((UITextField*)cellView.subviews[0]).text = [NSString stringWithFormat:@"%@",[User currentUser].email];
                ((UITextField*)cellView.subviews[0]).enabled = NO;
            }
            break;
        /*case 3:
            ((UITextField*)cellView.subviews[0]).font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
            if ([User currentUser].currentLocation) {
                ((UITextField*)cellView.subviews[0]).text = [NSString stringWithFormat:@"Krowdx City:  %@",[User currentUser].currentLocation];
            }
            else{
                ((UITextField*)cellView.subviews[0]).text = [NSString stringWithFormat:@"Krowdx City:"];
            }
            break;*/
        default:
            for (UIView* subview in cellView.subviews) {
                if ([subview isKindOfClass:[UILabel class]] && subview.tag == 2) {
                    ((UILabel*)subview).font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
                }
            }
            break;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 50;
    }
    else if(indexPath.row == 3 || indexPath.row == 6) {
        return 30;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 || indexPath.row == 3) {
        [selectedTF resignFirstResponder];
    }
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    selectedTF = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // Set the photo if it navigates to the PhotoView
    if ([segue.identifier isEqualToString:@"login"]) {
        TrendingPostsViewController *trendingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"trendingPosts"];

        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:trendingVC];
        [self.revealViewController setFrontViewController:navController animated:NO];
        
        LoginViewController *loginController = segue.destinationViewController;
        loginController.firstLogin = NO;
        loginController.delegate = self;
        [User logOut];
    }
    else if ([segue.identifier isEqualToString:@"privacyPolicy"]) {
        PolicyViewController *policyViewController = segue.destinationViewController;
        policyViewController.type = @"PrivacyPolicy";
    }
    else if ([segue.identifier isEqualToString:@"termsOfService"]) {
        PolicyViewController *policyViewController = segue.destinationViewController;
        policyViewController.type = @"TermsOfService";
    }

}


- (IBAction)cancel:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)done:(id)sender{
    UITableViewCell *usernameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITableViewCell *emailCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UIView *cellView,*cellView2;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        cellView = (UIView*)usernameCell.subviews[0];
        cellView2 = (UIView*)emailCell.subviews[0];
    }
    else{
        cellView = ((UIView*)(UIView*)usernameCell.subviews[0]).subviews[0];
        cellView2 = ((UIView*)(UIView*)emailCell.subviews[0]).subviews[0];
    }
    
    //Check if username already exists
    if ([((UITextField*)cellView.subviews[0]).text length] > 0 && !([((UITextField*)cellView.subviews[0]).text isEqualToString:@" "])) {
        PFQuery *usernameQuery = [User query];
        [usernameQuery whereKey:@"username" equalTo:((UITextField*)cellView.subviews[0]).text];
        PFObject *result = [usernameQuery getFirstObject];
        if ((result && ![result[@"username"]isEqualToString:[User currentUser].username]) || ([((UITextField*)cellView.subviews[0]).text isEqualToString:@"undefined"])) {
            ((UITextField*)cellView.subviews[0]).text = [User currentUser].username;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry.." message:@"The username you entered already exists. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            [User currentUser].username = ((UITextField*)cellView.subviews[0]).text;
            [User currentUser].email = ((UITextField*)cellView2.subviews[0]).text;
            [[User currentUser] saveInBackground];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (void)didLogin{
    ((UserProfViewController*)self.navigationController.viewControllers[0]).userToShow = nil;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
