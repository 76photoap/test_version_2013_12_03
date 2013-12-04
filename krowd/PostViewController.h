

#import <UIKit/UIKit.h>
#import "AFPhotoEditorController.h"
#import <CoreLocation/CoreLocation.h>
#import "PostPhotoDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "SWRevealViewController.h"

@interface PostViewController : UIViewController <AFPhotoEditorControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, PostPhotoDelegate, SWRevealViewControllerDelegate>

@property (strong, nonatomic) id tracker;


@end
