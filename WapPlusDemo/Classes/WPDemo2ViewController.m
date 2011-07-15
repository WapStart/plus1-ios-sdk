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
#import "WPBannerInfo.h"

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
	[bannerView release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

	WPBannerRequestInfo *requestInfo = [[WPBannerRequestInfo alloc] initWithApplicationId:APPLICATION_ID];
	
	bannerView = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo];
	bannerView.showCloseButton = YES;
	bannerView.autoupdateTimeout = 10;
	bannerView.delegate = self;
	[bannerView reloadBanner];
	
	[requestInfo release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	if (bannerView.isEmpty)
		return;

	bannerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, [bannerView bannerHeight]);
	self.tableView.tableHeaderView = nil;
	self.tableView.tableHeaderView = bannerView;
	
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
    return 100;
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
	
	bannerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, [bannerView bannerHeight]);
	self.tableView.tableHeaderView = nil;
	self.tableView.tableHeaderView = bannerView;
	[self.tableView reloadData];	
}

- (void) bannerViewPressed:(WPBannerView *) bnView
{
	if (bannerView.bannerInfo.responseType == WPBannerResponseWebSite)
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:bannerView.bannerInfo.link]];
	
	[bannerView reloadBanner];
}

- (void) bannerViewInfoLoaded:(WPBannerView *) bnView
{
	if (bannerView.isEmpty)
		return;
	
	bannerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, [bannerView bannerHeight]);
	self.tableView.tableHeaderView = nil;
	self.tableView.tableHeaderView = bannerView;
	[self.tableView reloadData];
}

- (void) bannerViewMinimizedStateChanged:(WPBannerView *) bnView
{
	self.tableView.tableHeaderView = nil;
	self.tableView.tableHeaderView = bannerView;
	[self.tableView reloadData];
}

@end

