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
#import "WPConst.h"

@interface WPBannerInfoLoader (PrivateMethods)

- (NSURL *) requestUrl;
- (NSString *) getUserAgent;
- (NSString *) getOriginalUserAgent;
- (NSString *) getCurrentETag;

@end


@implementation WPBannerInfoLoader

@synthesize bannerRequestInfo = _bannerRequestInfo;
@synthesize delegate = _delegate;
@synthesize statusCode = _statusCode;
@synthesize data = _data;
@synthesize adType = _adType;
@synthesize containerRect = _containerRect;
@synthesize sdkParameters = _sdkParameters;
@synthesize sdkActions = _sdkActions;
@synthesize uid = _uid;

- (id) init
{
	if ((self = [super init]) != nil)
	{
		_bannerRequestInfo = nil;

		self.data = [NSMutableData data];
	}

	return self;
}

- (id) initWithRequestInfo:(WPBannerRequestInfo *) requestInfo
{
	if ((self = [super init]) != nil)
	{
		_bannerRequestInfo = [requestInfo retain];

		self.data = [NSMutableData data];
	}

	return self;
}

- (void) dealloc
{
	[self cancel];

	[_bannerRequestInfo release];
	[_data release];
	[_adType release];
	[_sdkParameters release];
	[_uid release];

	[super dealloc];
}

- (NSURL *) requestUrl
{
	return [_bannerRequestInfo requestUrlByFormat:@"html"];
}

- (NSString *) getUserAgent
{
	if (_userAgent == nil)
		_userAgent = [WPUtils getUserAgent];

	return _userAgent;
}

- (NSString *) getOriginalUserAgent
{
	if (_originalUserAgent == nil)
		_originalUserAgent = [WPUtils getOriginalUserAgent];

	return _originalUserAgent;
}

- (NSString *) getCurrentETag
{
	if (_currentETag == nil && _bannerRequestInfo.uid != nil)
		_currentETag = _bannerRequestInfo.uid;
	
	return _currentETag;
}

- (BOOL) start
{
	if (_bannerRequestInfo == nil || _urlConnection != nil)
		return NO;

	NSMutableURLRequest *postRequest =
		[NSMutableURLRequest requestWithURL:[self requestUrl]
								cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
							timeoutInterval:60];

	NSMutableString *bodyString =
	[NSMutableString stringWithFormat:@"platform=%@&version=%@&sdkver=%@", @"iOS", [[UIDevice currentDevice] systemVersion], SDK_VERSION];

	// FIXME: change format
	if (_bannerRequestInfo.location != nil) {
        [bodyString appendFormat:@"&location=%.8f;%.8f",
			_bannerRequestInfo.location.coordinate.latitude,
			_bannerRequestInfo.location.coordinate.longitude
		];
	}

	if (!CGRectIsNull(self.containerRect))
		[bodyString appendFormat:@"&container-metrics=%@", [NSString stringWithFormat:@"%dx%d", BANNER_WIDTH, BANNER_HEIGHT]];

	[bodyString appendFormat:@"&display-orientation=%@",
		UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)
			? @"landscape"
			: @"portrait"
	];

	[postRequest setHTTPMethod:@"POST"];

	[postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[postRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];

	// Setting up BC headers
	[postRequest setValue:[self getUserAgent] forHTTPHeaderField:@"User-Agent"];
	if ([self getOriginalUserAgent] != nil)
		[postRequest setValue:[self getOriginalUserAgent] forHTTPHeaderField:@"x-original-user-agent"];
	if ([self getCurrentETag] != nil)
		[postRequest setValue:[self getCurrentETag] forHTTPHeaderField:@"If-None-Match"];

	_urlConnection = [[NSURLConnection alloc] initWithRequest:postRequest
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
	self.sdkParameters = nil;
	self.uid = nil;
	
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
		self.statusCode = [(NSHTTPURLResponse*)response statusCode];
		self.adType = [[(NSHTTPURLResponse*)response allHeaderFields] valueForKey:@"X-Adtype"];

		NSString *parameters = [[(NSHTTPURLResponse*)response allHeaderFields] valueForKey:SDK_PARAMETERS_HEADER];

		if (parameters != nil) {
			NSError *error;

			self.sdkParameters =
				[NSJSONSerialization JSONObjectWithData:[parameters dataUsingEncoding:NSUTF8StringEncoding]
												options:0
												  error:&error];

			if (!self.sdkParameters)
				WPLogError(@"Error parsing JSON: %@", error);
		}

		NSString *actions = [[(NSHTTPURLResponse*)response allHeaderFields] valueForKey:SDK_ACTION_HEADER];

		if (actions != nil) {
			NSError *error;

			self.sdkActions =
				[NSJSONSerialization JSONObjectWithData:[actions dataUsingEncoding:NSUTF8StringEncoding]
												options:0
												  error:&error];

			if (!self.sdkActions)
				WPLogError(@"Error parsing JSON: %@", error);
		}

		NSString *etagValue = [[(NSHTTPURLResponse*)response allHeaderFields] valueForKey:@"ETag"];

		if (etagValue != nil) {
			_currentETag = etagValue;
			WPLogDebug(@"New current ETag value: %@", _currentETag);

			NSRange range = [etagValue rangeOfString:@":"];
			self.uid =
				range.location != NSNotFound
					? [etagValue substringToIndex:range.location]
					: etagValue;
		}
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
		@"code: %ld, domain: %@, localizedDesc: %@", (long)[error code], [error domain], [error localizedDescription]
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
