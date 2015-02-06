//
//  BLCLoginViewController.h
//  Blocstagram
//
//  Created by Julicia on 1/26/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCLoginViewController : UIViewController
//Below, I declare a constant string. Anyone who wants to be notified when an access token is obtained will use the string below - BLCLoginViewControllerDidGetAccessTokenNotification
extern NSString *const BLCLoginViewControllerDidGetAccessTokenNotification;


@end
