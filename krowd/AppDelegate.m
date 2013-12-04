
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Post.h"
#import "Venue.h"
#import "FloatingCamera.h"
#import "GAI.h"
#import "NSURL+Attributes.h"
#import "GAITracker.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [User registerSubclass];
    [Post registerSubclass];
    [Venue registerSubclass];
    [Parse setApplicationId:@"d94nqmd0rwtRC28fSu5sA7xTpRq7Uxdr5Q1evo7M"
                  clientKey:@"2rjtVns6odV8mKNpMnJKWH7JDk0xcIQql9fSzQeg"];
    [PFFacebookUtils initializeFacebook];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Krowd_Nav_7.png"] forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont       fontWithName:@"Avenir" size:17], NSFontAttributeName,[UIColor colorWithRed:0/255.0 green:113/255.0 blue:188/255.0 alpha:1.0], NSForegroundColorAttributeName, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0]];
   
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        UIImage* backImage = [[UIImage imageNamed:@"backButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
   /* else{
        [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"backButton.png"]];
        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backButton.png"]];
    }*/
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000) forBarMetrics:UIBarMetricsDefault];
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    //Create directory for avatar images
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *imagesPath = [cachesDirectory stringByAppendingPathComponent:@"/images/"];
    NSString* path = [imagesPath stringByAppendingPathComponent:@"/avatars"];
 
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSURL fileURLWithPath:imagesPath] addSkipBackupAttributeToItem];
        [[NSURL fileURLWithPath:path] addSkipBackupAttributeToItem];
        [[NSURL fileURLWithPath:cachesDirectory] addSkipBackupAttributeToItem];
    }
    
    //GoogleAnalytics
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    id<GAITracker> tracker;
#ifdef TEST
    tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-44945302-1"];
#else
    tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-44945302-2"];
#endif
    NSLog(@"%@",tracker);
    
    /*FloatingCamera *floatingCamera = [[FloatingCamera alloc] initWithFrame:CGRectMake(260, 70, 60, 60)];
    [self.window addSubview:floatingCamera];
    [self.window bringSubviewToFront:floatingCamera];
*/
    
    return YES;
}


// These two methods are necessary to login from facebook app/website in case
// the user is not logged in from Settings|Facebook in the device.

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     