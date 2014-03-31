//
//  MRAdViewBrowsingController.m
//  MoPub
//
//  Created by Andrew He on 12/22/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import "WPAdViewBrowsingController.h"
#import "WPAdView.h"
//#import "MRAdView+Controllers.h"

@implementation WPAdViewBrowsingController
@synthesize viewControllerForPresentingModalView = _viewControllerForPresentingModalView;

- (id)initWithAdView:(WPAdView *)adView {
    self = [super init];
    if (self) {
        _view = adView;
    }
    return self;
}

- (void)openBrowserWithUrlString:(NSString *)urlString enableBack:(BOOL)back
                   enableForward:(BOOL)forward enableRefresh:(BOOL)refresh {
    NSURL *url = [NSURL URLWithString:urlString];
    MPAdBrowserController *controller = [[MPAdBrowserController alloc] initWithURL:url 
                                                                          delegate:self];
    
    //[_view adWillPresentModalView];
    [self.viewControllerForPresentingModalView presentModalViewController:controller animated:YES];
    [controller release];
}

#pragma mark -
#pragma mark MPAdBrowserControllerDelegate

- (void)dismissBrowserController:(MPAdBrowserController *)browserController {
    [self dismissBrowserController:browserController animated:YES];
}

- (void)dismissBrowserController:(MPAdBrowserController *)browserController 
                        animated:(BOOL)animated {
    //[self.viewControllerForPresentingModalView dismissModalViewControllerAnimated:animated];

    //[_view adDidDismissModalView];
}

@end