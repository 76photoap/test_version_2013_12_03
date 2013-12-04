//
//  NSURL+Attributes.m
//  krowdx
//
//  Created by Juliana C on 11/18/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "NSURL+Attributes.h"

@implementation NSURL (Attributes)

- (BOOL)addSkipBackupAttributeToItem
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [self path]]);
    
    NSError *error = nil;
    BOOL success = [self setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [self lastPathComponent], error);
    }
    return success;
}

@end
