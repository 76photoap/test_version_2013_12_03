
#import "FeedViewController.h"

@interface FollowersViewController : FeedViewController

@property (strong, nonatomic)NSString *typeOfList;
@property (strong, nonatomic)PFUser *user;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic)Post *selectedPost;

@end
