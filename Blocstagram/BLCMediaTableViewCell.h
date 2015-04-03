//
//  BLOCMediaTableViewCell.h
//  Blocstagram
//
//  Created by Julicia on 1/11/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BLCMedia, BLCMediaTableViewCell;
@protocol BLCMediaTableViewCellDelegate <NSObject>

- (void) cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void) cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void) cellDidPressLikeButton:(BLCMediaTableViewCell *)cell;


@end

@interface BLCMediaTableViewCell : UITableViewCell

@property (nonatomic, strong) BLCMedia *mediaItem;
+ (CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width;
@property (nonatomic, weak) id <BLCMediaTableViewCellDelegate> delegate;

@end
