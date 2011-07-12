/**
 * WPBannerView.h
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

#import <UIKit/UIKit.h>
#import "WPBannerInfoLoader.h"
#import "WPLocationManager.h"

@class WPBannerInfo;
@protocol WPBannerViewDelegate;

@interface WPBannerView : UIView <WPBannerInfoLoaderDelegate, WPLocationManagerDelegate>
{
	WPBannerInfo        *_bannerInfo;
	WPBannerRequestInfo *_bannerRequestInfo;
	WPBannerInfoLoader  *_bannerInfoLoader;
    WPLocationManager   *_locationManager;
	
	CGFloat _autoupdateTimeout;
	NSTimer *_autoupdateTimer;
	
	UIActivityIndicatorView *_loadingInfoIndicator;
	UIProgressView *_imageLoadingProgress;
	UIButton *_closeButton;
	BOOL _showCloseButton;
	
	UIImage *_bannerImage;
	
	id<WPBannerViewDelegate> _delegate;
	
	NSURLConnection *_urlConnection;
	NSMutableData   *_imageData;
	NSUInteger      _imageSize;
	
	BOOL _isMinimized;
	BOOL _reloadAfterOpenning;
	NSString *_minimizedLabel;
	
	NSTimer *_drawImageTimer;
	BOOL _showImageBanner;
	
	BOOL _hideWhenEmpty;
    BOOL _disableAutoDetectLocation;
}

@property (nonatomic, readonly) WPBannerInfo *bannerInfo;
@property (nonatomic, assign) BOOL showCloseButton;
@property (nonatomic, assign) CGFloat autoupdateTimeout;
@property (nonatomic, assign) BOOL isMinimized;
@property (nonatomic, retain) NSString *minimizedLabel;
@property (nonatomic, assign) BOOL hideWhenEmpty;
@property (nonatomic, readonly) BOOL isEmpty;
@property (nonatomic, readonly) CGFloat bannerHeight;
@property (nonatomic, assign) BOOL disableAutoDetectLocation;

@property (nonatomic, assign) id<WPBannerViewDelegate> delegate;

- (id) initWithBannerRequestInfo:(WPBannerRequestInfo *) requestInfo;

- (void) showFromTop:(BOOL) animated;
- (void) showFromBottom:(BOOL) animated;

- (void) hide:(BOOL) animated;

- (void) reloadBanner;

- (void) setIsMinimized:(BOOL)minimize animated:(BOOL) animated;

@end


@protocol WPBannerViewDelegate <NSObject>

- (void) bannerViewPressed:(WPBannerView *) bannerView;

@optional

- (void) bannerViewInfoLoaded:(WPBannerView *) bannerView;

- (void) bannerViewDidHide:(WPBannerView *) bannerView;
- (void) bannerViewMinimizedStateChanged:(WPBannerView *) bannerView;

@end