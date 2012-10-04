#import <Foundation/Foundation.h>

// I did not steal this from Node.js. I promise. No way. Would never do that. Definitely not. Ok I did. Shut up.
typedef void (^JPEventBlock)(NSError* errorOrNil, id accompanyingDataOrNil);

@interface JPEventedObject : NSObject {
 @private
  NSMutableDictionary* _listeners;
}

- (void) addListener:(JPEventBlock)callback forEventName:(NSString *)eventName;
- (void) fireListenersForEvent:(NSString *)event withErrorOrNil:(NSError *)error andAccompanyingDataOrNil:(id)data;

@end
