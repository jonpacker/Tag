#import "JPEventedObject.h"

@implementation JPEventedObject

- (id) init {
  if ((self = [super init]) != nil) {
    _listeners = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void) addListener:(JPEventBlock)callback forEventName:(NSString *)eventName {
  NSMutableArray* listenersForEvent = [_listeners objectForKey:eventName];
  if (listenersForEvent == nil) {
    listenersForEvent = [[NSMutableArray alloc] init];
    [_listeners setObject:listenersForEvent forKey:eventName];
  }
  
  [listenersForEvent addObject:[callback copy]];
}

- (void) fireListenersForEvent:(NSString *)event withErrorOrNil:(NSError *)error andAccompanyingDataOrNil:(id)data {
  NSArray* listeners = [_listeners objectForKey:event];
  if (listeners == nil) {
    return;
  }
  
  [listeners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    void (^listener)(NSError*, id) = obj;
    listener(error, data);
  }];
}

@end
