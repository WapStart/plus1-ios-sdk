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
#import "WPBannerInfo.h"

#define BANNER_HEIGHT 60
#define MINIMIZED_BANNER_HEIGHT 20
#define SHOW_IMAGE_TIMEOUT 3
#define DEFAULT_MINIMIZED_LABEL @"Открыть баннер"

@interface WPBannerView (PrivateMethods)

- (void) configureSubviews;

- (void) loadImage;
- (void) cancelLoadImage;

+ (CGRect) aspectFittedRect:(CGSize)imageSize max:(CGRect)maxRect;

@end


@implementation WPBannerView

@synthesize delegate = _delegate;
@synthesize bannerInfo = _bannerInfo;
@synthesize isMinimized = _isMinimized;
@synthesize minimizedLabel = _minimizedLabel;
@synthesize showCloseButton = _showCloseButton;
@synthesize hideWhenEmpty = _hideWhenEmpty;
@synthesize disableAutoDetectLocation = _disableAutoDetectLocation;

- (id) initWithBannerRequestInfo:(WPBannerRequestInfo *) requestInfo
{
    if ((self = [super initWithFrame:CGRectZero]))
	{
		self.minimizedLabel = DEFAULT_MINIMIZED_LABEL;
		self.isMinimized = NO;
		_bannerInfo = nil;
		_showCloseButton = YES;
		_hideWhenEmpty = NO;
		_reloadAfterOpenning = NO;
		_disableAutoDetectLocation = YES;

		_bannerRequestInfo = [requestInfo retain];
        
		self.backgroundColor = [UIColor clearColor];
		
		_closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[_closeButton setImage:[UIImage imageNamed:@"wp_banner_close.png"] forState:UIControlStateNormal];
		[_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:_closeButton];
		
		_loadingInfoIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_loadingInfoIndicator.hidesWhenStopped = YES;
		[self addSubview:_loadingInfoIndicator];
		
		_imageLoadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		[self addSubview:_imageLoadingProgress];

		[self configureSubviews];
		
		self.hideWhenEmpty = YES;
        
        _locationManager = [[WPLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return self;
}

- (void) dealloc
{
	[_drawImageTimer invalidate];
	[_autoupdateTimer invalidate];
	[_bannerInfoLoader cancel];
	[self cancelLoadImage];
	
    [_locationManager release];
	[_bannerRequestInfo release];
	[_bannerImage release];
	[_bannerInfo release];
	[_closeButton release];
	[_imageLoadingProgress release];
	self.minimizedLabel = nil;
	
    [super dealloc];
}

#pragma mark Properties

- (CGFloat) bannerHeight
{
	return self.isMinimized ? MINIMIZED_BANNER_HEIGHT : BANNER_HEIGHT;
}

- (BOOL) isEmpty
{
	return (_bannerInfo == nil);
}

- (void) setShowCloseButton:(BOOL)show
{
	_showCloseButton = show;
	[_closeButton setHidden:!_showCloseButton || self.isMinimized];
}

- (void) setHideWhenEmpty:(BOOL)hide
{
	_hideWhenEmpty = hide;
	[self setHidden:_hideWhenEmpty && self.isEmpty];
}

- (void) setIsMinimized:(BOOL)minimize
{
	[self setIsMinimized:minimize animated:NO];
}

- (void) setIsMinimized:(BOOL)minimize animated:(BOOL) animated
{
	if (_isMinimized == minimize)
		return;
	
	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.superview cache:YES];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	_isMinimized = minimize;
	
	CGRect currentFrame = self.frame;
	if (_isMinimized)
	{
		if ((self.frame.origin.y+self.frame.size.height) == (self.superview.bounds.origin.y+self.superview.bounds.size.height))
		{
			// Banner from bottom
			currentFrame.origin.y = self.superview.bounds.origin.y+self.superview.bounds.size.height-MINIMIZED_BANNER_HEIGHT;
			currentFrame.size.height = MINIMIZED_BANNER_HEIGHT;
		}else
		{
			currentFrame.size.height = MINIMIZED_BANNER_HEIGHT;
		}
	}else {
		if ((self.frame.origin.y+self.frame.size.height) == (self.superview.bounds.origin.y+self.superview.bounds.size.height))
		{
			// Banner from bottom
			currentFrame.origin.y = self.superview.bounds.origin.y+self.superview.bounds.size.height-BANNER_HEIGHT;
			currentFrame.size.height = BANNER_HEIGHT;
		}else
		{
			currentFrame.size.height = BANNER_HEIGHT;
		}
	}

	self.showCloseButton = _showCloseButton;
	self.frame = currentFrame;
	
	if (animated)
		[UIView commitAnimations];
	
	if ([_delegate respondsToSelector:@selector(bannerViewMinimizedStateChanged:)])
		[_delegate bannerViewMinimizedStateChanged:self];
	
	if (!_isMinimized && _reloadAfterOpenning)
		[self reloadBanner];
	
	_reloadAfterOpenning = NO;
}

- (CGFloat) autoupdateTimeout
{
	return _autoupdateTimeout;
}

- (void) setAutoupdateTimeout:(CGFloat)newTimeout
{
	_autoupdateTimeout = newTimeout;
	
	if (_autoupdateTimeout == 0)
	{
		// Turn off timer
		[_autoupdateTimer invalidate], _autoupdateTimer = nil;
	}else
	{
		_autoupdateTimer = [NSTimer timerWithTimeInterval:_autoupdateTimeout target:self selector:@selector(reloadBanner) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:_autoupdateTimer forMode:NSDefaultRunLoopMode];
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

#pragma mark Drawing and Views

- (void) configureSubviews
{
	if (_bannerInfoLoader == nil)
	{
		if (_urlConnection == nil)
			[_imageLoadingProgress setHidden:YES];
		else
			[_imageLoadingProgress setHidden:NO];
		
		[_loadingInfoIndicator stopAnimating];
	}else {
		[_imageLoadingProgress setHidden:YES];
		if (_bannerInfo == nil)
			[_loadingInfoIndicator startAnimating];
	}
}

- (void) setFrame:(CGRect)newFrame
{
	[super setFrame:newFrame];
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
	UIImage *bgImage = [UIImage imageNamed:@"wp_banner_background.png"];
	[bgImage drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];

	[[UIColor whiteColor] set];
	
	if (self.isMinimized)
	{
		CGRect rect = CGRectMake(10, 2, self.bounds.size.width-20, self.bounds.size.height-4);

		UIFont *font = [UIFont systemFontOfSize:12];

		[self.minimizedLabel drawInRect:rect
							   withFont:font
						  lineBreakMode:UILineBreakModeTailTruncation
							  alignment:UITextAlignmentRight];
	
		return;
	}
	
	
	UIImage *shildImage = [UIImage imageNamed:@"wp_banner_shild.png"];
	[shildImage drawInRect:CGRectMake(0, 0, 9, self.bounds.size.height)];
	
	if (_bannerInfoLoader != nil)
		return;
	
	CGRect maxRect = CGRectMake(9, 0, self.bounds.size.width-([_closeButton isHidden] ? 9 : 31), self.bounds.size.height);

	if (_showImageBanner && _bannerImage != nil)
	{
		[_bannerImage drawInRect:[WPBannerView aspectFittedRect:_bannerImage.size max:maxRect]];
	}else
	{
		// Draw title
		if (_bannerInfo.title != nil)
		{
			UIFont *font = [UIFont systemFontOfSize:12];
			CGRect rect = CGRectMake(30, 2, self.bounds.size.width-50, 14);
			[_bannerInfo.title drawInRect:rect
								 withFont:font
							lineBreakMode:UILineBreakModeTailTruncation
								alignment:UITextAlignmentLeft];
			
		}
		// Draw content
		if (_bannerInfo.content != nil)
		{
			UIFont *font = [UIFont boldSystemFontOfSize:12];
			CGRect rect = CGRectMake(30, 16, self.bounds.size.width-50, 14);
			[_bannerInfo.content drawInRect:rect
								   withFont:font
							  lineBreakMode:UILineBreakModeTailTruncation
								  alignment:UITextAlignmentLeft];
			
		}
	}
}

- (void) layoutSubviews
{
	_closeButton.frame = CGRectMake(self.bounds.size.width-24, 2, 22, 22);
	_imageLoadingProgress.frame = CGRectMake(30, self.bounds.size.height-20, self.bounds.size.width-50, 10);
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
	
	if (tapLocation.x > (self.bounds.size.width-40))
	{
		[self performSelector:@selector(closeButtonPressed)];
		return;
	}
	
	[_delegate bannerViewPressed:self];
}

#pragma mark Methods

- (void) showFromTop:(BOOL) animated
{
	if (animated)
	{
		self.frame = CGRectMake(0, -[self bannerHeight], self.superview.bounds.size.width, [self bannerHeight]);
		self.alpha = 0;

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.superview cache:NO];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	self.frame = CGRectMake(0, 0, self.superview.bounds.size.width, [self bannerHeight]);
	self.alpha = 1;

	if (animated)
		[UIView commitAnimations];
}

- (void) showFromBottom:(BOOL) animated
{
	if (animated)
	{
		self.frame = CGRectMake(0, self.superview.bounds.size.height, self.superview.bounds.size.width, [self bannerHeight]);
		self.alpha = 0;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.superview cache:NO];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	self.frame = CGRectMake(0, self.superview.bounds.size.height-[self bannerHeight], self.superview.bounds.size.width, [self bannerHeight]);
	self.alpha = 1;
	
	if (animated)
		[UIView commitAnimations];
}

- (void) hide:(BOOL) animated
{
	if (((self.frame.origin.y+self.frame.size.height) == (self.superview.bounds.origin.y+self.superview.bounds.size.height)) ||
		(self.frame.origin.y == self.superview.bounds.origin.y))
	{
		if (animated)
		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.superview cache:NO];
			[UIView setAnimationBeginsFromCurrentState:YES];
			if ([_delegate respondsToSelector:@selector(bannerViewDidHide:)])
			{
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
			}
		}
		
		if ((self.frame.origin.y+self.frame.size.height) == (self.superview.bounds.origin.y+self.superview.bounds.size.height))
			self.frame = CGRectMake(0, self.superview.bounds.size.height, self.superview.bounds.size.width, [self bannerHeight]);
		else
			self.frame = CGRectMake(0, -[self bannerHeight], self.superview.bounds.size.width, [self bannerHeight]);
		self.alpha = 0;
		
		if (animated)
			[UIView commitAnimations];
		else
		{
			if ([_delegate respondsToSelector:@selector(bannerViewDidHide:)])
				[_delegate bannerViewDidHide:self];
		}
	}
}

- (void) hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[_delegate bannerViewDidHide:self];
}

- (void) closeButtonPressed
{
	[self setIsMinimized:YES animated:YES];
}

- (void) changeImageState
{
	if (self.isMinimized)
		return;
	
	_showImageBanner = !_showImageBanner;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:_showImageBanner ? UIViewAnimationTransitionCurlUp : UIViewAnimationTransitionCurlDown forView:self cache:YES];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	[self setNeedsDisplay];
	
	[UIView commitAnimations];
}

#pragma mark Network

- (void) reloadBanner
{
	if (self.isMinimized)
	{
		if (!self.isEmpty || !_hideWhenEmpty)
		{
			_reloadAfterOpenning = YES;
			return;
		}
	}
	
	[self cancelLoadImage];
	[_bannerInfoLoader cancel];
	
	_bannerInfoLoader = [[WPBannerInfoLoader alloc] initWithRequestInfo:_bannerRequestInfo];
	_bannerInfoLoader.delegate = self;
	
	if (![_bannerInfoLoader start])
	{
		[_bannerInfoLoader release], _bannerInfoLoader = nil;
	}
	
	[self configureSubviews];
	[self setNeedsDisplay];
}

- (void) loadImage
{
	[self cancelLoadImage];
	
	NSString *imageURL = nil;
	if (_bannerInfo.pictureUrl != nil)
		imageURL = _bannerInfo.pictureUrl;
	else
		imageURL = _bannerInfo.pictureUrlPng;
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                            timeoutInterval:60];
	
    _imageData = [[NSMutableData alloc] init];
	
    _urlConnection = [[NSURLConnection alloc] initWithRequest:theRequest
                                                     delegate:self 
                                             startImmediately:YES];
}

- (void) cancelLoadImage
{
	if (_urlConnection == nil)
		return;
	
	[_urlConnection cancel];
	[_imageData release];
}

#pragma mark Network delegates

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if (connection != _urlConnection)
		return;
	
	_imageSize = response.expectedContentLength;
	_imageLoadingProgress.progress = 0.0;
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (connection != _urlConnection)
		return;
	
	[_imageData appendData:data];
	
	if (_imageSize != 0)
		_imageLoadingProgress.progress = 1.0*[_imageData length]/_imageSize;
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (connection != _urlConnection)
		return;

	[_imageLoadingProgress removeFromSuperview];
	[_imageLoadingProgress release], _imageLoadingProgress = nil;
	
	[_imageData release], _imageData = nil;
	[_urlConnection release], _urlConnection = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (connection != _urlConnection)
		return;

	[_imageLoadingProgress removeFromSuperview];
	[_imageLoadingProgress release], _imageLoadingProgress = nil;
	[_bannerImage release];
    _bannerImage = [[UIImage alloc] initWithData:_imageData];
	_showImageBanner = (_bannerInfo.title == nil);
	[self setNeedsDisplay];
	
	[_drawImageTimer invalidate], _drawImageTimer = nil;
	if (_bannerInfo.title != nil)
	{
		_drawImageTimer = [NSTimer timerWithTimeInterval:SHOW_IMAGE_TIMEOUT target:self selector:@selector(changeImageState) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:_drawImageTimer forMode:NSDefaultRunLoopMode];
	}
	
	[_imageData release], _imageData = nil;
	[_urlConnection release], _urlConnection = nil;
}

- (void) bannerInfoLoaderDidFinish:(WPBannerInfoLoader *) loader
{
	if (loader.bannerInfo != nil && loader.bannerInfo.bannerId != 0)
	{
		// Banner info loaded
		[_drawImageTimer invalidate], _drawImageTimer = nil;
		[_bannerImage release], _bannerImage = nil;
		[_bannerInfo release];
		_bannerInfo = [loader.bannerInfo retain];
		_showImageBanner = (_bannerInfo.title == nil);

		[self setHideWhenEmpty:_hideWhenEmpty];

		if (_bannerInfo.pictureUrl != nil || _bannerInfo.pictureUrlPng != nil)
			[self loadImage];
	}
	
	[_bannerInfoLoader release], _bannerInfoLoader = nil;
	[self configureSubviews];
	[self setNeedsDisplay];
	
	if ([_delegate respondsToSelector:@selector(bannerViewInfoLoaded:)])
		[_delegate bannerViewInfoLoaded:self];
}

- (void) bannerInfoLoader:(WPBannerInfoLoader *) loader didFailWithCode:(WPBannerInfoLoaderErrorCode) errorCode
{
	[_bannerInfoLoader release], _bannerInfoLoader = nil;
	[self configureSubviews];
	[self setNeedsDisplay];
}

#pragma mark Location manager delegates 
- (void) locationUpdate:(CLLocation *)location
{
    _bannerRequestInfo.location = location;
}

- (void) locationError:(NSError *)error { /*_*/ }

#pragma mark Utils

+ (CGRect) aspectFittedRect:(CGSize)imageSize max:(CGRect)maxRect
{
	float originalAspectRatio = imageSize.width / imageSize.height;
	float maxAspectRatio = maxRect.size.width / maxRect.size.height;
	
	CGRect newRect = maxRect;
	if (originalAspectRatio > maxAspectRatio) { // scale by width
		newRect.size.height = imageSize.height * newRect.size.width / imageSize.width;
		newRect.origin.y += (maxRect.size.height - newRect.size.height)/2.0;
	} else {
		newRect.size.width = imageSize.width  * newRect.size.height / imageSize.height;
		newRect.origin.x += (maxRect.size.width - newRect.size.width)/2.0;
	}
	
	return CGRectIntegral(newRect);
}


@end
