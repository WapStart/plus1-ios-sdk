/**
 * WPAdView.m
 *
 * Copyright (c) 2012, Alexander Zaytsev <a.zaytsev@co.wapstart.ru>
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

#import "WPAdView.h"


@interface WPAdView ()

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)convertFragmentToFullPayload:(NSMutableString *)fragment;

// Delegate callback methods wrapped with -respondsToSelector: checks.
- (void)adDidLoad;
- (void)adDidFailToLoad;

@end

@implementation WPAdView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        _webView = [[UIWebView alloc] initWithFrame:frame];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.clipsToBounds = YES;
        _webView.delegate = self;
        _webView.opaque = NO;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;

		if ([_webView respondsToSelector:@selector(scrollView)]) {
			// Property available in iOS 5.0 and later
			[[_webView scrollView] setScrollEnabled:NO];
		} else {
			for (id subview in _webView.subviews)
				if ([[subview class] isSubclassOfClass:[UIScrollView class]])
					((UIScrollView *)subview).scrollEnabled = NO;
		}

        if ([_webView respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
            [_webView setAllowsInlineMediaPlayback:YES];
        }
        
        if ([_webView respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
            [_webView setMediaPlaybackRequiresUserAction:NO];
        }
        
        [self addSubview:_webView];
	}

    return self;
}

- (void)dealloc {
    _webView.delegate = nil;
    [_webView release];
    [super dealloc];
}

- (void)loadAdWithHTMLString:(NSString *)html baseURL:(NSURL *)url {
	_isLoading = YES;
	[self loadHTMLString:html baseURL:url];
}

#pragma mark - Private

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
	NSRange htmlTagRange = [string rangeOfString:@"<html>"];
    NSRange headTagRange = [string rangeOfString:@"<head>"];
    BOOL isFragment = (htmlTagRange.location == NSNotFound || headTagRange.location == NSNotFound);
    
    NSMutableString *mutableHTML = [string mutableCopy];
    if (isFragment) [self convertFragmentToFullPayload:mutableHTML];
	[_webView loadHTMLString:mutableHTML baseURL:baseURL];
	[mutableHTML release];
}

- (void)convertFragmentToFullPayload:(NSMutableString *)fragment {
    NSString *prepend = @"<html><head>"
    @"<meta name='viewport' content='user-scalable=no; initial-scale=1.0'/>"
    @"</head>"
    @"<body style='margin:0;padding:0;overflow:hidden;background:transparent;'>";
    [fragment insertString:prepend atIndex:0];
    [fragment appendString:@"</body></html>"];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    NSString *scheme = url.scheme;
	bool result = YES;

    if (
		[scheme isEqualToString:@"tel"]
		|| [scheme isEqualToString:@"sms"]
		|| [scheme isEqualToString:@"mailto"]
	) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            result = NO;
        }
    } else if (!_isLoading && navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:url];
        result = NO;
    }

	[self adDidPressed];

    return result;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_isLoading) {
        _isLoading = NO;
        [self adDidLoad];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) return;
    _isLoading = NO;
    [self adDidFailToLoad];
}

#pragma mark - Delegation Wrappers

- (void)adDidLoad {
    if ([self.delegate respondsToSelector:@selector(adDidLoad:)]) {
        [self.delegate adDidLoad:self];
    }
}

- (void)adDidFailToLoad {
    if ([self.delegate respondsToSelector:@selector(adDidFailToLoad:)]) {
        [self.delegate adDidFailToLoad:self];
    }
}

- (void)adDidPressed {
    if ([self.delegate respondsToSelector:@selector(adDidPressed:)]) {
        [self.delegate adDidPressed:self];
    }
}

@end
