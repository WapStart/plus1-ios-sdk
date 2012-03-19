/**
 * WPDemo3ViewController.m
 *
 * Copyright (c) 2010, Alexey Goliatin <alexey.goliatin@gmail.com>
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

#import "WPDemo3ViewController.h"

@interface WPDemo3ViewController (PrivateMethods)

- (void) layoutSubviews;

@end


@implementation WPDemo3ViewController

- (id) initDemoViewController
{
    if ((self = [super initWithNibName:nil bundle:nil]))
	{
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"hidden"
														   image:nil
															 tag:3];
		self.tabBarItem = item;
		
		[item release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor orangeColor];
	
	logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
	logoView.contentMode = UIViewContentModeScaleAspectFit;
	[self.view addSubview:logoView];
	
	WPBannerRequestInfo *requestInfo = [[WPBannerRequestInfo alloc] initWithApplicationId:APPLICATION_ID];
	
	topBannerView = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo];
	topBannerView.showCloseButton = YES;
	topBannerView.delegate = self;
	topBannerView.hideWhenEmpty = YES;
	topBannerView.autoupdateTimeout = 20;
	[topBannerView setHidden:YES];
	[self.view addSubview:topBannerView];
	
	[requestInfo release];
	[topBannerView reloadBanner];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self layoutSubviews];
}

- (void) layoutSubviews
{
	logoView.frame = self.view.bounds;
	
	[topBannerView showFromTop:NO];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	topBannerView.orientation = toInterfaceOrientation;

	[self layoutSubviews];
}

- (void) viewDidUnload
{
    [super viewDidUnload];
	
	[logoView removeFromSuperview];
	[logoView release], logoView = nil;
	
	[topBannerView removeFromSuperview];
	[topBannerView release], topBannerView = nil;
}


- (void) dealloc
{
	[topBannerView release];
	[logoView release];
    [super dealloc];
}

- (void) bannerViewPressed:(WPBannerView *) bannerView
{
	//if (bannerView.bannerInfo.responseType == WPBannerResponseWebSite)
	//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:bannerView.bannerInfo.link]];
	
	[topBannerView hide:YES];
}

@end