//
//  EntryTextView.m
//  Popup
//
//  Created by Michael Mortensen on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EntryTextView.h"

@implementation EntryTextView

- (NSRange) rangeForUserCompletion {
    return NSMakeRange(NSNotFound, 0);
}
@end
