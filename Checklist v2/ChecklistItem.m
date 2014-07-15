//
//  ChecklistItem.m
//  Checklist v2
//
//  Created by Hicham Chourak on 17/06/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "ChecklistItem.h"
#import "ChecklistsViewController.h"

@implementation ChecklistItem

- (id)init
{
    self = [super init];
    if (self) {
        //self.itemId = 1;//[ChecklistsViewController nextChecklistItemId];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.text = [aDecoder decodeObjectForKey:@"Text"];
        self.dueDate = [aDecoder decodeObjectForKey:@"DueDate"];
        self.shouldRemind = [aDecoder decodeBoolForKey:@"ShouldRemind"];
        self.itemId = [aDecoder decodeIntForKey:@"ItemID"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"Text"];
    [aCoder encodeObject:self.dueDate forKey:@"DueDate"];
    [aCoder encodeBool:self.shouldRemind forKey:@"ShouldRemind"];
    [aCoder encodeInt:self.itemId forKey:@"ItemID"];
    
    //NSLog(@"saved itemid: %d", self.itemId);
}

- (void)scheduleNotification
{
    //NSLog(@"loaded itemID: %d", self.itemId);
    UILocalNotification *existingNotification = [self notificationForThisItem];
    
    NSDate *time = [NSDate dateWithTimeIntervalSinceReferenceDate:floor([self.dueDate timeIntervalSinceReferenceDate] / 60.0) * 60.0];
    
    if (existingNotification != nil) {
        //NSLog(@"Found an existing notification %@", existingNotification);
        [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
    }
    
    if (self.shouldRemind && [time compare:[NSDate date]] != NSOrderedAscending) {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        localNotification.fireDate = time;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertBody = self.text;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.itemId] forKey:@"ItemID"];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        //NSLog(@"Scheduled notification %@ for itemId %d", localNotification, self.itemId);
    }
}

- (UILocalNotification *)notificationForThisItem
{
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in allNotifications) {
        NSNumber *number = [notification.userInfo objectForKey:@"ItemID"];
        //NSLog(@"notification id: %@", number);
        if (number != nil && [number intValue] == self.itemId) {
            return notification;
        }
    }
    
    return nil;
}

/*- (void)dealloc
{
    UILocalNotification *existingNotification = [self notificationForThisItem];
    if (existingNotification != nil) {
        NSLog(@"Removing existing notification %@", existingNotification);
        [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
    }
    
}*/

@end
