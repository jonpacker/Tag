#import <Cocoa/Cocoa.h>
#import "config.h"

@protocol PostListener <NSObject>
- (void) postFailed:(NSString *)reason;
- (void) success;
@end

@interface PostRequest : NSObject
{
}

- (id) initWithDelegateAndKeyAndJSON:(id<PostListener>)inListener key:(NSString *)key jsonData:(NSData *)jsonData;

@end
