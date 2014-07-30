/**
 * WPBannerView.m
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

#import "WPBannerView.h"
#import "MRAdView.h"
#import "WPAdView.h"
#import "WPLogging.h"
#import "WPConst.h"
#import "WPUtils.h"
#import "NSString+Base64.h"

@interface WPBannerView (PrivateMethods)

- (void) configureSubviews;

- (UIWebView *) makeAdViewWithFrame:(CGRect)frame;

- (void) startAutoupdateTimer;
- (void) stopAutoupdateTimer;

- (void) setReinitTimeout:(CGFloat)timeout;
- (void) setFacebookInfoUpdateTimeout:(CGFloat)timeout;
- (void) setTwitterInfoUpdateTimeout:(CGFloat)timeout;

- (void) cleanCurrentView;
- (void) updateContentFrame;

- (void) show:(bool) animated;

- (void) updateXPos;

- (void) sendInitRequest;
- (void) updateFacebookUserInfo;
- (void) updateTwitterUserInfo;

- (void) openLink:(NSString*)url;

- (void) updateParameters:(NSDictionary*)sdkParameters;

- (void) checkAndDoActions:(NSDictionary*)sdkActions;

+ (CGRect) aspectFittedRect:(CGSize)imageSize max:(CGRect)maxRect;

@end


@implementation WPBannerView

@synthesize delegate = _delegate;
@synthesize isMinimized = _isMinimized;
@synthesize minimizedLabel = _minimizedLabel;
@synthesize showCloseButton = _showCloseButton;
@synthesize disableAutoDetectLocation = _disableAutoDetectLocation;
@synthesize autoupdateTimeout = _autoupdateTimeout;
@synthesize orientation = _orientation;
@synthesize reinitTimeout = _reinitTimeout;
@synthesize facebookInfoUpdateTimeout = _facebookInfoUpdateTimeout;
@synthesize twitterInfoUpdateTimeout = _twitterInfoUpdateTimeout;
@synthesize openInBrowser = _openInBrowser;

- (id) initWithBannerRequestInfo:(WPBannerRequestInfo *) requestInfo andCallbackUrl:(NSString *) callbackUrl
{
    if ((self = [super initWithFrame:CGRectZero]))
	{
		self.minimizedLabel = DEFAULT_MINIMIZED_LABEL;
		self.isMinimized = NO;
		_showCloseButton = YES;
		_disableAutoDetectLocation = YES;
		_callbackUrl = callbackUrl;

		_bannerRequestInfo = [requestInfo retain];
		_adviewPool = [[NSMutableSet set] retain];
		_backupValueDictionary = [[NSMutableDictionary alloc] init];

		self.backgroundColor = [UIColor clearColor];
		
		_closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[_closeButton setImage:[UIImage imageNamed:@"wp_banner_close.png"] forState:UIControlStateNormal];
		[_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:_closeButton];
		
		_loadingInfoIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_loadingInfoIndicator.hidesWhenStopped = YES;
		[self addSubview:_loadingInfoIndicator];

        _locationManager = [[WPLocationManager alloc] init];
        _locationManager.delegate = self;

		self.frame = CGRectMake(BANNER_X_POS, 0, BANNER_WIDTH, [self bannerHeight]);
		self.hidden = true;

		_bannerRequestInfo.uid = [[NSUserDefaults standardUserDefaults] objectForKey:WPSessionKey];

		[self updateFacebookUserInfo];
		[self updateTwitterUserInfo];
		[self sendInitRequest];

		self.reinitTimeout = DEFAULT_REINIT_TIMEOUT;
		self.facebookInfoUpdateTimeout = DEFAULT_FACEBOOK_INFO_UPDATE_TIMEOUT;
		self.twitterInfoUpdateTimeout = DEFAULT_TWITTER_INFO_UPDATE_TIMEOUT;

		self.openInBrowser = NO;

		if (!_callbackUrl)
			@throw([NSException exceptionWithName:@"WPBannerView" reason:@"You must define callback url" userInfo:nil]);
    }

    return self;
}

- (void) dealloc
{
	[_autoupdateTimer invalidate];
	[_bannerInfoLoader cancel];
	[_initRequestLoader cancel];

    [_locationManager release];
	[_bannerRequestInfo release];
	[_closeButton release];
	self.minimizedLabel = nil;

	[_currentContentView release];

	[_adviewPool release];

	[_backupValueDictionary release];

    [super dealloc];
}

#pragma mark Properties

- (CGFloat) bannerHeight
{
	return
		self.isMinimized
			? MINIMIZED_BANNER_HEIGHT
			: BANNER_HEIGHT;
}

- (BOOL) isEmpty
{
	return _currentContentView == nil;
}

- (void) setShowCloseButton:(BOOL)show
{
	_showCloseButton = show;
	[_closeButton setHidden:!_showCloseButton || self.isMinimized];
}

- (void) setIsMinimized:(BOOL)minimize
{
	[self setIsMinimized:minimize animated:NO];
}

- (void) setIsMinimized:(BOOL)minimize animated:(BOOL) animated
{
	if (_isMinimized == minimize)
		return;

	if ([_delegate respondsToSelector:@selector(bannerViewMinimizedStateWillChange:)])
		[_delegate bannerViewMinimizedStateWillChange:self];

	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.superview cache:YES];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	_isMinimized = minimize;

	CGRect currentFrame = self.frame;

	if (_isMinimized)
	{
		[_bannerInfoLoader cancel];
		[_bannerInfoLoader release], _bannerInfoLoader = nil;

		[self stopAutoupdateTimer];

		if ((self.frame.origin.y+self.frame.size.height) == (self.superview.bounds.origin.y+self.superview.bounds.size.height))
		{
			// Banner from bottom
			currentFrame.origin.y = self.superview.bounds.origin.y+self.superview.bounds.size.height-MINIMIZED_BANNER_HEIGHT;
		}

		currentFrame.size.height = MINIMIZED_BANNER_HEIGHT;

		[self cleanCurrentView];
	} else {
		if ((self.frame.origin.y+self.frame.size.height) == (self.superview.bounds.origin.y+self.superview.bounds.size.height))
		{
			// Banner from bottom
			currentFrame.origin.y = self.superview.bounds.origin.y+self.superview.bounds.size.height-[self bannerHeight];
		}

		currentFrame.size.height = [self bannerHeight];

		if (![self isEmpty]) { // NOTE: current view may be assigned in adDidLoad method
			_currentContentView.frame = currentFrame;
			_currentContentView.hidden = false;
			[self startAutoupdateTimer];
		} else {
			if (animated) {
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(reloadBanner)];
			} else
				[self reloadBanner];
		}
	}

	self.showCloseButton = _showCloseButton;
	self.frame = currentFrame;
	
	[_loadingInfoIndicator stopAnimating];
	if (animated) {
		[UIView commitAnimations];
	}

	if ([_delegate respondsToSelector:@selector(bannerViewMinimizedStateChanged:)])
		[_delegate bannerViewMinimizedStateChanged:self];
}

- (void) startAutoupdateTimer
{
	if (_autoupdateTimeout > 0 && _autoupdateTimer == nil) {
		_autoupdateTimer = [NSTimer timerWithTimeInterval:_autoupdateTimeout target:self selector:@selector(reloadBanner) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:_autoupdateTimer forMode:NSDefaultRunLoopMode];
	}
}

- (void) stopAutoupdateTimer
{
	if (_autoupdateTimer != nil) {
		// Turn off timer
		[_autoupdateTimer invalidate], _autoupdateTimer = nil;
	}
}

- (void) setDisableAutoDetectLocation:(BOOL)disableAutoDetectLocation
{
    _disableAutoDetectLocation = disableAutoDetectLocation;
    
    if (_disableAutoDetectLocation)
        [_locationManager stopUpdatingLocation];
    else
        [_locationManager startUpdatingLocation];
}

- (void) setOrientation:(UIInterfaceOrientation)orientation
{
	[self updateXPos];

	if (_orientation != orientation) {
		_orientation = orientation;

		if ([_currentContentView isKindOfClass:[MRAdView class]])
			[(MRAdView*)_currentContentView rotateToOrientation:orientation];
	}
}

- (void) setReinitTimeout:(CGFloat)timeout
{
	_reinitTimeout = timeout;

	if (_reinitTimer != nil) {
		[_reinitTimer invalidate], _reinitTimer = nil;
	}

	if (_reinitTimeout > 0) {
		_reinitTimer = [NSTimer timerWithTimeInterval:_reinitTimeout target:self selector:@selector(sendInitRequest) userInfo:nil repeats:YES];

		[[NSRunLoop currentRunLoop] addTimer:_reinitTimer forMode:NSDefaultRunLoopMode];
	}
}

- (void) setAutoupdateTimeout:(CGFloat)timeout
{
	_autoupdateTimeout = timeout;

	if (_autoupdateTimer != nil) {
		[self stopAutoupdateTimer];
		[self startAutoupdateTimer];
	}
}

- (void) setFacebookInfoUpdateTimeout:(CGFloat)timeout
{
	_facebookInfoUpdateTimeout = timeout;
	
	if (_facebookInfoUpdateTimer != nil) {
		[_facebookInfoUpdateTimer invalidate], _facebookInfoUpdateTimer = nil;
	}

	if (_facebookInfoUpdateTimeout > 0) {
		_facebookInfoUpdateTimer = [NSTimer timerWithTimeInterval:_facebookInfoUpdateTimeout target:self selector:@selector(updateFacebookUserInfo) userInfo:nil repeats:YES];

		[[NSRunLoop currentRunLoop] addTimer:_facebookInfoUpdateTimer forMode:NSDefaultRunLoopMode];
	}
}

- (void) setTwitterInfoUpdateTimeout:(CGFloat)timeout
{
	_twitterInfoUpdateTimeout = timeout;
	
	if (_twitterInfoUpdateTimer != nil) {
		[_twitterInfoUpdateTimer invalidate], _twitterInfoUpdateTimer = nil;
	}

	if (_twitterInfoUpdateTimeout > 0) {
		_twitterInfoUpdateTimer = [NSTimer timerWithTimeInterval:_twitterInfoUpdateTimeout target:self selector:@selector(updateTwitterUserInfo) userInfo:nil repeats:YES];

		[[NSRunLoop currentRunLoop] addTimer:_twitterInfoUpdateTimer forMode:NSDefaultRunLoopMode];
	}
}

#pragma mark Drawing and Views

- (void) configureSubviews
{
	if (_bannerInfoLoader == nil)
		[_loadingInfoIndicator stopAnimating];
	else if ([self isEmpty])
		[_loadingInfoIndicator startAnimating];
}

- (void) setFrame:(CGRect)newFrame
{
	[super setFrame:newFrame];
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
	[self updateXPos];

	UIImage *bgImage = [UIImage imageNamed:@"wp_banner_background.png"];
	[bgImage drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];

	[[UIColor whiteColor] set];

	[self updateContentFrame];

	if (self.isMinimized) {
		CGRect rect = CGRectMake(10, 2, self.bounds.size.width-20, self.bounds.size.height-4);

		UIFont *font = [UIFont systemFontOfSize:12];

		[self.minimizedLabel drawInRect:rect
							   withFont:font
						  lineBreakMode:UILineBreakModeTailTruncation
							  alignment:UITextAlignmentRight];

		return;
	}
}

- (void) updateXPos
{
	CGRect currentFrame = self.frame;
	currentFrame.origin.x = BANNER_X_POS;
	self.frame = currentFrame;
}

- (void) layoutSubviews
{
	_closeButton.frame = CGRectMake(self.bounds.size.width-24, 2, 22, 22);
	_loadingInfoIndicator.frame = CGRectMake((self.bounds.size.width-30)/2, (self.bounds.size.height-30)/2, 30, 30);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	if (self.isMinimized)
	{
		[self setIsMinimized:NO animated:YES];
		return;
	}
	
	UITouch *touch = [touches anyObject];
	CGPoint tapLocation = [touch locationInView:self];
	
	if (tapLocation.x > (self.bounds.size.width-40) && self.showCloseButton) {
		[self performSelector:@selector(closeButtonPressed)];
		return;
	}
}

- (void) willMoveToWindow:(UIWindow *) newWindow
{
    if (newWindow == nil)
        [self stopAutoupdateTimer];
    else
        [self startAutoupdateTimer];
}

#pragma mark Methods

- (void) showFromTop:(BOOL) animated
{
	_hiddenBannerFrame = CGRectMake(BANNER_X_POS, -[self bannerHeight], BANNER_WIDTH, [self bannerHeight]);
	_visibleBannerFrame = CGRectMake(BANNER_X_POS, 0, BANNER_WIDTH, [self bannerHeight]);

	[self show:animated];
}

- (void) showFromBottom:(BOOL) animated
{
	_hiddenBannerFrame = CGRectMake(BANNER_X_POS, self.superview.bounds.size.height, BANNER_WIDTH, [self bannerHeight]);
	_visibleBannerFrame = CGRectMake(BANNER_X_POS, self.superview.bounds.size.height-[self bannerHeight], BANNER_WIDTH, [self bannerHeight]);

	[self show:animated];
}

- (void) show:(bool) animated
{
	if (![self isHidden])
		return;

	if (animated)
	{
		self.frame = _hiddenBannerFrame;
		self.alpha = 0;

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.superview cache:NO];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}

	self.frame = _visibleBannerFrame;
	self.alpha = 1;
	
	_loadingInfoIndicator.frame = self.frame;

	if (animated)
		[UIView commitAnimations];

	[self setHidden:false];
}

- (void) hide:(BOOL) animated
{
	if ([self isHidden])
		return;

	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.superview cache:NO];
		[UIView setAnimationBeginsFromCurrentState:YES];

		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
	}

	self.frame = _hiddenBannerFrame;
	self.alpha = 0;

	if (animated) {
		[UIView commitAnimations];
	} else {
		[self setHidden:true];

		if ([_delegate respondsToSelector:@selector(bannerViewDidHide:)])
			[_delegate bannerViewDidHide:self];
	}
}

- (void) hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self setHidden:true];

	if ([_delegate respondsToSelector:@selector(bannerViewDidHide:)])
		[_delegate bannerViewDidHide:self];
}

- (void) closeButtonPressed
{
	[self setIsMinimized:YES animated:YES];
}

- (void) cleanCurrentView
{
	if (_currentContentView != nil) {
		[_adviewPool removeObject:_currentContentView];
		[_currentContentView removeFromSuperview];
		[_currentContentView release], _currentContentView = nil;
	}
}

- (void) updateContentFrame
{
	CGRect frame = _currentContentView.frame;
	frame.size.width = self.frame.size.width;
	_currentContentView.frame = frame;
}

- (void) updateParameters:(NSDictionary *)sdkParameters
{
	for (NSString *key in [sdkParameters allKeys]) {
		WPLogDebug(@"Found SDK parameter: %@ = %@", key, [sdkParameters valueForKey:key]);

		if ([key isEqualToString:@"refreshDelay"]) {
			if ([[sdkParameters valueForKey:key] intValue] == -1) {
				if ([_backupValueDictionary valueForKey:key] != nil) {
					self.autoupdateTimeout = [[_backupValueDictionary valueForKey:key] floatValue];
					[_backupValueDictionary removeObjectForKey:key];
				}
			} else {
				if ([_backupValueDictionary valueForKey:key] == nil)
					[_backupValueDictionary setValue:[NSNumber numberWithFloat:self.autoupdateTimeout] forKey:key];
				self.autoupdateTimeout = [[sdkParameters valueForKey:key] floatValue];
			}
		} else if ([key isEqualToString:@"reInitDelay"]) {
			if ([[sdkParameters valueForKey:key] intValue] == -1) {
				if ([_backupValueDictionary valueForKey:key] != nil) {
					self.reinitTimeout = [[_backupValueDictionary valueForKey:key] floatValue];
					[_backupValueDictionary removeObjectForKey:key];
				}
			} else {
				if ([_backupValueDictionary valueForKey:key] == nil)
					[_backupValueDictionary setValue:[NSNumber numberWithFloat:self.reinitTimeout] forKey:key];
				self.reinitTimeout = [[sdkParameters valueForKey:key] floatValue];
			}
		} else if ([key isEqualToString:@"facebookInfoDelay"]) {
			if ([[sdkParameters valueForKey:key] intValue] == -1) {
				if ([_backupValueDictionary valueForKey:key] != nil) {
					self.facebookInfoUpdateTimeout = [[_backupValueDictionary valueForKey:key] floatValue];
					[_backupValueDictionary removeObjectForKey:key];
				}
			} else {
				if ([_backupValueDictionary valueForKey:key] == nil)
					[_backupValueDictionary setValue:[NSNumber numberWithFloat:self.facebookInfoUpdateTimeout] forKey:key];
				self.facebookInfoUpdateTimeout = [[sdkParameters valueForKey:key] floatValue];
			}
		} else if ([key isEqualToString:@"twitterInfoDelay"]) {
			if ([[sdkParameters valueForKey:key] intValue] == -1) {
				if ([_backupValueDictionary valueForKey:key] != nil) {
					self.twitterInfoUpdateTimeout = [[_backupValueDictionary valueForKey:key] floatValue];
					[_backupValueDictionary removeObjectForKey:key];
				}
			} else {
				if ([_backupValueDictionary valueForKey:key] == nil)
					[_backupValueDictionary setValue:[NSNumber numberWithFloat:self.twitterInfoUpdateTimeout] forKey:key];
				self.twitterInfoUpdateTimeout = [[sdkParameters valueForKey:key] floatValue];
			}
		} else if ([key isEqualToString:@"openIn"]) {
			if ([[sdkParameters valueForKey:key] intValue] == -1) {
				if ([_backupValueDictionary valueForKey:key] != nil) {
					self.openInBrowser = [[_backupValueDictionary valueForKey:key] boolValue];
					[_backupValueDictionary removeObjectForKey:key];
				}
			} else {
				if ([_backupValueDictionary valueForKey:key] == nil)
					[_backupValueDictionary setValue:[NSNumber numberWithBool:self.openInBrowser] forKey:key];
				self.openInBrowser = [[sdkParameters valueForKey:key] isEqualToString:@"browser"];
			}
		}

		// FIXME: implement logic for refreshRetryNum
	}
}

- (void) checkAndDoActions:(NSDictionary*)sdkActions
{
	// FIXME: dirty code, add data checks
	for (NSString *key in [sdkActions allKeys]) {
		WPLogDebug(@"Found SDK action: %@ = %@", key, [sdkActions valueForKey:key]);

		if ([key isEqualToString:@"openLink"]) {
			[self openLink:[sdkActions valueForKey:key]];
		}
	}
}

- (void) openLink:(NSString*)url
{
	WPLogDebug(@"Open link url template: %@", url);
	url = [url stringByReplacingOccurrencesOfString:@"%reinitDelay%" withString:[[NSNumber numberWithFloat:self.reinitTimeout] stringValue]];
	url = [url stringByReplacingOccurrencesOfString:@"%bannerRefreshInterval%" withString:[[NSNumber numberWithFloat:self.autoupdateTimeout] stringValue]];
	url = [url stringByReplacingOccurrencesOfString:@"%facebookInfoRefreshInterval%" withString:[[NSNumber numberWithFloat:self.facebookInfoUpdateTimeout] stringValue]];
	url = [url stringByReplacingOccurrencesOfString:@"%twitterInfoRefreshInterval%" withString:[[NSNumber numberWithFloat:self.twitterInfoUpdateTimeout] stringValue]];
	url = [url stringByReplacingOccurrencesOfString:@"%uid%" withString:(_bannerInfoLoader.uid ?: @"unknown")];
	url = [url stringByReplacingOccurrencesOfString:@"%encodedCallback%" withString:[NSString stringWithBase64EncodedString:_callbackUrl]];
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	WPLogDebug(@"Open link after replacements: %@", url);

	NSURL *linkUrl = [NSURL URLWithString:url];

	if ([[UIApplication sharedApplication] canOpenURL:linkUrl]) {
		[[UIApplication sharedApplication] openURL:linkUrl];
	} else
		WPLogWarn(@"Can not open url: %@", url);
}

#pragma mark Network

- (void) reloadBanner
{
	if (self.isMinimized || _isExpanded || _bannerRequestInfo.uid == nil)
		return;

	[_bannerInfoLoader cancel];
	[_bannerInfoLoader release];

	_bannerInfoLoader = [[WPBannerInfoLoader alloc] initWithRequestInfo:_bannerRequestInfo];
	_bannerInfoLoader.containerRect = self.frame;
	_bannerInfoLoader.delegate = self;

	if (![_bannerInfoLoader start]) {
		[_bannerInfoLoader release], _bannerInfoLoader = nil;
	}

	[self configureSubviews];
	[self setNeedsDisplay];

	[self startAutoupdateTimer];
}

- (void) sendInitRequest
{
	[_initRequestLoader cancel];
	[_initRequestLoader release];

	_initRequestLoader = [[WPInitRequestLoader alloc] initWithRequestInfo:_bannerRequestInfo];
	_initRequestLoader.delegate = self;

	if (![_initRequestLoader start]) {
		[_initRequestLoader release], _initRequestLoader = nil;
	}
}

- (void) updateFacebookUserInfo
{
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
		ACAccountStore *accountStore = [[ACAccountStore alloc] init];
		ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
		NSArray *facebookAccounts = [accountStore accountsWithAccountType:accountType];

		WPLogDebug(@"Total facebook accounts available: %d", facebookAccounts.count);

		if (facebookAccounts.count > 0) {
			ACAccount *account = [facebookAccounts lastObject];

			_bannerRequestInfo.facebookUserHash = [WPUtils sha1Hash:[[[account valueForKey:@"properties"] valueForKey:@"uid"] stringValue]];
			WPLogDebug(@"Retrieve facebook user id by Accounts.framework: %@", _bannerRequestInfo.facebookUserHash);
		}

		[accountStore release];
	} else {
		WPLogDebug(@"Facebook accounts.framework info is not available on iOS %@", [[UIDevice currentDevice] systemVersion]);
	}

	if (
		[[[UIDevice currentDevice] systemVersion] floatValue] < 6.0
		|| _bannerRequestInfo.facebookUserHash == nil
	) {
		Class requestCls = NSClassFromString(@"FBRequest");

		if (requestCls) {
			[[requestCls performSelector:@selector(requestForMe)] performSelector:@selector(startWithCompletionHandler) withObject:
				^(id *connection, NSDictionary<NSObject> *aUser, NSError *error) {
					if (!error) {
						dispatch_sync(dispatch_get_main_queue(), ^{
							_bannerRequestInfo.facebookUserHash = [WPUtils sha1Hash:[aUser objectForKey:@"id"]];

							WPLogDebug(@"Retrieve facebook user id by Facebook sdk: %@", _bannerRequestInfo.facebookUserHash);
						});
					} else {
						WPLogDebug(@"User is not logged in with Facebook sdk");
					}
				}
			];
		} else {
			WPLogDebug(@"Application is not using Facebook sdk");
		}
	}
}

- (void) updateTwitterUserInfo
{
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
		ACAccountStore *accountStore = [[ACAccountStore alloc] init];
		ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

		NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];

		WPLogDebug(@"Total twitter accounts available: %d", twitterAccounts.count);

		ACAccount *account = nil;

		if (twitterAccounts.count > 0) {
			account = [twitterAccounts lastObject];

			_bannerRequestInfo.twitterUserHash = [WPUtils sha1Hash:[[account valueForKey:@"properties"] valueForKey:@"user_id"]];

			WPLogDebug(@"Retrieve twitter user id by Accounts.framework: %@", _bannerRequestInfo.twitterUserHash);
		}

		[accountStore release];
	} else {
		WPLogDebug(@"Twitter accounts.framework info is not available on iOS %@", [[UIDevice currentDevice] systemVersion]);
	}
}

#pragma mark Network delegates

- (void) bannerInfoLoaderDidFinish:(WPBannerInfoLoader *) loader
{
	if (loader.sdkParameters)
		[self updateParameters:loader.sdkParameters];

	if (loader.uid) {
		_bannerRequestInfo.uid = loader.uid;
		[[NSUserDefaults standardUserDefaults] setObject:_bannerRequestInfo.uid forKey:WPSessionKey];
	}

	if (loader.sdkActions)
		[self checkAndDoActions:loader.sdkActions];

	NSString *html = [[[[NSString alloc] initWithData:loader.data encoding:NSUTF8StringEncoding] autorelease] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (
		STATUS_CODE_NO_BANNER == loader.statusCode
		|| (
			loader.adType != nil // FIXME: must exists in API 3
			&& ![@"mraid" isEqualToString:loader.adType]
			&& ![@"plus1" isEqualToString:loader.adType]
		)
	) {
		WPLogDebug(@"No content to display");

		[_bannerInfoLoader release], _bannerInfoLoader = nil;

		if ([_delegate respondsToSelector:@selector(bannerViewInfoDidFailWithError:)])
			[_delegate bannerViewInfoDidFailWithError:WPBannerInfoLoaderErrorCodeNoBanner];

		[self hide:YES];
		return;
	}

	WPLogDebug(@"Creating adView for type: %@, html: %@", loader.adType, html);

	CGRect viewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

	if ([@"mraid" isEqualToString:loader.adType]) {
		MRAdView *mraidView = [[MRAdView alloc] initWithFrame:viewFrame];
		mraidView.delegate = self;
		[mraidView loadCreativeWithHTMLString:html baseURL:nil];
		[_adviewPool addObject:mraidView];
	} else {
		WPAdView *adView = [[WPAdView alloc] initWithFrame:viewFrame];
		adView.delegate = self;
		adView.openInBrowser = self.openInBrowser;
		[adView loadAdWithHTMLString:html baseURL:nil];
		[_adviewPool addObject:adView];
	}

	[_bannerInfoLoader release], _bannerInfoLoader = nil;
}

- (void) bannerInfoLoader:(WPBannerInfoLoader *) loader didFailWithCode:(WPBannerInfoLoaderErrorCode) errorCode
{
	[_bannerInfoLoader release], _bannerInfoLoader = nil;
	[self configureSubviews];
	[self setNeedsDisplay];

	if (
		errorCode != WPBannerInfoLoaderErrorCodeCancel
		&& [_delegate respondsToSelector:@selector(bannerViewInfoDidFailWithError:)]
	) {
		[_delegate bannerViewInfoDidFailWithError:errorCode];
	}
}

- (void) initRequestLoaderDidFinish:(WPInitRequestLoader *) loader
{
	if (loader.sdkParameters)
		[self updateParameters:loader.sdkParameters];

	if (loader.uid) {
		_bannerRequestInfo.uid = loader.uid;
		[[NSUserDefaults standardUserDefaults] setObject:_bannerRequestInfo.uid forKey:WPSessionKey];
	}

	if (loader.sdkActions)
		[self checkAndDoActions:loader.sdkActions];
		
	[_initRequestLoader release], _initRequestLoader = nil;
}

- (void) initRequestLoader:(WPInitRequestLoader *) loader didFailWithCode:(WPInitRequestLoaderErrorCode) errorCode
{
	[_initRequestLoader release], _initRequestLoader = nil;

	if (errorCode != WPInitRequestLoaderErrorCodeCancel)
		WPLogWarn(@"Init request loader failed with code: %d", errorCode);
}

#pragma mark Location manager delegates

- (void) locationUpdate:(CLLocation *)location
{
    _bannerRequestInfo.location = location;
}

- (void) locationError:(NSError *)error { /*_*/ }

#pragma mark MRAdViewDelegate

- (void) willExpandAd:(MRAdView *)adView toFrame:(CGRect)frame
{
	WPLogDebug(@"MRAID: Will expanded!");
	
	_isExpanded = true;

	[_bannerInfoLoader cancel];
	[self stopAutoupdateTimer];

	if ([_delegate respondsToSelector:@selector(bannerViewPressed:)])
		[_delegate bannerViewPressed:self];
}

- (void)didExpandAd:(MRAdView *)adView toFrame:(CGRect)frame
{
	WPLogDebug(@"MRAID: Did expanded!");

	// FIXME: choose better method name to notify about click tracking
	if ([_delegate respondsToSelector:@selector(bannerViewPressed:)])
		[_delegate bannerViewPressed:self];
}

- (void)adDidClose:(MRAdView *)adView
{
	WPLogDebug(@"MRAID: Did closed!");

	[self updateContentFrame];

	_isExpanded = false;
	[adView removeFromSuperview];
	[self insertSubview:adView atIndex:0];
	[self startAutoupdateTimer];
}

- (void)appShouldSuspendForAd:(MRAdView *)adView
{
	[_bannerInfoLoader cancel];
	[self stopAutoupdateTimer];
}

- (void)appShouldResumeForAd:(MRAdView *)adView
{
	[self updateContentFrame];

	[self startAutoupdateTimer];
}

#pragma mark WPAdViewDelegate

- (void)adDidPressed:(WPAdView *)adView
{
	if ([_delegate respondsToSelector:@selector(bannerViewPressed:)])
		[_delegate bannerViewPressed:self];
}

#pragma mark MRAdViewDelegate / WPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	return (UIViewController*)self.delegate;
}

- (void)adDidLoad:(UIView *)adView;
{
	if (self.isMinimized || _isExpanded)
		return;

	[self cleanCurrentView];
	_currentContentView = adView;

	[self insertSubview:_currentContentView atIndex:0];

	[self configureSubviews];
	[self setNeedsDisplay];

	if ([_delegate respondsToSelector:@selector(bannerViewInfoLoaded:)])
		[_delegate bannerViewInfoLoaded:self];
}

- (void)adDidFailToLoad:(UIView *)adView
{
	if ([_delegate respondsToSelector:@selector(bannerViewInfoDidFailWithError:)])
		[_delegate bannerViewInfoDidFailWithError:WPBannerInfoLoaderErrorCodeUnknown];
}

@end
