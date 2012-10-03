//
//  KolibriTimeTracker.h
//  Tag
//
//  Created by Jon Packer on 02.10.12.
//  Copyright (c) 2012 Creative Intersection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeTracker : NSObject {
 @protected
  NSString* _apiKey;
  NSDictionary* _config;
 @private
  NSMutableArray* _onStatusChange;
  NSMutableArray* _onSignedInChange;
}
- (id) initWithApiKey:(NSString *)key;
- (id) initWithApiKey:(NSString *)key andConfiguration:(NSDictionary *)config;

- (void) onSignedInChange:(void (^)(NSError* error, BOOL isNowSignedIn))callback;
- (void) onCurrentStatusChange:(void (^)(NSError* error, NSDictionary* newStatus))callback;

// Custom KVC method w/ error
- (void) setValue:(id)value forKey:(NSString *)key withError:(NSError*)error;

@property (nonatomic, retain) NSDictionary* status;
@property (nonatomic, setter=setSignedIn:) BOOL isSignedIn;

@end
