#import <SenTestingKit/SenTestingKit.h>
#import "TimeTracker.h"

@interface TimeTrackerTests : SenTestCase

- (void) testFiresHandlersOnChangeSignedIn;
- (void) testFiresErrorOnChangeSignedIn;

@end
