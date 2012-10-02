//
//  KolibriTimeTracker.m
//  Tag
//
//  Created by Jon Packer on 02.10.12.
//  Copyright (c) 2012 Creative Intersection. All rights reserved.
//

#import "TimeTracker.h"

@implementation TimeTracker

@synthesize isSignedIn, status;

- (id) initWithApiKey:(NSString *)key {
  if ((self = [super init]) != nil) {
    _apiKey = key;
    _onStatusChange = [[NSMutableArray alloc] init];
    _onSignedInChange = [[NSMutableArray alloc] init];
    
    NSKeyValueObservingOptions kvoOpts = NSKeyValueObservingOptionNew;
    
    [self addObserver:self forKeyPath:@"isSignedIn" options:kvoOpts context:NULL];
    [self addObserver:self forKeyPath:@"currentStatus" options:kvoOpts context:NULL];
  }
  return self;
}

- (id) initWithApiKey:(NSString *)key andConfiguration:(NSDictionary *)config {
  if ((self = [self initWithApiKey:key]) != nil) {
    _config = config;
  }
  return self;
}

- (void) onSignedInChange:(void (^)(NSError *, BOOL))callback {
  [_onSignedInChange addObject:Block_copy(callback)];
}

- (void) onCurrentStatusChange:(void (^)(NSError *, NSDictionary *))callback {
  [_onStatusChange addObject:Block_copy(callback)];
}

- (void) fire:(NSArray *)listeners withError:(NSError *) andData:(NSDictionary *)data {
  
}

- (void) observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object 
                         change:(NSDictionary *)change 
                        context:(void *)context {
  if ([keyPath isEqualToString:@"isSignedIn"]) {
    [_onSignedInChange enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      void (^callback)(NSError*, BOOL) = obj;
      callback(nil, self.isSignedIn);
    }];
  } else if ([keyPath isEqualToString:@"currentStatus"]) {
    [_onStatusChange enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      void (^callback)(NSError*, NSDictionary*) = obj;
      callback(nil, self.status);
    }];
  }
}

@end
