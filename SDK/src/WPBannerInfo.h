/**
 * WPBannerInfo.h
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

typedef enum
{
	WPBannerResponseUnknow  = 0,
	WPBannerResponseWebSite = 1,
	WPBannerResponsePhone   = 2,
	WPBannerResponseApplication = 3,
	WPBannerResponseMedia = 4
} WPBannerResponseType;

@interface WPBannerInfo : NSObject
{
	NSInteger _bannerId;
	
	NSString *_title;
	NSString *_content;
	
	WPBannerResponseType _responseType;
	
	NSString *_link;
	NSString *_pictureUrl;
	NSString *_pictureUrlPng;
}

@property (nonatomic, assign) NSInteger bannerId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, assign) WPBannerResponseType responseType;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *pictureUrl;
@property (nonatomic, retain) NSString *pictureUrlPng;

@end
