//
//  BLCMedia.h
//  Blocstagram
//
//  Created by Julicia on 1/2/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BLCComment.h"

/*We must track which media items have been downloaded, and which still need to be downloaded.
 Let's start by declaring an enumeration in BLCMedia.h. typedef NS_ENUM declares BLCMediaDownloadState as equivalent to NSInteger, with four predefined values (0, 1, 2, and 3.) */

typedef NS_ENUM(NSInteger, BLCMediaDownloadState) {
    BLCMediaDownloadStateNeedsImage = 0,
    BLCMediaDownloadStateDownloadInProgress = 1,
    BLCMediaDownloadStateNonRecoverableError = 2,
    BLCMediaDownloadStateHasImage = 3
};

@class BLCUser;

@interface BLCMedia : NSObject <NSCoding>
- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary;

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) BLCUser *user;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, assign) BLCMediaDownloadState downloadState; //We'll keep track of an individual media item's download state in this property. Property is "assign" instead of "strong" because BLCMediaDownloadState is a simple type (NSInteger) not an object


@end
