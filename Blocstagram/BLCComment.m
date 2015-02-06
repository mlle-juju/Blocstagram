//
//  BLCComment.m
//  Blocstagram
//
//  Created by Julicia on 1/2/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCComment.h"
#import "BLCUser.h"
@implementation BLCComment

-(instancetype) initWithDictionary:(NSDictionary *)commentDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = commentDictionary[@"id"];
        self.text = commentDictionary[@"text"];
        self.from = [[BLCUser alloc] initWithDictionary:commentDictionary[@"from"]];
    }
    return self;

}

@end
