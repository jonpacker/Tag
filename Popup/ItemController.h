//
//  ItemController.h
//  Popup
//
//  Created by Michael Mortensen on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ItemController : NSViewController

@property (retain) IBOutlet NSTextField *when;
@property (retain) IBOutlet NSTextField *what;
@property (retain) IBOutlet NSButton *remove;

- (IBAction) buttonClicked:(id) sender;

@end
