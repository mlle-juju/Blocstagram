//
//  BlocstagramTests.m
//  BlocstagramTests
//
//  Created by Julicia on 12/17/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCDataSource.h"
@interface BlocstagramTests : XCTestCase

@end

@implementation BlocstagramTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDataSource {
    // This is an example of a functional test case.
    BLCDataSource *ds = [BLCDataSource sharedInstance];
    NSInteger sizeOfData = ds.mediaItems.count;
    [ds deleteMediaItem:ds.mediaItems[0]];
    
    XCTAssert(ds.mediaItems.count == (sizeOfData-1), @"Wrong number of items, should be %ld but got %ld",(sizeOfData-1),ds.mediaItems.count);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
