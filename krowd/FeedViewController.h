

#import <Parse/Parse.h>
#import "User.h"
#import "LoginViewController.h"
#import "Post.h"
#import "PostCell.h"
#import "OperationSingleton.h"
#import "SWRevealViewController.h"
#import "FloatingCamera.h"
#import "DidSendReportDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#define _ME_WEAK  __weak typeof(self) me = self;

@interface FeedViewController : PFQueryTableViewController <NSURLConnectionDataDelegate,UIActionSheetDelegate, DidSendReportDelegate, CLLocationManagerDelegate>
{
    FloatingCamera *floatingCamera;
}

@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) NSNotificationCenter *notificationCenter;
@property (strong, nonatomic) Post *postToDelete;
@property (strong, nonatomic) id tracker;

- (void)connectToFB;
- (void)loadUserInfo;
- (void)removeTitle;
-(void)newPost;
- (void)loadImages;
- (void)reloadFeed;

@end
