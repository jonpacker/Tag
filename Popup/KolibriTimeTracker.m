#import "KolibriTimeTracker.h"
#import "Utilities.h"
#import "JSONKit.h"

@interface KolibriTimeTracker() <NSURLConnectionDelegate>

- (void) startPolling;
- (void) fetchImmediatelyIfNotFetching;
- (void) getStatus:(NSTimer *)timer;

@end

@implementation KolibriTimeTracker

- (id) initWithConfiguration:(NSDictionary *)config {
  if ((self = [super initWithConfiguration:config]) != nil) {
    [self startPolling];
    [self fetchImmediatelyIfNotFetching];
  }
}

- (void) startPolling {
  if (_timer) {
    [_timer invalidate];
  }
  
  _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 
                                            target:self 
                                          selector:@selector(getStatus:) 
                                          userInfo:nil 
                                           repeats:NO];
}

- (void) fetchImmediatelyIfNotFetching {
  if (_timer) {
    [_timer fire];
  }
}

- (void) getStatus:(NSTimer*)timer {
  [timer invalidate];
  timer = nil;
  NSString* key = [_config objectForKey:@"apiKey"];
  
#ifdef USING_OLD_API
  NSString *url = @"http://time.qpgc.org/time/current";
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:30.0];
  NSString *apikey = [NSString stringWithFormat:@"apikey=%@", key];
  [request addValue:apikey forHTTPHeaderField:@"Cookie"];
#else
  NSDate *now = [NSDate date];
  NSString *url = [NSString stringWithFormat:@"http://time.qpgc.org/status?timestamp=%@&start=%@", 
                   [Utilities getUTCDate:now], [Utilities getUTCDate:[Utilities getStartOfDay:now]]];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:30.0];
  [request addValue:key forHTTPHeaderField:@"apikey"];
#endif
  
  _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  if (_connection) {
    _data = [NSMutableData data];
  } else {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Failed to create connection", NSLocalizedDescriptionKey,
                              @"status", TimeTrackerNSErrorPropertyNameKey, nil];
    NSError* error = [NSError errorWithDomain:@"KolibriTimeTracker#getStatus" code:1 userInfo:userInfo];

    [self setValue:error forKey:@"error"];
    [self startPolling];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                            error.localizedDescription, NSLocalizedDescriptionKey,
                            @"status", TimeTrackerNSErrorPropertyNameKey, nil];
  NSError* wrappedError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
  [self setValue:wrappedError forKey:@"error"];
  _data = nil;
  _connection = nil;
  [self startPolling];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)inData {
  [_data appendData:inData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
  NSInteger responseStatusCode = [httpResponse statusCode];
  if (responseStatusCode != 200) {
      //[listener failedMiserably:[NSString stringWithFormat:@"Failed to retrieve status, server returned %d", responseStatusCode]];
    NSString* errorMessage = [NSString stringWithFormat:@"Failed to retrieve status, server returned %d", 
                              responseStatusCode];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              errorMessage, NSLocalizedDescriptionKey,
                              @"status", TimeTrackerNSErrorPropertyNameKey, nil];
    NSError* error = [NSError errorWithDomain:@"KolibriTimeTracker#getStatus" code:2 userInfo:userInfo];
    [self setValue:error forKey:@"error"];
    [_connection cancel], _connection = nil;
    [self startPolling];
  } else {
    [_data setLength:0];
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSDictionary *json = [_data objectFromJSONData];
  [self setValue:json forKey:@"status"];
  _connection = nil;
  _data = nil;
  [self startPolling];
}

@end
