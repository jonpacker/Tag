#import "MenubarController.h"
#import "StatusItemView.h"

@interface MenubarController ()
@property (assign, nonatomic) BOOL inError;
@property (assign, nonatomic) BOOL oldStatus;
@end

@implementation MenubarController

@synthesize statusItemView = _statusItemView;
@synthesize inError;
@synthesize oldStatus;

#pragma mark -

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Install status item into the menu bar
        NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        _statusItemView = [[StatusItemView alloc] initWithStatusItem:statusItem];
        _statusItemView.image = [NSImage imageNamed:@"StatusInactive"];
        _statusItemView.alternateImage = [NSImage imageNamed:@"StatusHighlighted"];
        _statusItemView.action = @selector(togglePanel:);
        self.inError = NO;
        self.oldStatus = NO;
    }
    return self;
}

- (void)dealloc
{
    self.inError = NO;
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

#pragma mark -
#pragma mark Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

#pragma mark -

- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void) startAnimation {
    [self.statusItemView startAnimation];
}

- (void) stopAnimation {
    [self.statusItemView stopAnimation];
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}

- (void) setError:(NSString *)error {
    if (error) {
        inError = YES;
        _statusItemView.image = [NSImage imageNamed:@"StatusFailed"];
        [_statusItemView setToolTip:error];
    } else {
        [_statusItemView setToolTip:@""];
        inError = NO;
    }
}

- (void) setStatus:(BOOL)working {
    if (working == oldStatus && !inError) return;
    oldStatus = working;
    if (inError) {
        [self setError:nil];
    }
    if (working) {
        _statusItemView.image = [NSImage imageNamed:@"Status"];
    } else {
        _statusItemView.image = [NSImage imageNamed:@"StatusInactive"];
    }
}
@end
