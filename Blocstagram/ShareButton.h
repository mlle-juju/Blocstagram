//
//  ShareButton.h
//  Blocstagram
//
//  Created by Julicia on 2/26/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ShareButton;
@protocol ShareButton <NSObject>

@optional

- (void) floatingToolbar:(ShareButton *)toolbar didSelectButtonWithTitle:(NSString *)title;
- (void) floatingToolbar:(ShareButton *)toolbar didLongPressButtonWithTitle:(NSString *)title;
- (void) floatingToolbar:(ShareButton *)toolbar didTryToPanWithOffset:(CGPoint)offset;
- (void) floatingToolbar:(ShareButton *)toolbar didTryToScaleToSize:(CGFloat)newScale;

@end

@interface ShareButton : UIView
- (instancetype) initWithFourTitles:(NSArray *)titles;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;
- (void) rotateColors;

@property (nonatomic, weak) id <ShareButton> delegate;




@end
