/**
 * WPMainDemoViewController.m
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

#import "WPMainDemoViewController.h"

// Uncomment the line bellow if you want to use Plus1 WapStart Conversion SDK
//#import "Plus1ConversionTracker.h"

@implementation WPMainDemoViewController

- (id) initMainDemoViewController
{
	if (self = [super init])
	{
		demo1Controller = [[WPDemo1ViewController alloc] initDemoViewController];
		demo2Controller = [[WPDemo2ViewController alloc] initDemoViewController];
		demo3Controller = [[WPDemo3ViewController alloc] initDemoViewController];
		
		self.viewControllers = [NSArray arrayWithObjects:demo1Controller, demo2Controller, demo3Controller, nil];
	}
	return self;
}

// Uncomment the block bellow if you want to use Plus1 WapStart Conversion SDK
/**
- (void) viewDidLoad
{
    Plus1ConversionTracker *tracker = [[Plus1ConversionTracker alloc] initWithTrackId:Plus1TrackId andCallbackUrl:@"wsp1demo://ru.wapstart.plus1.ios.demoapp"];
    [tracker run];
    [tracker release];
}
*/

- (void) dealloc
{
	[demo1Controller release];
	[demo2Controller release];
	[demo3Controller release];
    [super dealloc];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
