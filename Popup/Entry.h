//
//  Entry.h
//  Popup
//
//  Created by Michael Mortensen on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entry : NSObject
@property (retain) NSDate *timestamp;
@property (assign) BOOL working;
@property (retain) NSArray *tags;
@property (retain) NSString *description;

- (NSData *) entryAsJSONData;
@end
