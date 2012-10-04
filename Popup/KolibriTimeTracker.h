#import "TimeTracker.h"

@interface KolibriTimeTracker : TimeTracker {
 @private
  NSTimer* _timer;
  NSURLConnection* _connection;
  NSMutableData* _data;
  
}



@end
