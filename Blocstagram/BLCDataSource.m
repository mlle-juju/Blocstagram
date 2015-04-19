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
// Use quotes (" ") when importing local files; use angle brackets (< >) when importing external files (below).
#import <UICKeyChainStore.h>
#import <AFNetworking/AFNetworking.h>

@interface BLCDataSource () {
    NSMutableArray *_mediaItems; //An array must be accesible as an instance variable names _<key> or by a method named -<key> to be (which returns a reference to the array) to be key value compliant
}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSMutableArray *mediaItems;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;
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
        NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0;
        
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
        self.instagramOperationManager.responseSerializer = serializer;
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
       if (!self.accessToken) {
        [self registerForAccessTokenNotification]; // Register and respond to the notification that a user logs in
        } else {
            //Read the file at launch - find the file at the path and convert it into an array. If this read-code finds an array of at least one item, it displays it immediately. (We make a mutableCopy since the copy stored to disk is immutable.) If not, it gets the initial data from the server.
            

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                    //The 3 lines below are Paul's fix to update the init method in BLCDataSource to download images if necessary for each retrieved saved record
                        
                        for (BLCMedia *item in mutableMediaItems) {
                            [self downloadImageForMediaItem:item];
                        }
                        
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        
        
        
        }
    
    }
    return self; // Now the access token will be saved and restored upon app launch
    
}
- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
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

#pragma mark - Completion Handlers
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
        
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/feed"
         parameters:mutableParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                 
                 if (completionHandler) {
                     completionHandler(nil);
                 }
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completionHandler) {
                 completionHandler(error);
             }
                     
                     }];
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
//            [self downloadImageForMediaItem:mediaItem];
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
    
    if (tmpMediaItems.count > 0) {
        //write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }

        
        
        });
    }
    
}

- (void) downloadImageForMediaItem:(BLCMedia *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        
        mediaItem.downloadState = BLCMediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject;
                                            mediaItem.downloadState = BLCMediaDownloadStateHasImage;
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                        } else {
                                            
                                            mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError;
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                        
                                        mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError;
                                        
                                        if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                            // A networking problem
                                            if (error.code == NSURLErrorTimedOut ||
                                                error.code == NSURLErrorCancelled ||
                                                error.code == NSURLErrorCannotConnectToHost ||
                                                error.code == NSURLErrorNetworkConnectionLost ||
                                                error.code == NSURLErrorNotConnectedToInternet ||
                                                error.code == kCFURLErrorInternationalRoamingOff ||
                                                error.code == kCFURLErrorCallIsActive ||
                                                error.code == kCFURLErrorDataNotAllowed ||
                                                error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                                
                                                // It might work if we try again
                                                mediaItem.downloadState = BLCMediaDownloadStateNeedsImage;
                                            }
                                        }
         
                                
                                    }];
                                    }
         
         }
         
#pragma mark - Adding NSKeyedArchiver
//NSKeyedArchiver saves and reads the archived files
- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
    //This code creates a string containing an absolute path to the user's documents directory, like /somedir/someotherdir/filename
}

#pragma mark - Liking Media Items

- (void) toggleLikeOnMediaItem:(BLCMedia *)mediaItem {
    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken};
    
    if (mediaItem.likeState == BLCLikeStateNotLiked) {
        
        mediaItem.likeState = BLCLikeStateLiking;
        
        __block int numberOfLikes;
        [self.instagramOperationManager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                numberOfLikes = [(NSArray*)[(NSDictionary*)responseObject objectForKey:@"data"] count];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            numberOfLikes = -1;
        }];
        
        [self.instagramOperationManager
            POST:urlString
         parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = BLCLikeStateLiked;
            [self reloadMediaItem:mediaItem];
        }
         
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = BLCLikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
    } else if (mediaItem.likeState == BLCLikeStateLiked) {
        
        mediaItem.likeState = BLCLikeStateUnliking;
        
        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = BLCLikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = BLCLikeStateLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
    }
    
    [self reloadMediaItem:mediaItem];
}

- (void) reloadMediaItem:(BLCMedia *)mediaItem {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
}

#pragma mark - Comments

- (void) commentOnMediaItem:(BLCMedia *)mediaItem withCommentText:(NSString *)commentText {
    return;
    
    if (!commentText || commentText.length == 0) {
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"media/%@/comments", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken, @"text": commentText};
    
    [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        mediaItem.temporaryComment = nil;
        
        NSString *refreshMediaUrlString = [NSString stringWithFormat:@"media/%@", mediaItem.idNumber];
        NSDictionary *parameters = @{@"access_token": self.accessToken};
        [self.instagramOperationManager GET:refreshMediaUrlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            BLCMedia *newMediaItem = [[BLCMedia alloc] initWithDictionary:responseObject];
            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:newMediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self reloadMediaItem:mediaItem];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", operation.responseString);
        [self reloadMediaItem:mediaItem];
    }];
}

@end
