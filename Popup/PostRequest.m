#import "PostRequest.h"
#import "config.h"

@interface PostRequest ()
@property (retain) NSURLConnection *connection;
@property (assign) id<PostListener> listener;
@end

@implementation PostRequest

@synthesize connection, listener;
- (id) initWithDelegateAndKeyAndJSON:(id<PostListener>)inListener key:(NSString *)key jsonData:(NSData *)jsonData
{
    self = [super init];
    if (self)
    {
        self.listener = inListener;
#ifdef USING_OLD_API
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://time.qpgc.org/time"]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        NSString *apikey = [NSString stringWithFormat:@"apikey=%@", key];
        [request addValue:apikey forHTTPHeaderField:@"Cookie"];
#else
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://localhost:8124/v1/time"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://time.qpgc.org/time"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [request addValue:key forHTTPHeaderField:@"apikey"];
#endif
//
//        [request addValue:key forHTTPHeaderField:@"apikey"];
        [request addValue:@"application/json" forHTTPHeaderField:@"content-type"];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        
        self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
        if (!connection)
        {
            [listener postFailed:@"Failed to post data."];
        }
    }
    return self;
}


- (void) dealloc
{
    self.connection = nil;
    self.listener = nil;
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)inData
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [listener postFailed:[error localizedDescription]];
    self.connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [listener success];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    if (responseStatusCode/100 != 2) {
        [listener postFailed:[NSString stringWithFormat:@"Server returned HTTP code %d", responseStatusCode]];
        [self.connection cancel];
        self.connection = nil;
    }
}

@end
