//
//  FocusableScrollView.m
//  Popup
//
//  Created by Michael Mortensen on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FocusableScrollView.h"

@implementation FocusableScrollView

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];

    NSSetFocusRingStyle(NSFocusRingOnly);
    NSRectFill([self bounds]);
}

@end
