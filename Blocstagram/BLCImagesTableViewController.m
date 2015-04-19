//
//  BLCImagesTableViewController.m
//  Blocstagram
//
//  Created by Julicia on 12/17/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCImagesTableViewController.h"
#import "BLCMediaTableViewCell.h"
#import "BLCMediaFullScreenViewController.h"
#import "BLCMediaFullScreenAnimator.h" //At first I accidentally imported the BLCMediaFulScreenAnimator.m file, and that caused an Apple Mach-O Linker Error when compiling the device. 

@interface BLCImagesTableViewController () <BLCMediaTableViewCellDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIImageView *lastTappedImageView;
@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardAdjustment;


@end

@implementation BLCImagesTableViewController


#pragma mark - Setup

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //self.images = [NSMutableArray array];
        
    }
    return self;
}

#pragma mark > Key Value Observation
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*NSDictionary *images = @{@1: @"1.jpg",
                             @2: @"2.jpg",
                             @3: @"DSCF2907.JPG",
                             @4: @"houseparty.jpg",
                             @5: @"pinata.jpg",
                             @6: @"piramide.jpg",
                             @7: @"scotland.jpg",
                             @8: @"IMG_3399.jpg",
                             @9: @"notredame.jpg",
                             @10: @"salamanca.jpg",
                             }; */
    
    /* for (int i = 1; i <= 10; i++) {
        NSString *imageName = images[[NSNumber numberWithInt:i]];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [self.images addObject:image];
        }
    }
    
    UIImage *images = [[UIImage alloc] init]; */
    
    //We register this class, BLCImagesTableView Controller, for Key Value Observation of mediaItems below:
    
    [[BLCDataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.tableView registerClass:[BLCMediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                            name:UIKeyboardWillShowNotification
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                             name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}



- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [BLCDataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        // This "if" statement checks two things: (1) Is this update coming from the BLCDataSource object we registered with? (2) Is mediaItems the updated key?
    
        //We know mediaITems changed. Let's see what kind of change it is.
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            //Someone set a brand new images array
            [self.tableView reloadData];
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
                   kindOfChange == NSKeyValueChangeRemoval ||
                   kindOfChange == NSKeyValueChangeReplacement) {
            //We have an incremental change: inserted, deleted, or replaced images
            
            // Get a list of the index (or indices) that changed
            NSIndexSet *indexSetofChanges = change[NSKeyValueChangeIndexesKey];
            
            //Convert this NSIndexSet to an NSArray of NSIndexPaths (which is what the table view animation methods require)
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetofChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            // Call 'beginUpdates' to tell the table view we're about to make changes
            [self.tableView beginUpdates];
            
            //Tell the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            //Tell the table view that we're done telling it about changes, and to complete the animation
            [self.tableView endUpdates];
    
    }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Refresh the images
- (void) refreshControlDidFire:(UIRefreshControl *) sender {
    [[BLCDataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
    
}

- (void) infiniteScrollIfNecessary {
    [[BLCDataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row == [BLCDataSource sharedInstance].mediaItems.count - 1) {
        //The very last cell is on screen
        [self infiniteScrollIfNecessary];
        
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self items].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    
    //Configure the cell...
    BLCMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    
    cell.delegate = self;

    cell.mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    
    [BLCMediaTableViewCell heightForMediaItem:cell.mediaItem width:320];

        return cell;


}

#pragma mark - BLCMediaTableViewCellDelegate

- (void) cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    self.lastTappedImageView = imageView;
    
    BLCMediaFullScreenViewController *fullScreenVC = [[BLCMediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    fullScreenVC.transitioningDelegate = self;
    fullScreenVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

- (void) cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (cell.mediaItem.caption.length > 0) {
        [itemsToShare addObject:cell.mediaItem.caption];
    }
    
    if (cell.mediaItem.image) {
        [itemsToShare addObject:cell.mediaItem.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMediaTableViewCell *cell = (BLCMediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopComposingComment];
}

#pragma mark - Check to see if we need images right before a cell displays
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMedia *mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    if (mediaItem.downloadState == BLCMediaDownloadStateNeedsImage) {
        [[BLCDataSource sharedInstance] downloadImageForMediaItem:mediaItem];
    }
}
//
//- (NSArray *)visibleCells {
//    
//}

#pragma mark - Cell height

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    BLCMedia *item = [self items][indexPath.row];
    return [BLCMediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}




#pragma mark - Let's delete those rows

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    
    return YES;
}

- (void) cellWillStartComposingComment:(BLCMediaTableViewCell *)cell {
    self.lastSelectedCommentView = (UIView *)cell.commentView;
}

- (void) cell:(BLCMediaTableViewCell *)cell didComposeComment:(NSString *)comment {
    [[BLCDataSource sharedInstance] commentOnMediaItem:cell.mediaItem withCommentText:comment];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                        presentingController:(UIViewController *)presenting
                        sourceController:(UIViewController *)source {
    
    BLCMediaFullScreenAnimator *animator = [BLCMediaFullScreenAnimator new];
    animator.presenting = YES;
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    BLCMediaFullScreenAnimator *animator = [BLCMediaFullScreenAnimator new];
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

/*- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  BLCMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    if (indexPath.row == [cell countOfList]-1) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
    
} */


//tableView:canEditRowAtIndexPath

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete the row from the data source
        BLCMedia *item = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
        [[BLCDataSource sharedInstance] deleteMediaItem:item]; //This line is what actually does the deletion of the image. Before that, I may have been able to make the image dissappear but it was still in the data source and would show up again if I reloaded or something like that. (Paul 1/19/15)
    }
    
    
    /*
    If an image is deleted, remove it from the list
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the image from the image array
        
        Remove from the list - 12/28/14 success! :D
        [self.images removeObjectAtIndex:[indexPath row]];
        [tableView reloadData];
        
        
        [[self items] removeObjectAtIndex:[indexPath row]]; */
    
    /*
        [[BLCDataSource sharedInstance] removeDataItem:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];

        Below are the two failed attempts to delete the image that I tried
        #1 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        #2 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade]; */

        

    /*} else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    } */

}




/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */



- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMedia *item = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    if (item.image) {
        return 450;
    } else {
        return 250;
    } // By making a rough estimated height, the table view avoids calculating the height of every cell, and instead calculates one at a time as they scroll into the view
    
}



-(NSArray *)items {
    return [BLCDataSource sharedInstance].mediaItems;
}

- (void) cellDidPressLikeButton:(BLCMediaTableViewCell *)cell {
    [[BLCDataSource sharedInstance] toggleLikeOnMediaItem:cell.mediaItem];
}

#pragma mark - Update to Adjust Comment Keyboard
- (void) dealloc
{
    [[BLCDataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
} //Whenever a class is added as an observer, it must also remove itself as an observer later

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
}


#pragma mark - Keyboard Handling

bool keyboardShowing = NO;

- (void)keyboardWillShow:(NSNotification *)notification
{
    /*
    if (keyboardShowing) {

        UIEdgeInsets contentInsets = self.tableView.contentInset;
        contentInsets.bottom -= self.lastKeyboardAdjustment;
        
        UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        scrollIndicatorInsets.bottom -= self.lastKeyboardAdjustment;

        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    
    }
    keyboardShowing = YES;
     */
    
    if (!keyboardShowing) {
    
    // Get the frame of the keyboard within self.view's coordinate system
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
    CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
    
    // Get the frame of the comment view in the same coordinate system
    CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    CGFloat heightToScroll = 0;
    
    CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
    CGFloat commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates);
    CGFloat difference = commentViewY - keyboardY;
    
    if (difference > 0) {
        heightToScroll += difference;
    }
    
    if (CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates)) {
        // The two frames intersect (the keyboard would block the view)
        CGRect intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
        heightToScroll += CGRectGetHeight(intersectionRect);
    }
    
    if (heightToScroll > 0) {
        contentInsets.bottom += heightToScroll;
        scrollIndicatorInsets.bottom += heightToScroll;
        contentOffset.y += heightToScroll;
        
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
    }
    
    self.lastKeyboardAdjustment = heightToScroll;
        
        keyboardShowing = YES;
    } else {
        NSLog(@"Trying to show already shown keyboard");
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    if (keyboardShowing) {
        
        
        UIEdgeInsets contentInsets = self.tableView.contentInset;
        contentInsets.bottom -= self.lastKeyboardAdjustment;
        
        UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        scrollIndicatorInsets.bottom -= self.lastKeyboardAdjustment;
     //   scrollIndicatorInsets.bottom = scrollIndicatorInsets.bottom - self.lastKeyboardAdjustment;
       
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
        } completion:nil];
        
        
        keyboardShowing = NO;
    } else {
        NSLog(@"Trying to hide already hidden keyboard");
    
}

}

@end

