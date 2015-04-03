//
//  BLCLoginViewController.m
//  Blocstagram
//
//  Created by Julicia on 1/26/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCLoginViewController.h"
#import "BLCDataSource.h"

@interface BLCLoginViewController () <UIWebViewDelegate>
//Below, we use a UIWebView for the user to login. This is the property for it:
@property (nonatomic, weak) UIWebView *webView;

@end

@implementation BLCLoginViewController

NSString *const BLCLoginViewControllerDidGetAccessTokenNotification = @"BLCLoginViewControllerDidGetAccessTokenNotification";

- (NSString *)redirectURI {
    return @"http://bloc.io"; //This is the redirect URI I specified when I registered a client on Instagram
    
}
#pragma mark - Create the Webview
//I create the web view and set its delegate
-(void)loadView {
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    self.webView = webView;
    self.view = webView;
    
}

#pragma mark - Here's the navigation bar title at the top
- (instancetype) init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Login", nil);
    }
    return self;
}

#pragma mark - Let's go to the correct login page
//In order to get the correct login page, I need to write below my Instagram Client ID, which is stored in BLCDataSource
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", [BLCDataSource instagramClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url ) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    
    
}

- (void)goHome {
    /*
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [BLCDataSource instagramClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url ) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    */
    while (self.webView.canGoBack) {
        [self.webView goBack];
    }

    self.navigationItem.leftBarButtonItem = nil;
    NSLog(@"Went Home");
}


/*When the login controller gets deallocated, we need to do 2 things:
1. Set the web view's delegate to nil (this is a quirk of UIWebViewl most objects don't require this)
2. Clear cookies set by the Instagram website. Wheeeeeeeee !
 */

- (void) dealloc {
    //Removing this line causes a weird flickering effect when you relaunch the app after loggin in, as the web view is briefly displayed, automatically authenicated with cookies, returns the access token, and dismisses the login view, sometimes in <1 second
    [self clearInstagramCookies];
    
    //see https://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006951-CH3-DontLinkElementID_1
    self.webView.delegate = nil;
    
}
#pragma mark - Cookies! :D
- (void) clearInstagramCookies {
    //cookies! :D
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if(domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}
//NSHTTPCoo Get that access token girl
//This method searches for a URL containing the redirect URI, and then sets the access token to everything after access_token=.
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:[self redirectURI]]) {
        //This cotnains our auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        
        //[NSNotificationCenter defaultCenter] is another example of the singleton pattern

        [[NSNotificationCenter defaultCenter] postNotificationName:BLCLoginViewControllerDidGetAccessTokenNotification object:accessToken];
        
      //  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
          self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        return NO;
        
    } else {
        if (webView.canGoBack) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(goHome)];

        }
    }
    return YES;

    /*
     We're using a new method of communication here called a notification. A notification is a one-to-many form of communication like key-value observing, but less formal. One object (in our case, the login view controller) sends a communication to anyone who's registered when something noteworthy happens (in our case, when an access token is obtained).
     

     */

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
