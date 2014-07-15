//
//  ChecklistItem.h
//  Checklist v2
//
//  Created by Hicham Chourak on 17/06/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChecklistItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSDate *dueDate;
@property (nonatomic, assign) BOOL shouldRemind;
@property (nonatomic, assign) int itemId;

- (void)scheduleNotification;

@end