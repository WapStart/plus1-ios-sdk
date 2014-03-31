//
//  MRAdViewBrowsingController.h
//  MoPub
//
//  Created by Andrew He on 12/22/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdBrowserController.h"

@class WPAdView;

@interface WPAdViewBrowsingController : NSObject <MPAdBrowserControllerDelegate> {
	WPAdView *_view;
	UIViewController *_viewControllerForPresentingModalView;
}

@property (nonatomic, assign) UIViewController *viewControllerForPresentingModalView;

- (id)initWithAdView:(WPAdView *)adView;
- (void)openBrowserWithUrlString:(NSString *)urlString enableBack:(BOOL)back
                   enableForward:(BOOL)forward enableRefresh:(BOOL)refresh;

@end
