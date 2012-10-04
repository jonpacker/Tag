#import "TimeTracker.h"

NSString * const TimeTrackerNSErrorNewValueKey = @"TimeTrackerNSErrorNewValueKey";
NSString * const TimeTrackerNSErrorPropertyNameKey = @"TimeTrackerNSErrorPropertyNameKey";

static const NSKeyValueObservingOptions KVOOpts = NSKeyValueObservingOptionNew;

@interface TimeTracker() 

- (void) startObservingProperties;

@end

@implementation TimeTracker

@synthesize isSignedIn = _isSignedIn, status = _status, error = _error;

- (id) initWithApiKey:(NSString *)key {
  if ((self = [super init]) != nil) {
    _apiKey = key;
    
    [self startObservingProperties];
  }
  return self;
}

- (id) initWithApiKey:(NSString *)key andConfiguration:(NSDictionary *)config {
  if ((self = [self initWithApiKey:key]) != nil) {
    _config = config;
  }
  return self;
}

- (void) startObservingProperties {
  [self addObserver:self forKeyPath:@"isSignedIn" options:KVOOpts context:NULL];
  [self addObserver:self forKeyPath:@"status" options:KVOOpts context:NULL];
  [self addObserver:self forKeyPath:@"error" options:KVOOpts context:NULL];
}

- (void) onSignedInChange:(void (^)(NSError *, id))callback {
  [self addListener:callback forEventName:@"isSignedIn"];
}

- (void) onCurrentStatusChange:(void (^)(NSError *, id))callback {
  [self addListener:callback forEventName:@"status"];
}

- (void) didReceiveError:(NSError *)error forProperty:(NSString *)property withNewValueOrNil:(id)newValue {
  NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
  [userInfo setObject:error forKey:NSUnderlyingErrorKey];
  [userInfo setObject:property forKey:TimeTrackerNSErrorPropertyNameKey];
  
  if (newValue != nil) {
    [userInfo setObject:newValue forKey:TimeTrackerNSErrorNewValueKey];
  }
  
  NSError* errorWrapper = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
  [self setValue:errorWrapper forKeyPath:@"error"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object 
                         change:(NSDictionary *)change 
                        context:(void *)context {
  id value = [change objectForKey:NSKeyValueChangeNewKey];
  NSError* error = nil;
  if ([keyPath isEqualToString:@"error"]) {
    error = value;
    keyPath = [error.userInfo objectForKey:TimeTrackerNSErrorPropertyNameKey];
    
    // Apparently this error is in regards to nothing at all, you bastard! Quit now, call no callbacks. If you want to
    // peek at the (apparently orphaned) error, it will be set on `self.error`.
    if (keyPath == nil) {
      return;
    }
    
    value = [error.userInfo objectForKey:TimeTrackerNSErrorNewValueKey];
    
    // In order to not break KVO for other observers, we also need to still change the underlying value using the KVO
    // method (we can't just, f.e., do _status = value). BUT, since this would fire the listeners twice, we have to be
    // cheeky and temporarily remove ourselves from the observer list.
    [self removeObserver:self forKeyPath:keyPath];
    if (value != nil) {
      [self setValue:value forKey:keyPath];
    } else if ([value isKindOfClass:NSNull.class]) {
      [self setNilValueForKey:keyPath];
      value = nil;
    }
    [self addObserver:self forKeyPath:keyPath options:KVOOpts context:NULL];
  }
  
  [self fireListenersForEvent:keyPath withErrorOrNil:error andAccompanyingDataOrNil:value];
}

- (void) dealloc {
  [self removeObserver:self forKeyPath:@"isSignedIn"];
  [self removeObserver:self forKeyPath:@"status"];
  [self removeObserver:self forKeyPath:@"error"];
}

@end
