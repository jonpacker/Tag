//
//  StatusFetcher.m
//  Popup
//
//  Created by Michael Mortensen on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatusFetcher.h"
#import "JSONKit.h"
#import "Utilities.h"
#import "config.h"

@interface StatusFetcher () <NSURLConnectionDelegate>
@property (retain, nonatomic) NSMutableData *data;
@property (retain, nonatomic) NSURLConnection *connection;
@property (assign, nonatomic) id<StatusListener> listener;
@property (assign, nonatomic) NSUInteger fetchStatus;
@property (retain, nonatomic) NSString *workingStatus;
@property (retain, nonatomic) NSString *key;
@property (retain, nonatomic) NSTimer *timer;
@end

@implementation StatusFetcher
@synthesize data, connection, listener, fetchStatus, workingStatus, key, timer;

- (id) initWithListenerAndKey:(id<StatusListener>)inListener key:(NSString *)inKey
{
    self = [super init];
    if (self) {
        self.data = nil;
        self.listener = inListener;
        self.fetchStatus = -1;
        self.key = inKey;
        self.workingStatus = nil;
        self.timer = nil;
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (fetchStatus != NO) {
        fetchStatus = NO;
        [listener failedMiserably:[error localizedDescription]];
    }
    self.data = nil;
    self.workingStatus = nil;
    self.connection = nil;
    [self startPolling];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)inData {
    [data appendData:inData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    fetchStatus = YES;
    NSDictionary *json = [data objectFromJSONData];
    NSString *newStatus = [json valueForKey:@"status"];
    [listener statusChanged:[newStatus isEqualToString:@"in"] json:json];
    workingStatus = newStatus;
    self.connection = nil;
    self.data = nil;
    [self startPolling];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    if (responseStatusCode != 200) {
        if (fetchStatus != NO) {
            fetchStatus = NO;
            [listener failedMiserably:[NSString stringWithFormat:@"Failed to retrieve status, server returned %d", responseStatusCode]];
        }
        [self.connection cancel];
        self.connection = nil;
        self.workingStatus = nil;
        [self startPolling];
    } else {
        [data setLength:0];
    }
}

- (void) getStatus:(NSTimer*)theTimer {
    [self.timer invalidate];
    self.timer = nil;
#ifdef USING_OLD_API
    NSString *url = @"http://time.qpgc.org/time/current";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    NSString *apikey = [NSString stringWithFormat:@"apikey=%@", key];
    [request addValue:apikey forHTTPHeaderField:@"Cookie"];
#else
    NSDate *now = [NSDate date];
    //time-next.qpgc.org
//    NSString *url = [NSString stringWithFormat:@"http://localhost:8124/v1/status?timestamp=%@&start=%@", [Utilities getUTCDate:now], [Utilities getUTCDate:[Utilities getStartOfDay:now]]];
    NSString *url = [NSString stringWithFormat:@"http://time.qpgc.org/status?timestamp=%@&start=%@", [Utilities getUTCDate:now], [Utilities getUTCDate:[Utilities getStartOfDay:now]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request addValue:key forHTTPHeaderField:@"apikey"];
#endif
    self.connection = nil;
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (self.connection) {
        self.data = [NSMutableData data];
    } else {
        if (fetchStatus != NO) {
            fetchStatus = NO;
            [listener failedMiserably:@"Failed to create connection."];
        }
        self.workingStatus = nil;
        [self startPolling];
    }
}

- (void) fetchImmediatelyIfNotFetching
{
    if (self.timer) [self.timer fire];
}

- (void) startPolling {
    if (self.timer) [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getStatus:) userInfo:nil repeats:NO];
}

- (void) stopPolling {
    
}

@end
