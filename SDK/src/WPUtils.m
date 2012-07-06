/**
 * WPUtils.m
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

#import "WPUtils.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation WPUtils

+ (NSString *) sha1Hash:(NSString *) text
{
	const char *cStr = [text UTF8String];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cStr, strlen(cStr), result);
	
	NSMutableString *hash = [NSMutableString string];
	
	for (int i=0; i<20; i++)
		[hash appendFormat:@"%02X", result[i]];
		
	return hash;
}

+ (UIInterfaceOrientation) getInterfaceOrientation
{
	return [UIApplication sharedApplication].statusBarOrientation;
}

+ (UIWindow*) getKeyWindow
{
    return [UIApplication sharedApplication].keyWindow;
}

+ (CGFloat) getStatusBarHeight
{
    if ([UIApplication sharedApplication].statusBarHidden) return 0.0;
    
    UIInterfaceOrientation orientation = [self getInterfaceOrientation];
    
    return
		UIInterfaceOrientationIsLandscape(orientation)
			? CGRectGetWidth([UIApplication sharedApplication].statusBarFrame)
			: CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
}

+ (CGRect) getApplicationFrame
{
	CGRect frame = [self getScreenBounds];
	CGFloat height = [self getStatusBarHeight];
    
	frame.origin.y += height;
	frame.size.height -= height;

	return frame;
}

+ (CGRect) getScreenBounds
{
	CGRect bounds = [UIScreen mainScreen].bounds;
	
	if (UIInterfaceOrientationIsLandscape([self getInterfaceOrientation]))
	{
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	
	return bounds;
}

+ (NSString*) getUserAgent
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [[[NSString alloc] initWithCString:machine encoding:NSUTF8StringEncoding] autorelease];
	free(machine);
	
	return [NSString stringWithFormat:@"%@ (%@)", platform, [[UIDevice currentDevice] systemVersion]];
}

+ (NSDictionary*) getDictionaryFromQueryString:(NSString*) query
{
	NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
	NSArray *queryElements = [query componentsSeparatedByString:@"&"];
	for (NSString *element in queryElements) {
		NSArray *keyVal = [element componentsSeparatedByString:@"="];
		NSString *key = [keyVal objectAtIndex:0];
		NSString *value = [keyVal lastObject];
		[queryDict setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
					  forKey:key];
	}

	return queryDict;
}

@end
