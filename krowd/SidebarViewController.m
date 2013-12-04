//
//  SidebarViewController.m
//  SidebarDemo
//
//  Created by Simon on 29/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "SidebarViewController.h"
#import "OtherTrendingViewController.h"
#import "SWRevealViewController.h"
#import "SearchCell.h"
#import "VenueViewController.h"
#import "HomeViewController.h"
#import "UserProfViewController.h"

@interface SidebarViewController ()
{
    NSMutableArray *searchResults;
    __weak IBOutlet UISearchBar *oSearchBar;
    NSString *typeOfResult;
    BOOL search;
}
@property (nonatomic, strong) NSArray *menuItems;


@end

@implementation SidebarViewController

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    searchResults = [[NSMutableArray alloc] initWithCapacity:10];
    self.view.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:20./255.0 blue:20./255.0 alpha:1.0];
    //self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0];
    
    _menuItems = @[@"profile",@"wall", @"feeds", @"city", @"following",@"trendings", @"trendPosts", @"trendVenues", @"trendUsers"];
    search = YES;

    [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"searchBarBackground.png"]];
    
    //iOS 7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        //[oSearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchBarTFBackground.png"] forState:UIControlStateNormal];
    }
    
    //iOS 6
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        
        UIBarButtonItem *searchBarButton = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
        [searchBarButton setBackgroundImage:[UIImage imageNamed:@"cancelButtonSearchBar.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [searchBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:27.0/255.0 green:160.0/255.0 blue:206.0/255.0 alpha:1.0],UITextAttributeTextColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)],UITextAttributeTextShadowOffset,[UIFont fontWithName:@"CenturyGothic" size:17.0],UITextAttributeFont,nil] forState:UIControlStateNormal];
        
        for (UIView *searchBarSubview in [oSearchBar subviews]) {
            
            if ([searchBarSubview isKindOfClass:[UITextField class]]) {
                [(UITextField *)searchBarSubview setBackground:[UIImage imageNamed:@"searchBarTFBackground.png"]];
                [(UITextField*)searchBarSubview setFont:[UIFont fontWithName:@"CenturyGothic" size:15.0]];
            }
        }
    }
}


- (void)viewDidAppear:(BOOL)animated{
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height <= 480.0) {
        self.tableView.frame = CGRectMake(0,67,320,413);

    }

}

- (void)viewDidDisappear:(BOOL)animated{
    [self.searchDisplayController setActive:NO];
    [searchResults removeAllObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    }
    else{
       return [self.menuItems count]; 
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    UITableViewCell *cell;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = (SearchCell*)[tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil];
            cell = (SearchCell*)[nib objectAtIndex:0];
            
        }
        ((SearchCell*)cell).oNameLabel.text = [searchResults objectAtIndex:indexPath.row][@"name"];
        ((SearchCell*)cell).oUsernameLabel.text = [searchResults objectAtIndex:indexPath.row][@"username"];
    }
    else{
        NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIView *cellView;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            cellView = (UIView*)cell.subviews[0];
        }
        else{
            cellView = ((UIView*)(UIView*)cell.subviews[0]).subviews[0];
        }
        
        if (indexPath.row == 2 || indexPath.row == 5) {
            ((UILabel*)cellView.subviews[0]).font = [UIFont fontWithName:@"CenturyGothic" size:19.0];
        }
        else{
            ((UIButton*)cellView.subviews[0]).titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2 || indexPath.row == 5) {
        return 55;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([[searchResults objectAtIndex:indexPath.row] isKindOfClass:[User class]]) {
            [self performSegueWithIdentifier:@"goToProfile" sender:indexPath];
        }
        else{
            [self performSegueWithIdentifier:@"goToVenue" sender:indexPath];
        }
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // Set the photo if it navigates to the PhotoView
    if ([segue.identifier isEqualToString:@"trendVenues"]) {
        OtherTrendingViewController *trendingController = (OtherTrendingViewController*)segue.destinationViewController;
        trendingController.typeOfTrending = @"Venues";
    }
    else if ([segue.identifier isEqualToString:@"trendUsers"]) {
        OtherTrendingViewController *trendingController = (OtherTrendingViewController*)segue.destinationViewController;
        trendingController.typeOfTrending = @"Users";
    }
    else if ([segue.identifier isEqualToString:@"goToProfile"] && searchResults.count >0){
        UserProfViewController *userProfileController = segue.destinationViewController;
        userProfileController.userToShow = [searchResults objectAtIndex:((NSIndexPath*)sender).row];
    }
    else if ([segue.identifier isEqualToString:@"goToVenue"] && searchResults.count >0){
        VenueViewController *venueController = segue.destinationViewController;
        venueController.venueToShow = [searchResults objectAtIndex:((NSIndexPath*)sender).row];
    }
    else if ([segue.identifier isEqualToString:@"following"]){
        HomeViewController *followingController = segue.destinationViewController;
        followingController.following = YES;
    }
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchResults removeAllObjects];
}

#pragma mark Content Filtering
-(void)searchResults:(NSString*)searchString{
    searchResults = [[NSMutableArray alloc] initWithCapacity:20];
    PFQuery *userQuery = [User query];
    [userQuery whereKey:@"name" hasPrefix:[NSString stringWithFormat:@"%@",[searchString capitalizedString]]];
    [userQuery whereKey:@"currentLocation" equalTo:[User currentUser].currentLocation];
    
    PFQuery *usernameQuery = [User query];
    [usernameQuery whereKey:@"username" hasPrefix:[NSString stringWithFormat:@"%@",searchString]];
    [usernameQuery whereKey:@"currentLocation" equalTo:[User currentUser].currentLocation];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userQuery,usernameQuery,nil]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [searchResults addObjectsFromArray:objects];
        
        [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
        
        PFQuery *venueQuery = [PFQuery queryWithClassName:@"Venue"];
        [venueQuery whereKey:@"name" hasPrefix:[NSString stringWithFormat:@"%@",[searchString capitalizedString]]];
        venueQuery.limit = 15;
        
        [venueQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [searchResults addObjectsFromArray:objects];
            [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];

        }];

    }];
    
}

- (void)reloadTable{
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if (search) {
        [self searchResults:searchString];
        search = NO;
        return YES;
    }
    else{
        search = YES;
        return NO;
    }
}



- (void)reloadFeed{
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end
