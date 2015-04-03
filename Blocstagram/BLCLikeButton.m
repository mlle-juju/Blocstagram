//
//  BLCLikeButton.m
//  Blocstagram
//
//  Created by Julicia on 3/13/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCLikeButton.h"
#import "BLCCircleSpinnerView.h"

#define kLikedStateImage @"heart-full"
#define kUnlikedStateImage @"heart-empty"

@interface BLCLikeButton ()
@property (nonatomic, strong) BLCCircleSpinnerView *spinnerView;

@end


@implementation BLCLikeButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.spinnerView = [[BLCCircleSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        self.likeButtonState = BLCLikeStateNotLiked; //the default state is not liked
    }
    
    return self;
    
}

//The spinner view's frame should be updated whenever the button's frame changes:
- (void) layoutSubviews {
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
}

//Update the button based on the set state:
- (void) setLikeButtonState:(BLCLikeState)likeState {
    _likeButtonState = likeState;
    
    NSString *imageName;
    
    switch (_likeButtonState) {
        case BLCLikeStateLiked:
        case BLCLikeStateUnliking:
            imageName = kLikedStateImage;
            break;
            
        case BLCLikeStateNotLiked:
        case BLCLikeStateLiking:
            imageName =kUnlikedStateImage;
    }
    
    switch (_likeButtonState) {
    case BLCLikeStateLiking:
        case BLCLikeStateUnliking:
            self.spinnerView.hidden = NO;
            self.userInteractionEnabled = NO;
            break;
            
        case BLCLikeStateLiked:
    case BLCLikeStateNotLiked:
            self.spinnerView.hidden = YES;
            self.userInteractionEnabled = YES;
    }
    
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}


@end
