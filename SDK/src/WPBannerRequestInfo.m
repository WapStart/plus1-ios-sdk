/**
 * WPBannerRequestInfo.m
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

#import "WPBannerRequestInfo.h"
#import "WPUtils.h"

static NSString *wpCurrentPageId = nil;

@implementation WPBannerRequestInfo

@synthesize applicationId = _applicationId;
@synthesize gender = _gender;
@synthesize age = _age;
@synthesize login = _login;
@synthesize location = _location;

- (id) initWithApplicationId:(NSInteger) applicationId
{
	if ((self = [super init]) != nil)
	{
		self.applicationId = applicationId;
		self.gender = WPGenderUnknown;
		self.age = 0;
	}
	return self;
}

- (id) initWithApplicationId:(NSInteger) applicationId gender:(WPGender) gender
{
	if ((self = [super init]) != nil)
	{
		self.applicationId = applicationId;
		self.gender = gender;
        self.age = 0;
	}
	return self;
}

- (id) initWithApplicationId:(NSInteger) applicationId age:(NSInteger) age
{
	if ((self = [super init]) != nil)
	{
		self.applicationId = applicationId;
		self.gender = WPGenderUnknown;
		self.age = age;
	}
	return self;
}

- (id) initWithApplicationId:(NSInteger) applicationId gender:(WPGender) gender age:(NSInteger) age
{
	if ((self = [super init]) != nil)
	{
		self.applicationId = applicationId;
		self.gender = gender;
		self.age = age;
    }
	return self;
}

- (NSString *) pageId
{
	if (wpCurrentPageId != nil)
		return wpCurrentPageId;
	
	NSString *tempPageId = 
	[[NSString alloc] initWithFormat:@"%i%i%i%i%i%i%i", 
	 arc4random(), arc4random(), arc4random(), arc4random(), arc4random(), arc4random(), arc4random()];
	
	wpCurrentPageId = [[WPUtils sha1Hash:tempPageId] retain];
	[tempPageId release];
	
	return wpCurrentPageId;
}

@end
