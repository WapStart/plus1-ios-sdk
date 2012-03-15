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
#import "WPBannerInfo.h"
#import "WPUtils.h"
#include <sys/types.h>
#include <sys/sysctl.h>

//#define WPRotatorUrl @"http://ro.plus1.wapstart.ru/?area=application&version=2"
//#define WPRotatorUrl @"http://ro.trunk.plus1.oemtest.ru/?area=application&version=2"
#define WPRotatorUrl @"http://ro.trunk.plus1.oemtest.ru/testmraid.php?area=application&version=2"
//#define WPRotatorUrl @"http://ro.trunk.plus1.oemtest.ru/testmraid.php?area=application&version=2"
#define WPSessionKey @"WPClientSessionId"


@interface WPBannerInfoLoader (PrivateMethods)

- (void) initializeClientSessionId;
- (NSURL *) requestUrl;
- (NSString *) getUserAgent;

@end


@implementation WPBannerInfoLoader

@synthesize bannerRequestInfo = _bannerRequestInfo;
@synthesize delegate = _delegate;
@synthesize data = _data;
@synthesize adType = _adType;

- (id) init
{
	if ((self = [super init]) != nil)
	{
		_bannerRequestInfo = nil;
		
		[self initializeClientSessionId];
	}
	return self;
}

- (id) initWithRequestInfo:(WPBannerRequestInfo *) requestInfo
{
	if ((self = [super init]) != nil)
	{
		_bannerRequestInfo = [requestInfo retain];

		[self initializeClientSessionId];
	}
	return self;
}

- (void) dealloc
{
	[self cancel];
	
	[_bannerRequestInfo release];
	[_clientSessionId release];
	[_data release];

	[super dealloc];
}

- (void) initializeClientSessionId
{
	if (_clientSessionId != nil)
		return;
	
	_clientSessionId = [[[NSUserDefaults standardUserDefaults] objectForKey:WPSessionKey] retain];
	
	if (_clientSessionId != nil)
		return;

	_clientSessionId = [[WPUtils sha1Hash:[[UIDevice currentDevice] uniqueIdentifier]] retain];
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
  
//  NOTE: disabled while on server side 
//    NSSet *set = [_bannerRequestInfo.typeList retain];
//    for (id item in set)
//        [url appendFormat:@"&types[]=%d", [item intValue]];
    
    if (_bannerRequestInfo.login != nil)
        [url appendFormat:@"&login=%@", _bannerRequestInfo.login];
	
    if (_bannerRequestInfo.location != nil)
        [url appendFormat:@"&location=%.8f;%.8f", 
           _bannerRequestInfo.location.coordinate.latitude,
           _bannerRequestInfo.location.coordinate.longitude
        ];
    
	return [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *) getUserAgent
{
	size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [[[NSString alloc] initWithCString:machine encoding:NSUTF8StringEncoding] autorelease];
    free(machine);

	return [NSString stringWithFormat:@"%@ (%@)", platform, [[UIDevice currentDevice] systemVersion]];
}

- (NSString *) getDeviceIMEI
{
    return [[UIDevice currentDevice] uniqueIdentifier];
}

- (NSString *) getDisplayMetrics 
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	return [NSString stringWithFormat:@"%3.0fx%3.0f", screenRect.size.width, screenRect.size.height];
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

	[theRequest setValue:[self getUserAgent] forHTTPHeaderField:@"User-Agent"];
	[theRequest setValue:@"iOS" forHTTPHeaderField:@"x-application-type"];
	[theRequest setValue:[self getDisplayMetrics] forHTTPHeaderField:@"x-display-metrics"];
	[theRequest setValue:[self getDeviceIMEI] forHTTPHeaderField:@"x-device-imei"];
	// TODO: add container metrics header

	_urlConnection = [[NSURLConnection alloc] initWithRequest:theRequest
													 delegate:self 
											 startImmediately:YES];
	
	if (_urlConnection == nil)
		return NO;

	self.data = [NSMutableData data];

	return YES;
}

- (void) cancel
{
	if (_urlConnection == nil)
		return;
	
	[_urlConnection cancel];
	[_urlConnection release], _urlConnection = nil;
	
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
		NSString *adType = [[response allHeaderFields] valueForKey:@"X-Adtype"];
		NSLog(@"X-Adtype received: %@", adType);
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
