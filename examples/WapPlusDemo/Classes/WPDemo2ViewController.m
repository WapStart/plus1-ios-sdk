/**
 * WPDemo2ViewController.m
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

#import "WPDemo2ViewController.h"
#import "WPConst.h"

@implementation WPDemo2ViewController


#pragma mark -
#pragma mark Initialization

- (id) initDemoViewController
{
    if ((self = [super initWithStyle:UITableViewStylePlain]))
	{
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"table"
														   image:nil
															 tag:2];
		self.tabBarItem = item;
		
		[item release];
    }
    return self;
}

- (void) dealloc
{
	[containerView release];
	[bannerView release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

	WPBannerRequestInfo *requestInfo = [[WPBannerRequestInfo alloc] initWithApplicationId:PLUS1_APP_ID];
	
	bannerView = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo];
	bannerView.showCloseButton = YES;
	bannerView.autoupdateTimeout = UPDATE_BANNER_TIMEOUT;
	bannerView.delegate = self;
	[bannerView reloadBanner];

	containerView = [[UIView alloc] initWithFrame:bannerView.frame];
	[containerView addSubview:bannerView];

	[requestInfo release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	self.tableView.tableHeaderView = containerView;
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"cell %d", indexPath.row+1];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (bannerView.isEmpty)
		return;

	bannerView.orientation = toInterfaceOrientation;
	[self.tableView reloadData];
}

- (void) bannerViewInfoLoaded:(WPBannerView *) bnView
{
	if (bannerView.isEmpty)
		return;

	bannerView.hidden = false;
	[self.tableView reloadData];
}

- (void) bannerViewMinimizedStateWillChange:(WPBannerView *) bnView
{
	CGRect frame = bnView.frame;
	frame.size.height =
		[bnView isMinimized]
			? BANNER_HEIGHT
			: MINIMIZED_BANNER_HEIGHT;

	[containerView setFrame:frame];
}

- (void) bannerViewMinimizedStateChanged:(WPBannerView *) bnView
{
	self.tableView.tableHeaderView = nil;
	self.tableView.tableHeaderView = containerView;
	[self.tableView reloadData];
}

@end

