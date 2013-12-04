

#import <UIKit/UIKit.h>
#import "SignUpDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "LoginDelegate.h"

@interface LoginViewController : UIViewController <SignUpDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) id tracker;
@property (assign, nonatomic) BOOL firstLogin;
@property (weak, nonatomic) id <LoginDelegate> delegate;

@end
