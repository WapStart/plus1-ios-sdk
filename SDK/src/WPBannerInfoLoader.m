/**
 * WPBannerInfoLoader.m
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

#import "WPBannerInfoLoader.h"
#import "WPUtils.h"
#import "WPLogging.h"
#import "UIDevice+IdentifierAddition.h"

#define WPRotatorUrl @"http://ro.plus1.wapstart.ru/?area=applicationWebView&version=2&sdkver=2.0.0"
#define WPSessionKey @"WPClientSessionId"

@interface WPBannerInfoLoader (PrivateMethods)

- (void) initializeClientSessionId;
- (NSURL *) requestUrl;
- (NSString *) getDisplayMetrics;

@end


@implementation WPBannerInfoLoader

@synthesize bannerRequestInfo = _bannerRequestInfo;
@synthesize delegate = _delegate;
@synthesize data = _data;
@synthesize adType = _adType;
@synthesize containerRect = _containerRect;

- (id) init
{
	if ((self = [super init]) != nil)
	{
		_bannerRequestInfo = nil;
		
		[self initializeClientSessionId];

		self.data = [NSMutableData data];
	}
	return self;
}

- (id) initWithRequestInfo:(WPBannerRequestInfo *) requestInfo
{
	if ((self = [super init]) != nil)
	{
		_bannerRequestInfo = [requestInfo retain];

		[self initializeClientSessionId];

		self.data = [NSMutableData data];
	}
	return self;
}

- (void) dealloc
{
	[self cancel];
	
	[_bannerRequestInfo release];
	[_clientSessionId release];
	[_data release];
	[_adType release];

	[super dealloc];
}

- (void) initializeClientSessionId
{
	if (_clientSessionId != nil)
		return;
	
	_clientSessionId = [[[NSUserDefaults standardUserDefaults] objectForKey:WPSessionKey] retain];
	
	if (_clientSessionId != nil)
		return;

	_clientSessionId = [[WPUtils sha1Hash:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]] retain];
	[[NSUserDefaults standardUserDefaults] setObject:_clientSessionId forKey:WPSessionKey];
}

- (NSURL *) requestUrl
{
	NSMutableString *url = [NSMutableString stringWithString:WPRotatorUrl];
	
	[url appendFormat:@"&id=%d", _bannerRequestInfo.applicationId];
	[url appendFormat:@"&pageId=%@", _bannerRequestInfo.pageId];
	
	if (_bannerRequestInfo.gender != WPGenderUnknown)
		[url appendFormat:@"&sex=%d", _bannerRequestInfo.gender];
	
	if (_bannerRequestInfo.age > 0)
		[url appendFormat:@"&age=%d", _bannerRequestInfo.age];
    
    if (_bannerRequestInfo.login != nil)
        [url appendFormat:@"&login=%@", _bannerRequestInfo.login];
	
    if (_bannerRequestInfo.location != nil)
        [url appendFormat:@"&location=%.8f;%.8f", 
           _bannerRequestInfo.location.coordinate.latitude,
           _bannerRequestInfo.location.coordinate.longitude
        ];
    
	return [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *) getDisplayMetrics 
{
	CGRect screenRect = [WPUtils getApplicationFrame];
	return [NSString stringWithFormat:@"%.0fx%.0f", screenRect.size.width, screenRect.size.height];
}

- (BOOL) start
{
	if (_bannerRequestInfo == nil || _urlConnection != nil)
		return NO;

	NSMutableURLRequest *theRequest =
		[NSMutableURLRequest requestWithURL:[self requestUrl]
								cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
							timeoutInterval:60];

	// Setting up headers
	[theRequest addValue:[NSString stringWithFormat:@"wssid=%@", _clientSessionId]
	  forHTTPHeaderField:@"Cookies"];

	[theRequest setValue:[WPUtils getUserAgent] forHTTPHeaderField:@"User-Agent"];
	[theRequest setValue:@"iOS" forHTTPHeaderField:@"x-application-type"];
	[theRequest setValue:[self getDisplayMetrics] forHTTPHeaderField:@"x-display-metrics"];

	if (!CGRectIsNull(self.containerRect)) {
		NSString* metrics = [NSString stringWithFormat:@"%.0fx%.0f", self.containerRect.size.width, self.containerRect.size.height];
		[theRequest setValue:metrics forHTTPHeaderField:@"x-container-metrics"];
		WPLogDebug(@"x-container-metrics: %@", metrics);
	}

	_urlConnection = [[NSURLConnection alloc] initWithRequest:theRequest
													 delegate:self 
											 startImmediately:YES];
	
	if (_urlConnection == nil)
		return NO;

	return YES;
}

- (void) cancel
{
	if (_urlConnection == nil)
		return;
	
	[_urlConnection cancel];
	[_urlConnection release], _urlConnection = nil;

	[self.data setLength:0];
	self.adType = nil;
	
	[_delegate bannerInfoLoader:self didFailWithCode:WPBannerInfoLoaderErrorCodeCancel];
}

//////////////////////////////////////////////////////////
//       NSURLConnection delegate functions             //
//////////////////////////////////////////////////////////

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if (connection != _urlConnection)
		return;
	
	[self.data setLength:0];
	
	if ([response respondsToSelector:@selector(allHeaderFields)]) {
		NSString *adType = [[(NSHTTPURLResponse*)response allHeaderFields] valueForKey:@"X-Adtype"];
		WPLogDebug(@"X-Adtype received: %@", adType);
		self.adType = adType;
	}
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (connection != _urlConnection)
		return;

	[self.data appendData:data];
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (connection != _urlConnection)
		return;

	WPLogDebug(
		@"code: %d, domain: %@, localizedDesc: %@", [error code], [error domain], [error localizedDescription]
	);

	if ([error code] == -1001)
		[_delegate bannerInfoLoader:self didFailWithCode:WPBannerInfoLoaderErrorCodeTimeout];
	else
		[_delegate bannerInfoLoader:self didFailWithCode:WPBannerInfoLoaderErrorCodeUnknown];

	[_urlConnection release], _urlConnection = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (connection != _urlConnection)
		return;

	[_delegate bannerInfoLoaderDidFinish:self];

	[_urlConnection release], _urlConnection = nil;
}

@end
