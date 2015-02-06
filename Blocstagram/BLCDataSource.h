//
//  BLCDataSource.h
//  Blocstagram
//
//  Created by Julicia on 1/2/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCMedia;

typedef void (^BLCNewItemCompletionBlock)(NSError *error);

@interface BLCDataSource : NSObject

+(instancetype) sharedInstance; //This will return the single instance that exists for this class. If the instance has not yet been created then this method will create it before returning it.

@property (nonatomic, strong, readonly) NSArray *mediaItems; //We make this property readonly to make sure that other classes aren't able to modify it
@property (nonatomic, strong, readonly) NSString *accessToken;

//-(void)removeDataItem:(NSUInteger)indexToRemove;

- (void) deleteMediaItem:(BLCMedia *)item;

- (void) requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;

- (void) requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;

+ (NSString *) instagramClientID;

@end
