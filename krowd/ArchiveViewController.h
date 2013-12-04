

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface ArchiveViewController : UITableViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) id tracker;

@end
