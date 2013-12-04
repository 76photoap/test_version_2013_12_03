
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FeedViewController.h"


@interface HomeViewController : FeedViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic)BOOL following;
@property (nonatomic)BOOL uploadingPhoto;

@end
