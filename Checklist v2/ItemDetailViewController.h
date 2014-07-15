//
//  ItemDetailViewController.h
//  Checklist v2
//
//  Created by Hicham Chourak on 16/06/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemDetailViewController;
@class ChecklistItem;

@protocol ItemDetailViewControllerDelegate <NSObject>

//- (void)itemDetailViewControllerDidCancel:(ItemDetailViewController *)controller;
- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishAddingItem:(ChecklistItem *)item;
- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishEditingItem:(ChecklistItem *)item;
- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishRemovingItem:(ChecklistItem *)item;

//- (void)datePickerDidCancel:(ItemDetailViewController *)picker;
//- (void)datePicker:(ItemDetailViewController *)picker didPickDate:(NSDate *)date;

@end

@interface ItemDetailViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) id <ItemDetailViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDate *date;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (nonatomic, strong) ChecklistItem *itemToEdit;
//@property (nonatomic, strong) IBOutlet UISwitch *switchControl;
@property (nonatomic, strong) IBOutlet UILabel *dueDateLabel;

- (IBAction)done;
- (IBAction)dateChanged;

@end
