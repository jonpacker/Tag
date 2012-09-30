#import "BackgroundView.h"
#import "StatusItemView.h"

@class PanelController;
@class Entry;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@required
- (void) newEntry:(Entry*)entry;
@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate>
{
    @private
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    __unsafe_unretained NSTextView *_inputText;
    __unsafe_unretained NSScrollView *_inputView;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet NSScrollView *inputView;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *inputText;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *sum;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *when;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *whenLabel;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *tagsLabel;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *tags;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *descriptionLabel;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *description;
@property (nonatomic, unsafe_unretained) IBOutlet NSBox *box;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

@property (assign, nonatomic) BOOL signedIn;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;
- (NSRect)statusRectForWindow:(NSWindow *)window;
- (void) enable;
- (void) disable;
- (void) setTotal:(NSString *)total;
- (void) setLastEntry:(NSDictionary *)json;

@end
