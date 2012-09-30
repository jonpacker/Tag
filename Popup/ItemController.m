//
//  ItemController.m
//  Popup
//
//  Created by Michael Mortensen on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemController.h"

@implementation ItemController

@synthesize when;
@synthesize what;
@synthesize remove;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction) buttonClicked:(id) sender {
    NSLog(@"Remove button clicked.");
}

@end
