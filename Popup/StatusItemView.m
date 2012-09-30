#import "StatusItemView.h"
#import "Utilities.h"

@interface StatusItemView ()
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *alternateImages;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;
@synthesize images;
@synthesize alternateImages;
@synthesize index;
@synthesize timer;

#pragma mark -

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
        self.images = nil;
        self.alternateImages = nil;
        self.index = 0;
        self.timer = nil;
    }
    return self;
}


- (void) rotate
{
    index += 1;
    index %= [images count];
    [self setNeedsDisplay:YES];
}

- (void) startAnimation {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(rotate) userInfo:nil repeats:YES];
}

- (void) stopAnimation {
    [self.timer invalidate];
    self.timer = nil;
    index = 0;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    NSImage *icon = self.isHighlighted ? self.alternateImage : [images objectAtIndex:index];
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon compositeToPoint:iconPoint operation:NSCompositeSourceOver];
}

- (void) activate
{
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage) {
        //_image = [Utilities scaleImage:newImage longSide:[[NSStatusBar systemStatusBar] thickness]-5];// newImage;
        _image = newImage;
        self.images = [NSArray arrayWithObjects:_image,
                       [Utilities rotateImage:_image degrees:-15],
                       [Utilities rotateImage:_image degrees:-30],
                       [Utilities rotateImage:_image degrees:-45],
                       [Utilities rotateImage:_image degrees:-60],
                       [Utilities rotateImage:_image degrees:-75],
                       nil];
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage
{
    if (_alternateImage != newImage) {
        //_alternateImage = [Utilities scaleImage:newImage longSide:[[NSStatusBar systemStatusBar] thickness]-5];// newImage;

        _alternateImage = newImage;
        self.alternateImages = [NSArray arrayWithObjects:_alternateImage,
                                [Utilities rotateImage:_alternateImage degrees:30],
                                [Utilities rotateImage:_alternateImage degrees:60],
                                [Utilities rotateImage:_alternateImage degrees:90],
                                [Utilities rotateImage:_alternateImage degrees:120],
                                [Utilities rotateImage:_alternateImage degrees:150],
                                nil];
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
