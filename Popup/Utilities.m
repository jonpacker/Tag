//
//  Utilities.m
//  TagTime
//
//  Created by Michael Mortensen on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import "ISO8601DateFormatter.h"

@implementation Utilities


+(NSString *)getUTCDate:(NSDate *)localDate {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

+(NSDate *) getDateFromUTCTimestamp:(NSString *)date
{
    ISO8601DateFormatter *formatter = [[[ISO8601DateFormatter alloc] init] autorelease];
    return [formatter dateFromString:date];
}

+(NSDate *) getStartOfDay:(NSDate *)date {
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components = [gregorian components:unitFlags fromDate:date];
    components.hour = 0;
    components.minute = 0;
    return [gregorian dateFromComponents:components];
}

+ (NSImage *)rotateImage:(NSImage *)image degrees:(CGFloat)deg
{
    NSSize existingSize;
    
    NSBitmapImageRep* rep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    
    existingSize.width = [rep pixelsWide];
    existingSize.height = [rep pixelsHigh];
    
    NSSize newSize = NSMakeSize(existingSize.height, existingSize.width);
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:newSize];
    
    [rotatedImage lockFocus];
    
    NSAffineTransform *rotate = [NSAffineTransform transform];
    NSPoint centerPoint = NSMakePoint(newSize.width / 2, newSize.height / 2);
    
    [rotate translateXBy: centerPoint.x yBy: centerPoint.y];
    [rotate rotateByDegrees: deg];
    [rotate translateXBy: -centerPoint.y yBy: -centerPoint.x];
    [rotate concat];
    
    NSRect r1 = NSMakeRect(0, 0, newSize.height, newSize.width);
    [rep drawInRect: r1];
    
    [rotatedImage unlockFocus];
    [rotatedImage autorelease];
    return rotatedImage;
}

+ (NSImage *) scaleImage:(NSImage *)image longSide:(CGFloat)longSide
{
    NSSize size = [image size];
    CGFloat ratio = size.width > size.height
        ? longSide/size.width
        : longSide/size.height;
    size.width *= ratio;
    size.height *= ratio;
    [image setSize:size];
    return image;
}
@end
