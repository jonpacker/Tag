//
//  KolibriTimeTracker.m
//  Tag
//
//  Created by Jon Packer on 02.10.12.
//  Copyright (c) 2012 Creative Intersection. All rights reserved.
//

#import "TimeTracker.h"

@interface TimeTracker() 

- (void) startObservingProperties;
- (void(^)(NSString*,NSError*)) errorReceiver;

@end

@implementation TimeTracker

@synthesize isSignedIn, status;

- (id) initWithApiKey:(NSString *)key {
  if ((self = [super init]) != nil) {
    _apiKey = key;
    _onStatusChange = [[NSMutableArray alloc] init];
    _onSignedInChange = [[NSMutableArray alloc] init];
    
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
  NSKeyValueObservingOptions kvoOpts = NSKeyValueObservingOptionNew;
  [self addObserver:self forKeyPath:@"isSignedIn" options:kvoOpts context:NULL];
  [self addObserver:self forKeyPath:@"currentStatus" options:kvoOpts context:NULL];
}

- (void) onSignedInChange:(void (^)(NSError *, BOOL))callback {
  [_onSignedInChange addObject:Block_copy(callback)];
}

- (void) onCurrentStatusChange:(void (^)(NSError *, NSDictionary *))callback {
  [_onStatusChange addObject:Block_copy(callback)];
}

- (void) observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object 
                         change:(NSDictionary *)change 
                        context:(void *)context {
  id value = [change objectForKey:NSKeyValueChangeNewKey];
  NSError* error = nil;
  if ([keyPath hasPrefix:@".error"]) {
    error = [value objectForKey:@"error"];
    value = [value objectForKey:@"value"];
    if ([value isKindOfClass:NSNull.class]) {
      value = nil;
    }
  }
  
  if ([keyPath hasPrefix:@"isSignedIn"]) {
    BOOL boolValue = value == nil ? NO : [value boolValue];
    [_onSignedInChange enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      void (^callback)(NSError*, BOOL) = obj;
      callback(error, boolValue);
    }];
  } else if ([keyPath hasPrefix:@"currentStatus"]) {
    [_onStatusChange enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      void (^callback)(NSError*, NSDictionary*) = obj;
      callback(error, value);
    }];
  }
}

@end
