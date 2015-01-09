//
//  BLCImagesTableViewController.h
//  Blocstagram
//
//  Created by Julicia on 12/17/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLCDataSource.h"
#import "BLCMedia.h"
#import "BLCUser.h"
#import "BLCComment.h"


@interface BLCImagesTableViewController : UITableViewController
//@property (nonatomic, strong) NSMutableArray *images;
//@property (nonatomic, strong) UIImage *images;

    -(NSArray *)items;
@end
