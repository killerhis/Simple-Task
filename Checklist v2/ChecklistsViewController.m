//
//  ChecklistsViewController.m
//  Checklist v2
//
//  Created by Hicham Chourak on 16/06/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "ChecklistsViewController.h"
#import "ChecklistItem.h"
#import "GAIDictionaryBuilder.h"

@interface ChecklistsViewController ()

@end

@implementation ChecklistsViewController {
    NSMutableArray *items;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CheckListView"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    if ([items count] == 0) {
        [self performSegueWithIdentifier:@"NoItems" sender:self];
    }
}

//TableView

- (void)configureTextForCell:(UITableViewCell *)cell withChecklistItem:(ChecklistItem *)item
{
    //UILabel *label = (UILabel *)[cell viewWithTag:1000];
    //label.text = item.text;
    
    //cell.textLabel.text = item.text;
    //int itemId =  [items indexOfObject:item];
    cell.textLabel.text = item.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    cell.detailTextLabel.text = [formatter stringFromDate:item.dueDate];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ChecklistItem"];
    
    ChecklistItem *item = [items objectAtIndex:indexPath.row];
    
    //cell.textLabel.text = item.text;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"test"];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self configureTextForCell:cell withChecklistItem:item];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [items removeObjectAtIndex:indexPath.row];
    
    [self saveChecklistItems];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if ([items count] == 0) {
        [self performSegueWithIdentifier:@"NoItems" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    ChecklistItem *item = [items objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EditItem" sender:item];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Items

- (void)itemDetailViewControllerDidCancel:(ItemDetailViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishAddingItem:(ChecklistItem *)item
{
    int newRowIndex = (int)[items count];

    [items addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self saveChecklistItems];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishEditingItem:(ChecklistItem *)item
{
    int index = (int)[items indexOfObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self configureTextForCell:cell withChecklistItem:item];
     
    [self saveChecklistItems];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishRemovingItem:(ChecklistItem *)item
{
    int index = (int)[items indexOfObject:item];
    
    [items removeObjectAtIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self saveChecklistItems];
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddItem"]) {
        //UINavigationController *navigationController = segue.destinationViewController;
        //ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
        //controller.delegate = self;
        ItemDetailViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"EditItem"]) {
        //UINavigationController *navigationController = segue.destinationViewController;
        //ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
        ItemDetailViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.itemToEdit = sender;
    }
}

// Store items

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

- (void)saveChecklistItems
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:items forKey:@"ChecklistItems"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

@end
