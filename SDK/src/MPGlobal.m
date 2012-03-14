//
//  MPGlobal.m
//  MoPub
//
//  Created by Andrew He on 5/5/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPGlobal.h"
#import <CommonCrypto/CommonDigest.h>

UIInterfaceOrientation MPInterfaceOrientation()
{
	return [UIApplication sharedApplication].statusBarOrientation;
}

UIWindow *MPKeyWindow()
{
    return [UIApplication sharedApplication].keyWindow;
}

CGFloat MPStatusBarHeight() {
    if ([UIApplication sharedApplication].statusBarHidden) return 0.0;
    
    UIInterfaceOrientation orientation = MPInterfaceOrientation();
    
    return UIInterfaceOrientationIsLandscape(orientation) ?
        CGRectGetWidth([UIApplication sharedApplication].statusBarFrame) :
        CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
}

CGRect MPApplicationFrame()
{
    CGRect frame = MPScreenBounds();
    
    frame.origin.y += MPStatusBarHeight();
    frame.size.height -= MPStatusBarHeight();
    
    return frame;
}

CGRect MPScreenBounds()
{
	CGRect bounds = [UIScreen mainScreen].bounds;
	
	if (UIInterfaceOrientationIsLandscape(MPInterfaceOrientation()))
	{
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	
	return bounds;
}

CGFloat MPDeviceScaleFactor()
{
	if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
		[[UIScreen mainScreen] respondsToSelector:@selector(scale)])
	{
		return [[UIScreen mainScreen] scale];
	}
	else return 1.0;
}

NSString *MPHashedUDID()
{
	static NSString *hashedUDID = nil;
	
	if (!hashedUDID) 
	{
		unsigned char digest[20];
		
		NSString *udid = [NSString stringWithFormat:@"%@", 
						  [[UIDevice currentDevice] uniqueIdentifier]];
		NSData *data = [udid dataUsingEncoding:NSASCIIStringEncoding];
		CC_SHA1([data bytes], [data length], digest);
		
		NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
		
		for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) 
		{
			[output appendFormat:@"%02x", digest[i]];
		}
		
		hashedUDID = [[NSString stringWithFormat:@"sha:%@", [output uppercaseString]] retain];
	}
	return hashedUDID;
}

NSString *MPUserAgentString()
{
	static NSString *userAgent = nil;
	
    if (!userAgent) {
        UIWebView *webview = [[UIWebView alloc] init];
        userAgent = [[webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] copy];  
        [webview release];
    }
    return userAgent;
}

NSDictionary *MPDictionaryFromQueryString(NSString *query) {
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

@implementation NSString (MPAdditions)

- (NSString *)URLEncodedString
{
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																		   (CFStringRef)self,
																		   NULL,
																		   (CFStringRef)@"!*'();:@&=+$,/?%#[]<>",
																		   kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
