//
//  BLCUser.h
//  Blocstagram
//
//  Created by Julicia on 12/29/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
// 12.29.14 I imported UIKit because it was recommended on StackOverflow to resolve the error of "Unknown type name 'UIImage'" on the property line

@interface BLCUser : NSObject

-(instancetype) initWithDictionary:(NSDictionary *)userDictionary;

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSURL *profilePictureURL;
@property (nonatomic, strong) UIImage *profilePicture;


@end
