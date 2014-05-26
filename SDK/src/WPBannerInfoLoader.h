/**
 * WPBannerInfoLoader.h
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

#import <Foundation/Foundation.h>
#import "WPBannerRequestInfo.h"

@protocol WPBannerInfoLoaderDelegate;

typedef enum
{
	WPBannerInfoLoaderErrorCodeUnknown,
	WPBannerInfoLoaderErrorCodeCancel,
	WPBannerInfoLoaderErrorCodeTimeout,
	WPBannerInfoLoaderErrorCodeNoBanner
} WPBannerInfoLoaderErrorCode;

@interface WPBannerInfoLoader : NSObject 
{
@private
	WPBannerRequestInfo	*_bannerRequestInfo;

	id<WPBannerInfoLoaderDelegate> _delegate;

	NSURLConnection		*_urlConnection;

	NSString			*_userAgent;
	NSString			*_originalUserAgent;
	NSString			*_currentETag;

	NSMutableData		*_data;
	NSString			*_adType;
	CGRect				_containerRect;
	NSDictionary		*_sdkParameters;
	NSDictionary		*_sdkActions;
	NSString			*_uid;
}

@property (nonatomic, retain) WPBannerRequestInfo  *bannerRequestInfo;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSString *adType;
@property (nonatomic, assign) id<WPBannerInfoLoaderDelegate> delegate;
@property (nonatomic, assign) CGRect containerRect;
@property (nonatomic, retain) NSDictionary *sdkParameters;
@property (nonatomic, retain) NSDictionary *sdkActions;
@property (nonatomic, retain) NSString *uid;

- (id) initWithRequestInfo:(WPBannerRequestInfo *) requestInfo;
- (BOOL) start;
- (void) cancel;

@end

@protocol WPBannerInfoLoaderDelegate

- (void) bannerInfoLoaderDidFinish:(WPBannerInfoLoader *) loader;
- (void) bannerInfoLoader:(WPBannerInfoLoader *) loader didFailWithCode:(WPBannerInfoLoaderErrorCode) errorCode;

@end