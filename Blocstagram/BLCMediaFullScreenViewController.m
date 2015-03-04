//
//  BLCMediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Julicia on 2/22/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCMediaFullScreenViewController.h"
#import "BLCMedia.h"

@interface BLCMediaFullScreenViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) BLCMedia *media;
//We start by importing BLCMedia and creating a property to hang on to it. We also declare that this class conforms to the UIScrollViewDelegate protocol
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation BLCMediaFullScreenViewController
- (instancetype) initWithMedia:(BLCMedia *)media {
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    
    return self;
}

/* For actually displaying the image, we'll use a UIScrollView. Scroll views don't just slide content around on the screen - they also make it easy to zoom in and out. 
 
 The UIScrollView class can have a delegate that must adopt the UIScrollViewDelegate protocol. For zooming and panning to work, the delegate must implement both viewForZoomingInScrollView: and scrollViewDidEndZooming:withView:atScale:; in addition, the maximum (maximumZoomScale) and minimum (minimumZoomScale) zoom scale must be different.
 */
 

- (void)viewDidLoad {
    [super viewDidLoad];
//We'll set up the scroll view and image view in this method.
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.media.image.size;
    
    /*
     We create and configure a scroll view, and add it as the only subview of self.view. We then create an image view, set the image, and add it as a subview of the scroll view.
     
     You haven't seen a scroll view's contentSize before: this property represents the size of the content view, which is the content being scrolled around. In our case, we're simply scrolling around an image, so we'll pass in its size
     */
    
    
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
    self.shareButton.frame = CGRectMake(0, 0, 100, 80);
    [self.shareButton addTarget:self action:@selector(shareButtonFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
    
}

#pragma mark - Gesture Recognizers

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareButtonFired:(id)sender {
    NSLog(@"you hit share");
    self.shareButton = sender;
    UIActivityViewController *shareFullScreenPhotoActivityViewController;
    [self presentViewController:shareFullScreenPhotoActivityViewController animated:YES completion:nil]; 
    
    
    /* if (self.shareButton == self.shareButton.touchInside) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:(NSArray *) applicationActivities:nil];
        [BLCMediaFullScreenViewController load:activityViewController
                                      animated:YES
                                    completion:^{
                                    }];
    } */
    
}

- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

#pragma mark - Layout the Views

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds; //First, the scroll view's frame is set to the view's bounds. This way, the scroll view will always take up all of the view's space.
    
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1; //maximumZoomScale will always be 1 (representing 100%). We could make this bigger, but then the image would just start to get pixelated if the user zooms in too much.
    

    
}

- (void)centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundSize.width) {
        contentsFrame.origin.x = (boundSize.width - CGRectGetWidth(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.x = 0;
    }

    if (contentsFrame.size.height < boundSize.height) {
        contentsFrame.origin.y = (boundSize.height - CGRectGetHeight(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self centerScrollView];
}

#pragma mark - UIScroll View Delegate
//The first method tells the scroll view which view to zoom in and out on; the latter calls centerScrollView when the user has changed the zoom level.

//Method #1
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//Method #2
- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
