
#import <Parse/Parse.h>
#import "FeedViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface TrendingPostsViewController : FeedViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
