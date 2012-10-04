#import <Foundation/Foundation.h>
#import "JPEventedObject.h"

FOUNDATION_EXPORT NSString * const TimeTrackerNSErrorNewValueKey;
FOUNDATION_EXPORT NSString * const TimeTrackerNSErrorPropertyNameKey;

@interface TimeTracker : JPEventedObject {
 @protected
  NSDictionary* _config;
}
- (id) initWithConfiguration:(NSDictionary *)config;

- (void) onSignedInChange:(void (^)(NSError* error, id newSignedInStateOrNil))callback;
- (void) onCurrentStatusChange:(void (^)(NSError* error, id newStatusOrNil))callback;

- (void) didReceiveError:(NSError *)error forProperty:(NSString *)property withNewValueOrNil:(id)newValue;

@property (nonatomic, retain) NSDictionary* status;
@property (nonatomic) BOOL isSignedIn;
@property (nonatomic, retain) NSError* error;

@end
