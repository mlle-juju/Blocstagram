//
//  BLCMediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Julicia on 2/22/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BLCMediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, weak) UIImageView *cellImageView;
//We have two properties. The first, presenting, will let us know if the animation is a presenting animation (if not, it's a dismissing animation). The second, cellImageView, will reference the image view from the media table view cell (the image view the user taps on).




@end
