//
//  Entry.m
//  Popup
//
//  Created by Michael Mortensen on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Entry.h"
#import "ISO8601DateFormatter.h"
#import "JSONKit.h"
#import "Utilities.h"
#import "config.h"

@implementation Entry

@synthesize tags;
@synthesize description;
@synthesize working;
@synthesize timestamp;

- (NSData *) entryAsJSONData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *dateStr = [Utilities getUTCDate:timestamp];

#ifdef USING_OLD_API
    [dict setValue:dateStr forKey:@"id"];
#else
    [dict setValue:dateStr forKey:@"_id"];
#endif
    
    if (tags)
    {
        [dict setValue:tags forKey:@"tags"];
    }
    
    if (description)
    {
        [dict setValue:description forKey:@"description"];
    }
    
    if (working) {
        [dict setValue:@"in" forKey:@"status"];
    } else {    
        [dict setValue:@"out" forKey:@"status"];
    }

    return [dict JSONData];
}
@end
