
#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "LoginDelegate.h"
#import "SWRevealViewController.h"

@interface SettingsViewController : UITableViewController <UITextFieldDelegate, LoginDelegate, SWRevealViewControllerDelegate>

@property (strong, nonatomic) id tracker;


@end
