//
//  Utilities.h
//  TagTime
//
//  Created by Michael Mortensen on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities

+ (NSImage *)rotateImage: (NSImage *)image degrees:(CGFloat)deg;
+ (NSString *)getUTCDate:(NSDate *)localDate;
+ (NSDate *) getStartOfDay:(NSDate *)date;
+ (NSDate *) getDateFromUTCTimestamp:(NSString *)date;
+ (NSImage *) scaleImage:(NSImage *)image longSide:(CGFloat)longSide;
@end
