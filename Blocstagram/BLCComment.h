//
//  BLCComment.h
//  Blocstagram
//
//  Created by Julicia on 1/2/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCUser;

@interface BLCComment : NSObject <NSCoding>

- (instancetype) initWithDictionary:(NSDictionary *)commentDictionary;

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) BLCUser *from;
@property (nonatomic, strong) NSString *text;

@end
