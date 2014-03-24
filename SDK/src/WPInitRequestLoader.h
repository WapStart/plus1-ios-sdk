/**
 * WPInitRequestLoader.h
 *
 * Copyright (c) 2014, Alexander Zaytsev <a.zaytsev@co.wapstart.ru>
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

@protocol WPInitRequestLoaderDelegate;

typedef enum
{
	WPInitRequestLoaderErrorCodeUnknown,
	WPInitRequestLoaderErrorCodeCancel,
	WPInitRequestLoaderErrorCodeTimeout
} WPInitRequestLoaderErrorCode;

@interface WPInitRequestLoader : NSObject
{
@private
	WPBannerRequestInfo	*_bannerRequestInfo;
	id<WPInitRequestLoaderDelegate> _delegate;

	NSURLConnection		*_urlConnection;

	NSString			*_userAgent;
	NSString			*_originalUserAgent;
	
	CGRect				_containerRect;
	NSDictionary		*_sdkParameters;
}

@property (nonatomic, retain) WPBannerRequestInfo  *bannerRequestInfo;
@property (nonatomic, assign) id<WPInitRequestLoaderDelegate> delegate;
@property (nonatomic, assign) CGRect containerRect;
@property (nonatomic, assign) NSDictionary *sdkParameters;

- (id) initWithRequestInfo:(WPBannerRequestInfo *) requestInfo;
- (BOOL) start;
- (void) cancel;

@end

@protocol WPInitRequestLoaderDelegate

- (void) initRequestLoaderDidFinish:(WPInitRequestLoader *) loader;
- (void) initRequestLoader:(WPInitRequestLoader *) loader didFailWithCode:(WPInitRequestLoaderErrorCode) errorCode;

@end