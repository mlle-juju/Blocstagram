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
    
    
}


- (void) dealloc
{
    [[BLCDataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
} //Whenever a class is added as an observer, it must also remove itself as an observer later

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
        return 350;
    } else {
        return 150;
    } // By making a rough estimated height, the table view avoids calculating the height of every cell, and instead calculates one at a time as they scroll into the view
    
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(NSArray *)items {
    return [BLCDataSource sharedInstance].mediaItems;
}

- (void) cellDidPressLikeButton:(BLCMediaTableViewCell *)cell {
    [[BLCDataSource sharedInstance] toggleLikeOnMediaItem:cell.mediaItem];
}


@end

