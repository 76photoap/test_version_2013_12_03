//
//  NetworkClient.m
//  krowdx
//
//  Created by Julie Caccavo on 11/9/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "NetworkClient.h"
#import "Venue.h"

@interface NetworkClient ()
{
    NSTimer *timer;
    NSNumber *uploadInterval;
}


@property (strong, nonatomic)RequestSuccess photoSuccessBlock;
@property (strong, nonatomic)RequestSuccess photoFailBlock;
@property (strong, nonatomic)RequestSuccess postSuccessBlock;
@property (strong, nonatomic)RequestSuccess postFailBlock;
@property (strong, nonatomic)NSDictionary *venue;
@property (strong, nonatomic)PFObject *imageObject;
@property (strong, nonatomic)PFObject *imageObjectOk;

@end

@implementation NetworkClient

GCDSingleton(NetworkClient)


- (void)retryUploadingPost{
    self.post[@"image"] = self.imageObjectOk;
    [self uploadPost:self.post inVenue:self.venue successBlock:self.postSuccessBlock failBlock:self.postFailBlock];
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Upload Photo" action:@"Retry after failure" label:@"Retry" value:nil] build]];
}

- (void)retryUploadingPhoto{
    
    PFObject *imageObject = [PFObject objectWithClassName:@"PostImage"];
    NSData *imageData = UIImagePNGRepresentation(self.image);
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd_hh-mm-ss"];
    if (imageData && [User currentUser].objectId) {
        imageObject[@"image"] = [PFFile fileWithName:[NSString stringWithFormat:@"%@_%@.png",[User currentUser].objectId,[df stringFromDate:[NSDate date]]] data:imageData];
        NSLog(@"Imagen: %@",((PFFile*)imageObject[@"image"]).name);
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
    
    [self uploadPhoto:imageObject successBlock:self.photoSuccessBlock failBlock:self.photoFailBlock];
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Upload Photo" action:@"Retry after failure" label:@"Retry" value:nil] build]];
}


- (void)timer{
    //Google analytics takes 1000 and shows 1 sec, thats why I increment by 1000 every second.
    uploadInterval = [NSNumber numberWithInteger:[uploadInterval integerValue] + 1000];
    
    //If uploading takes more than 1 minute, cancel and retry
    if ([uploadInterval integerValue] >= 40000) {
        [self cancelUpload];
    }
}

-(void)uploadPhoto:(PFObject*)imageObject successBlock:(RequestSuccess)success failBlock:(RequestFail)fail{
    self.imageObject = imageObject;
    //Calculate uploading time and send to google analytics.
    uploadInterval = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timer) userInfo:nil repeats:YES];

    self.photoSuccessBlock = success;
    self.photoFailBlock = fail;
    
    _ME_WEAK
    [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [timer invalidate];
        if (succeeded){
            [me.tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"New Post" interval:uploadInterval name:@"Upload Image" label:nil] build]];
            self.imageObjectOk = imageObject;
            success(@"Photo uploaded");
        }
        else{
            fail(@"Uploading failed");
        }
    }];
}


- (void)uploadPost:(Post *)newPost inVenue:(NSDictionary *)selectedVenue successBlock:(RequestSuccess)success failBlock:(RequestFail)fail{
    self.venue = selectedVenue;
    self.postFailBlock = fail;
    self.postSuccessBlock = success;
    
    
    //when i retry to upload photo, the pfobject imageObject is a new one, so i need to link the new post to the new instance.
    if (self.imageObjectOk) {
        newPost[@"image"] = self.imageObjectOk;
    }
    
    //Fetch venue objectId to store in Post table
    PFQuery *venueQuery = [PFQuery queryWithClassName:@"Venue"];
    [venueQuery whereKey:@"foursquareId" equalTo:selectedVenue[@"id"]];
    [venueQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        //If venue doesnt exist, create it.
        if (objects.count == 0) {
           
            //Create venue and save it
            Venue *newVenue = [self createNewVenue:selectedVenue];
            [newVenue saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    newPost.venue = newVenue;
                    [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            success(@"SI");
                        }
                        else{
                            fail(@"NO");
                        }
                    }];
                }
                else{
                    fail(@"NO");
                }
                
            }];
            
        }
        else{
            newPost.venue = [objects lastObject];
            
            [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    success(@"SI");
                }
                else{
                    fail(@"NO");
                }
            }];
        }
        
    }];
}

-(void)cancelUpload{
    [self.imageObject[@"image"] cancel];
}


- (Venue*)createNewVenue:(NSDictionary*)selectedVenue{
    Venue *newVenue = [Venue object];
    
    NSMutableDictionary *contact, *location, *categories;
    contact = [[NSMutableDictionary alloc] initWithCapacity:2];
    location = [[NSMutableDictionary alloc] initWithCapacity:9];
    categories = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    
    if (selectedVenue[@"id"]) {
        [newVenue setObject:selectedVenue[@"id"] forKey:@"foursquareId"];
    }
    else{
        [newVenue setObject:@"" forKey:@"foursquareId"];
    }
    if (selectedVenue[@"name"]) {
        [newVenue setObject:selectedVenue[@"name"] forKey:@"name"];
    }
    else{
        [newVenue setObject:@"" forKey:@"name"];
    }
    if (selectedVenue[@"contact"]) {
        if (selectedVenue[@"contact"][@"phone"]) {
            [contact setObject:selectedVenue[@"contact"][@"phone"] forKey:@"phone"];
        }
        else{
            [contact setObject:@"" forKey:@"phone"];
        }
        if (selectedVenue[@"contact"][@"formattedPhone"]) {
            [contact setObject:selectedVenue[@"contact"][@"formattedPhone"] forKey:@"formattedPhone"];
        }
        else{
            [contact setObject:@"" forKey:@"formattedPhone"];
        }
    }
    else{
        [contact setObject:@"" forKey:@"phone"];
        [contact setObject:@"" forKey:@"formattedPhone"];
        
    }
    [newVenue setObject:contact forKey:@"contact"];
    
    if (selectedVenue[@"location"]) {
        if (selectedVenue[@"location"][@"address"]) {
            [location setObject:selectedVenue[@"location"][@"address"] forKey:@"address"];
        }
        else{
            [location setObject:@"" forKey:@"address"];
        }
        if (selectedVenue[@"location"][@"crossStreet"]) {
            [location setObject:selectedVenue[@"location"][@"crossStreet"] forKey:@"crossStreet"];
        }
        else{
            [location setObject:@"" forKey:@"crossStreet"];
        }
        if (selectedVenue[@"location"][@"lat"]) {
            [location setObject:selectedVenue[@"location"][@"lat"] forKey:@"lat"];
        }
        else{
            [location setObject:@"" forKey:@"lat"];
        }
        if (selectedVenue[@"location"][@"lng"]) {
            [location setObject:selectedVenue[@"location"][@"lng"] forKey:@"lng"];
        }
        else{
            [location setObject:@"" forKey:@"lng"];
        }
        if (selectedVenue[@"location"][@"postalCode"]) {
            [location setObject:selectedVenue[@"location"][@"postalCode"] forKey:@"postalCode"];
        }
        else{
            [location setObject:@"" forKey:@"postalCode"];
        }
        if (selectedVenue[@"location"][@"city"]) {
            [location setObject:selectedVenue[@"location"][@"city"] forKey:@"city"];
        }
        else{
            [location setObject:@"" forKey:@"city"];
        }
        if (selectedVenue[@"location"][@"state"]) {
            [location setObject:selectedVenue[@"location"][@"state"] forKey:@"state"];
        }
        else{
            [location setObject:@"" forKey:@"state"];
        }
        if (selectedVenue[@"location"][@"country"]) {
            [location setObject:selectedVenue[@"location"][@"country"] forKey:@"country"];
        }
        else{
            [location setObject:@"" forKey:@"country"];
        }
        if (selectedVenue[@"location"][@"cc"]) {
            [location setObject:selectedVenue[@"location"][@"cc"] forKey:@"cc"];
        }
        else{
            [location setObject:@"" forKey:@"cc"];
        }
    }
    else{
        [location setObject:@"" forKey:@"address"];
        [location setObject:@"" forKey:@"crossStreet"];
        [location setObject:@"" forKey:@"lat"];
        [location setObject:@"" forKey:@"lng"];
        [location setObject:@"" forKey:@"postalCode"];
        [location setObject:@"" forKey:@"city"];
        [location setObject:@"" forKey:@"state"];
        [location setObject:@"" forKey:@"country"];
        [location setObject:@"" forKey:@"cc"];
    }
    [newVenue setObject:location forKey:@"location"];
    
    if ([selectedVenue[@"categories"] lastObject]) {
        if (selectedVenue[@"categories"][0][@"name"]) {
            [categories setObject:selectedVenue[@"categories"][0][@"name"] forKey:@"name"];
        }
        else{
            [categories setObject:@"" forKey:@"name"];
        }
        if (selectedVenue[@"categories"][0][@"icon"]) {
            [categories setObject:selectedVenue[@"categories"][0][@"icon"] forKey:@"icon"];
        }
        else{
            [categories setObject:@"" forKey:@"icon"];
        }
    }
    else{
        [categories setObject:@"" forKey:@"name"];
        [categories setObject:@"" forKey:@"icon"];
        
    }
    [newVenue setObject:categories forKey:@"categories"];
    
    if (selectedVenue[@"url"]) {
        [newVenue setObject:selectedVenue[@"url"] forKey:@"url"];
    }
    else{
        [newVenue setObject:@"" forKey:@"url"];
    }
    
    return newVenue;
}



@end
