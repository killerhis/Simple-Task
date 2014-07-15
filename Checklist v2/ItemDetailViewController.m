//
//  ItemDetailViewController.m
//  Checklist v2
//
//  Created by Hicham Chourak on 16/06/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "ChecklistItem.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController {
    UILabel *dateLabel;
    UITextField *textField;
    UILabel *saveLabel;
    NSDate *dueDate;
    UISwitch *switchControl;
    NSMutableArray *items;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self loadChecklistItems];
    }
    return self;
}

- (void)loadChecklistItems
{
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        items = [unarchiver decodeObjectForKey:@"ChecklistItems"];
        [unarchiver finishDecoding];
    }
    else
    {
        items = [[NSMutableArray alloc] initWithCapacity:20];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.itemToEdit != nil) {
        self.title = @"Edit Item";
        textField.text = self.itemToEdit.text;
        //switchControl.on = self.itemToEdit.shouldRemind;
        dueDate = self.itemToEdit.dueDate;
    } else {
        //switchControl.on = NO;
        dueDate = [NSDate date];
    }
    
    [self updateDueDateLabel];
    self.date = dueDate;
    [self.datePicker setDate:dueDate animated:NO];
    [self.tableView reloadData];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    //NSLog(@"%@", [[items mutableArrayValueForKey: @"itemId"] lastObject]);

    
}

- (void)updateSwitchControl
{
    if (self.itemToEdit != nil)
    {
        switchControl.on = self.itemToEdit.shouldRemind;
    } else {
        switchControl.on = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.datePicker setDate:self.date animated:YES];
    //self.date = [self.datePicker date];
    //dueDate = [self.datePicker date];
    if (self.itemToEdit != nil) {
        self.title = @"Edit Item";
        self.doneBarButton.enabled = YES;
        // moved to cellForRowAtIndexpath
        //textField.text = self.itemToEdit.text;
    }
    //[self updateDateLabel];
}

- (IBAction)dateChanged
{
    self.date = [self.datePicker date];
    
    [self updateDateLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done
{
    if (self.itemToEdit == nil) {
        ChecklistItem *item = [[ChecklistItem alloc] init];
        item.text = textField.text;
        item.shouldRemind = switchControl.on;
        item.dueDate = dueDate;
        
        if (items != nil)
        {
            item.itemId = [[[items mutableArrayValueForKey: @"itemId"] lastObject] intValue] + 1;
        } else {
            item.itemId = [items count];
        }
        
        //NSLog(@"%d", item.itemId);
        [item scheduleNotification];
        
        [self.delegate itemDetailViewController:self didFinishAddingItem:item];
    } else {
        self.itemToEdit.text = textField.text;
        self.itemToEdit.shouldRemind = switchControl.on;
        self.itemToEdit.dueDate = dueDate;
        
        [self.itemToEdit scheduleNotification];
        [self.delegate itemDetailViewController:self didFinishEditingItem:self.itemToEdit];
    }
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneBarButton.enabled = ([newText length] > 0);
    return YES;
}

#pragma mark - Table view data source
//TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"NameCell"];
        textField = (UITextField *)[cell viewWithTag:1001];
        
        if (self.itemToEdit != nil) {
            textField.text = self.itemToEdit.text;
        }
        
        //[textField becomeFirstResponder];
        return cell;
    } else if (indexPath.section == 0 && indexPath.row == 2){
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"DateCell"];
        dateLabel = (UILabel *)[cell viewWithTag:1000];
        [self updateDateLabel];
        return cell;
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"RemindMeCell"];
        cell.textLabel.text = @"Remind Me";
        switchControl = (UISwitch *)[cell viewWithTag:2000];
        [self updateSwitchControl];
        return cell;
    } else {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"DeleteCell"];
        saveLabel = (UILabel *)[cell viewWithTag:1002];
        
        if (self.itemToEdit != nil) {
            saveLabel.text = @"Delete";
        } else {
            saveLabel.text = @"Done";
        }
        return cell;
    }
    
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        if (self.itemToEdit == nil) {
            ChecklistItem *item = [[ChecklistItem alloc] init];
            item.text = textField.text;
            
            [self done];
            //[self.delegate itemDetailViewController:self didFinishAddingItem:item];
        } else {
            [self.delegate itemDetailViewController:self didFinishRemovingItem:self.itemToEdit];
        }
        
        return indexPath;
    } else {
        //return nil;
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [textField becomeFirstResponder];
    }
}

- (void)updateDateLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    dateLabel.text = [formatter stringFromDate:self.date];
    dueDate = self.date;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 50;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return NO;
}

- (void)updateDueDateLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    dateLabel.text = [formatter stringFromDate:dueDate];
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    [textField resignFirstResponder];
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"Checklists.plist"];
}


@end
