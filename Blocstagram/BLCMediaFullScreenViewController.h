//
//  BLCMediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Julicia on 2/22/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLCMedia;
@interface BLCMediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *shareButton;

- (instancetype) initWithMedia:(BLCMedia *)media;
//This is just like other view controllers I made - it has a custom initializer; in this one, we pass it a BLCMedia object for it to display.

- (void) centerScrollView;


@end
