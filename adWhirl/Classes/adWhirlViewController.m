/**
 * adWhirlViewController.m
 *
 * Copyright (c) 2010, Alexander Klestov <a.klestov@co.wapstart.ru>
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 * 
 *   * Redistributions of source code must retain the above copyright notice, 
 *     this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright notice, 
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   * Neither the name of the "Wapstart" nor the names of its contributors 
 *     may be used to endorse or promote products derived from this software 
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "adWhirlViewController.h"
#import "WPBannerInfo.h"

@implementation adWhirlViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	AdWhirlView *adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
	adView.autoresizingMask = 
		UIViewAutoresizingFlexibleLeftMargin 
		| UIViewAutoresizingFlexibleRightMargin;
		
	[self.view addSubview:adView];
	
	WPBannerRequestInfo *requestInfo = 
		[[WPBannerRequestInfo alloc] initWithApplicationId:/* PLACE YOUR APPICATION ID HERE */];
    
	plus1Banner = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo];
	plus1Banner.showCloseButton = NO;
	plus1Banner.autoupdateTimeout = 0;
	plus1Banner.delegate = self;
	plus1Banner.hideWhenEmpty = YES;
	[plus1Banner setFrame:adView.bounds];
	[requestInfo release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[plus1Banner release];

    [super dealloc];
}

# pragma mark AdWhirlDelegate methods

- (NSString *)adWhirlApplicationKey {
  return AdWhirlKey;
}

- (UIViewController *)viewControllerForPresentingModalView {
  return self;
}

# pragma mark WPBannerView delegate methods

- (void) bannerViewPressed:(WPBannerView *) bannerView {
	if (plus1Banner.bannerInfo.responseType == WPBannerResponseWebSite)
		[[UIApplication sharedApplication] 
			openURL:[NSURL URLWithString:plus1Banner.bannerInfo.link]];

	[plus1Banner reloadBanner];
}

# pragma mark Plus1 Custom Event 

- (void) plus1CustomEvent:(AdWhirlView *) adWhirlView {
	[plus1Banner reloadBanner];
	[adWhirlView replaceBannerViewWith:plus1Banner];
}

@end
