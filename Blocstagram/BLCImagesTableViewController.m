//
//  BLCImagesTableViewController.m
//  Blocstagram
//
//  Created by Julicia on 12/17/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCImagesTableViewController.h"
#import "BLCMediaTableViewCell.h"

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
    } */
    
   // UIImage *images = [[UIImage alloc] init];
    
    
    [self.tableView registerClass:[BLCMediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    //[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(startEditing) userInfo:nil repeats:NO];
    
}

/*- (void)startEditing {
    [self setEditing:YES];
}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self infiniteScrollIfNecessary];
}*/


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
    cell.mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    
    [BLCMediaTableViewCell heightForMediaItem:cell.mediaItem width:320];

        return cell;


}

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
    //If an image is deleted, remove it from the list
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the image from the image array
        
        //Remove from the list - 12/28/14 success! :D
//        [self.images removeObjectAtIndex:[indexPath row]];
//        [tableView reloadData];
        
        
        //[[self items] removeObjectAtIndex:[indexPath row]];
        
        [[BLCDataSource sharedInstance] removeDataItem:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];

        /*Below are the two failed attempts to delete the image that I tried
        #1 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        #2 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade]; */

        

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}




/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */



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


@end
