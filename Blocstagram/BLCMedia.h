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

@class BLCUser;

@interface BLCMedia : NSObject <NSCoding>
- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary;

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) BLCUser *user;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *comments;

@end
