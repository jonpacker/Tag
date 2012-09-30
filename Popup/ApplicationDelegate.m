/*
 Todo:
 - Fix placement bug when starting on one monitor and using on another.
 - Add completion
 - Add pluggable completion
 - Show last couple of entries and add a delete button.
*/
#import "ApplicationDelegate.h"
#import "DDHotKeyCenter.h"
#import <Carbon/Carbon.h>
#import "StatusFetcher.h"
#import "Entry.h"
#import "PostRequest.h"
#import "config.h"

const char *API_KEY = KEY;

@interface ApplicationDelegate () <StatusListener, PostListener>

@property (retain, nonatomic) StatusFetcher *statusFetcher;
@property (assign, nonatomic) BOOL firstFetch;
@end

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;
@synthesize statusFetcher;
@synthesize firstFetch;
#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
    statusFetcher = nil;
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - StatusListener

- (void) statusChanged:(BOOL)working json:(NSDictionary *)json {
    if (firstFetch) {
        firstFetch = NO;
        [_panelController enable];
        [_menubarController stopAnimation];
        DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];
        if (![c registerHotKeyWithKeyCode:kVK_Space modifierFlags:(NSControlKeyMask | NSCommandKeyMask) target:self action:@selector(hotkeyWithEvent:) object:nil]) {
            NSLog(@"Unable to register hotkey for example 1");
        } else {
            NSLog(@"%@", [NSString stringWithFormat:@"Registered: %@", [c registeredHotKeys]]);
        }

    }
#ifndef USING_OLD_API
    NSNumber *hours = [json objectForKey:@"hours"];
    NSNumber *minutes = [json objectForKey:@"minutes"];
    if (minutes != nil) {
        NSString *total = [NSString stringWithFormat:@"%llum", [minutes longValue]];
        if (hours != nil && [hours longValue] > 0L) {
            total = [NSString stringWithFormat:@"Today: %lluh %@", [hours longValue], total];
        } else {
            total = [NSString stringWithFormat:@"Today: %@", total];
        }
        [_panelController setTotal:total];
    }
#endif
    [_panelController setLastEntry: json];
    //[_panelController setSignedIn: working];
    [_menubarController setStatus:working];
}

- (void) failedMiserably:(NSString *)error {
    NSLog(@"Failed %@", error);
    [_menubarController setError:error];
}

#pragma mark - NSApplicationDelegate


- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
    if (![_menubarController hasActiveIcon]) {
        [_menubarController.statusItemView activate];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Install icon into the menu bar
    firstFetch = YES;
    self.menubarController = [[MenubarController alloc] init];
    [_menubarController setStatus:NO];
    [[self panelController] setSignedIn:NO];
    [_panelController disable];
    [_menubarController startAnimation];
    self.statusFetcher = [[StatusFetcher alloc] initWithListenerAndKey:self key:[NSString stringWithUTF8String:API_KEY]];
    [statusFetcher startPolling];
    [self.statusFetcher fetchImmediatelyIfNotFetching];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}

- (void) postFailed:(NSString *)reason {
    [_menubarController stopAnimation];
    [self failedMiserably:reason];
}

- (void) success {
    [_menubarController stopAnimation];
    [self.statusFetcher fetchImmediatelyIfNotFetching];
}

- (void) newEntry:(Entry *)entry {
    [_menubarController startAnimation];
    NSData *jsonData = [entry entryAsJSONData];
    PostRequest *post = [[PostRequest alloc] initWithDelegateAndKeyAndJSON:self key:[NSString stringWithUTF8String:API_KEY] jsonData:jsonData];
    if (post == nil) {
        [self postFailed:@"Failed to update status."];
    }
}

@end
