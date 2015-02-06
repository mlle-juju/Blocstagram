//
//  BLCDataSource.m
//  Blocstagram
//
//  Created by Julicia on 1/2/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCDataSource.h"
#import "BLCUser.h"
#import "BLCMedia.h"
#import "BLCComment.h"
#import "BLCLoginViewController.h"


@interface BLCDataSource () {
    NSMutableArray *_mediaItems; //An array must be accesible as an instance variable names _<key> or by a method named -<key> to be (which returns a reference to the array) to be key value compliant
}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSMutableArray *mediaItems;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@end

@implementation BLCDataSource

#pragma mark - Singleton Pattern/Instance Type and Access Token
+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

/*To make sure we only create a single instance of this class we use a function called dispatch_once. This function takes a block of code and ensures that it only runs once. We first define a variable to static dispatch_once_t once;. This variable stores the completion status of the dispatch_once task. */

- (instancetype) init {
    self = [super init];
    
    if (self) {
        [self registerForAccessTokenNotification]; // Register and respond to the notification that a user logs in
    
    }
    return self;
    
}
- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        //Got a token, populate the initial data
        [self populateDataWithParameters:nil completionHandler:nil];
        
    }];
}


#pragma mark - Client ID
+(NSString *) instagramClientID {
    return @"d0259d0cb8b740af9b8bc4c0661d1ec4";
}
/*
#pragma mark - Random data, comment, and user generator
- (void) addRandomData {
    NSMutableArray *randomMediaItems = [NSMutableArray array];
    
    for (int i = 1; i <= 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image) {
            BLCMedia *media = [[BLCMedia alloc] init];
            media.user = [self randomUser];
            media.image = image;
            
            NSUInteger commentCount = arc4random_uniform(10);
            NSMutableArray *randomComments = [NSMutableArray array];
            
            for (int i = 0; i <= commentCount; i++) {
                BLCComment *randomComment = [self randomComment];
                [randomComments addObject:randomComment];
            }
            
            media.comments = randomComments;
            
            [randomMediaItems addObject:media];
        }
    }
    
    self.mediaItems = randomMediaItems;
}

- (BLCUser *) randomUser {
    BLCUser *user = [[BLCUser alloc] init];
    user.userName = [self randomStringOfLength:arc4random_uniform(10)];
    
    NSString *firstName = [self randomStringOfLength:arc4random_uniform(7)];
    NSString *lastName = [self randomStringOfLength:arc4random_uniform(12)];
    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    return user;
}

- (BLCComment *) randomComment {
    BLCComment *comment = [[BLCComment alloc] init];
    
    comment.from = [self randomUser];
    
    NSUInteger wordCount = arc4random_uniform(20);
    
    NSMutableString *randomSentence = [[NSMutableString alloc] init];
    
    for (int i = 0; i <= wordCount; i++) {
        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12)];
        [randomSentence appendFormat:@"%@ ", randomWord];
        
    }
    
    comment.text = randomSentence;
    
    return comment;
    
}

- (NSString *) randomStringOfLength:(NSUInteger) len {
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return [NSString stringWithString:s];
}


-(void)removeDataItem:(NSUInteger)indexToRemove
{
    [(NSMutableArray*)self.mediaItems removeObjectAtIndex:indexToRemove];
}
*/


#pragma mark - Key/Value Observing 
//Below, we add accessor methods to allow observers to be notified when the content of the array changes:
- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
} //This method will be discovered by key name. countOf<Key> is one of the required accessor methods. It indicates that the signature mut begin with countOf which must then be proceeded by thacapitalized name of your key. Our key is mediaItems and the capitalized version of it is MediaItems, hence the full signature of the method will be countOfMediaItems



- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
    }

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(BLCMedia *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

#pragma mark - Delete an image
- (void) deleteMediaItem:(BLCMedia *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

#pragma mark - Weird completion Handlers
- (void) requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    self.thereAreNoMoreOlderMessages = NO;

    if (self.isRefreshing == NO ) {
        self.isRefreshing = YES;
        /*
        BLCMedia *media = [[BLCMedia alloc] init];
        media.user = [self randomUser];
        media.image = [UIImage imageNamed:@"10.jpg"];
        media.caption = [self randomStringOfLength:7];
        
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
        [mutableArrayWithKVO insertObject:media atIndex:0];
        */
        
        /*Need to add images here
        
        self.isRefreshing = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }*/
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters = @{@"min_id": minID};
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

- (void) requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages ==NO) {
        self.isLoadingOlderItems = YES;
        /*
        BLCMedia *media = [[BLCMedia alloc] init];
        media.user = [self randomUser];
        media.image = [UIImage imageNamed:@"1.jpg"];
        media.caption = [self randomStringOfLength:7];
        
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
        [mutableArrayWithKVO addObject:media];
        
        Need to add images here
        self.isLoadingOlderItems =  NO;
        if (completionHandler) {
            completionHandler(nil);
        } */
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters = @{@"max_id": maxID};
       
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
        
        
    }
}
#pragma mark - Get media data from Instagram and use access token
- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        //only try to get the data if there's an access token
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //do the network request in the background, so the UI doesn't lock up
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                //for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url ) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                if (responseData) {
                    NSError *jsonError;
                    NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    
                    if (feedDictionary) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //done networking, go back on the main thread
                            [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                            if (completionHandler) {
                                completionHandler(nil);
                            }
                        });
                    } else if (completionHandler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(jsonError);
                        });
                    }
                } else if (completionHandler) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        /*done networking, go back on the main thread
                        [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters]; */
                        completionHandler(webError);
                    });
                }
            }
        
        });
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    //NSLog(@"%@", feedDictionary);
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        BLCMedia *mediaItem = [[BLCMedia alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem];
        }
    }
    
   /* [self willChangeValueForKey:@"mediaItems"];
    self.mediaItems = tmpMediaItems;
    [self didChangeValueForKey:@"mediaItems"]; */
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        //This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    } else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        }
        
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];

        
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    
}

- (void) downloadImageForMediaItem:(BLCMedia *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            
            NSURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (image) {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                    });
                }
            } else {
                NSLog(@"Error downloading image: %@", error);
            }
                
        });
    }
}



@end
