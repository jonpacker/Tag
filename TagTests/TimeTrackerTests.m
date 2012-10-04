#import "TimeTrackerTests.h"

@implementation TimeTrackerTests


- (void) testFiresHandlersOnChangeSignedIn {
  TimeTracker* tracker = [[TimeTracker alloc] initWithApiKey:@""];
  __block BOOL callbackWasCalled = NO;
  [tracker onSignedInChange:^(NSError *error, id isNowSignedIn) {
    STAssertNil(error, @"Error should be nil when no error is passed");
    STAssertTrue([isNowSignedIn boolValue], @"Signed in should equal the value passed");
    callbackWasCalled = YES;
  }];
  
  [tracker setValue:[NSNumber numberWithBool:YES] forKey:@"isSignedIn"];
  
  STAssertTrue(tracker.isSignedIn, @"KVC should set the value");
  STAssertTrue(callbackWasCalled, @"Callback should be called on property change");
}

- (void) testFiresErrorOnChangeSignedIn {
  TimeTracker* tracker = [[TimeTracker alloc] initWithApiKey:@""];
  __block BOOL callbackWasCalled = NO;
  [tracker onSignedInChange:^(NSError* error, id isNowSignedIn) {
    STAssertNotNil(error, @"Error shouldn't be nil when an error was passed");
    STAssertEqualObjects(error.domain, @"com.potato", @"error should reflect that which was passed (domain)");
    STAssertTrue(error.code == 1337, @"error should reflect that which was passed (code)");
    
    NSError* underlyingError = [error.userInfo objectForKey:NSUnderlyingErrorKey];
    STAssertNotNil(underlyingError, @"Should retain the original underlying error");
    
    NSString* customErrorVal = [underlyingError.userInfo objectForKey:@"ERRAR_QUAY"];
    
    STAssertEqualObjects(customErrorVal, @"ERRAR_VAL", @"Error should reflect that which was passed (userInfo)");
    STAssertFalse([isNowSignedIn boolValue], @"Signed in should equal the value passed");
    callbackWasCalled = YES;
  }];
  
  NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"ERRAR_VAL", @"ERRAR_QUAY", nil];
  NSError* error = [NSError errorWithDomain:@"com.potato" code:1337 userInfo:userInfo];
  
  [tracker didReceiveError:error forProperty:@"isSignedIn" withNewValueOrNil:[NSNumber numberWithBool:NO]];
  
  STAssertFalse(tracker.isSignedIn, @"KVC should set the value");
  STAssertTrue(callbackWasCalled, @"Callback should be called on property change");
}


@end
