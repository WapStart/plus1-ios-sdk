/**
 * WPBannerInfoParser.m
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

#import "WPBannerInfoParser.h"
#import "WPBannerInfo.h"
#import <libxml/tree.h>

// Function prototypes for SAX callbacks. This sample implements a minimal subset of SAX callbacks.
// Depending on your application's needs, you might want to implement more callbacks.
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

// Forward reference. The structure is defined in full at the end of the file.
static xmlSAXHandler simpleSAXHandlerStruct;

@protocol WPBannerInfoParserProtocol <NSObject>

- (void) openXMLTagFound:(NSString *) name attributes:(NSArray *) attributes prevTags:(NSArray *) prevTags;
- (void) closeXMLTagFound:(NSString *) name prevTags:(NSArray *) prevTags;
- (void) textFound:(NSString *) text prevTags:(NSArray *) prevTags;
- (void) errorFoundWithPrevTags:(NSArray *) prevTags;
- (void) parsingFinished;

@end

@interface WPBannerInfoParser (PrivateMethods)

- (void) startElementSAX:(NSString *) name attributes:(NSArray *) attributes;
- (void) endElementSAX:(NSString *) name;
- (void) charactersFoundSAX:(NSString *) str;
- (void) errorFoundSAX;

@end

@implementation WPBannerInfoParser

- (id) init
{
	if (self = [super init])
	{
		_isSuccess   = YES;
		_isFinished  = NO;
		_bannerInfo  = [[WPBannerInfo alloc] init];
		_context     = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
		_itemsStack  = [[NSMutableArray alloc] init];
		_textsStack  = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	xmlFreeParserCtxt((xmlParserCtxtPtr)_context);
	[_itemsStack release];
	[_textsStack release];
	[super dealloc];
}

- (BOOL) isSuccess
{
	return _isSuccess && _isFinished;
}

- (WPBannerInfo *) bannerInfo
{
	if (self.isSuccess)
		return _bannerInfo;
	
	return nil;
}

- (void) parseData:(NSData *) data
{
	xmlParseChunk((xmlParserCtxtPtr)_context, (const char *)[data bytes], [data length], 0);
}

- (void) finishParsing
{
	xmlParseChunk((xmlParserCtxtPtr)_context, NULL, 0, 1);
	[(id<WPBannerInfoParserProtocol>)_bannerInfo parsingFinished];
	_isFinished = YES;
}

- (void) startElementSAX:(NSString *) name attributes:(NSArray *) attributes
{
	[_itemsStack addObject:name];
	[(id<WPBannerInfoParserProtocol>)_bannerInfo openXMLTagFound:name attributes:attributes prevTags:_itemsStack];
	NSMutableString *str = [[NSMutableString alloc] init];
	[_textsStack addObject:str];
	[str release];
}

- (void) endElementSAX:(NSString *) name
{
	NSString *text = [_textsStack lastObject];
	if ([text length] > 0)
	{
		// Found text
		[(id<WPBannerInfoParserProtocol>)_bannerInfo textFound:text prevTags:_itemsStack];
	}
	
	[_itemsStack removeLastObject];

	[(id<WPBannerInfoParserProtocol>)_bannerInfo closeXMLTagFound:name prevTags:_itemsStack];
	
	[_textsStack removeLastObject];
	
}

- (void) charactersFoundSAX:(NSString *) str
{
	NSMutableString *text = [_textsStack lastObject];
	[text appendString:str];
}

- (void) errorFoundSAX
{
	[(id<WPBannerInfoParserProtocol>)_bannerInfo errorFoundWithPrevTags:_textsStack];
	_isSuccess = NO;
}

@end

#pragma mark SAX Parsing Callbacks

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, 
                            int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes)
{
    WPBannerInfoParser *parser = (WPBannerInfoParser *)ctx;
	
	NSString *name   = [[NSString alloc] initWithUTF8String:(const char *)localname];
	
	NSMutableArray *attrArray = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < nb_attributes; i++)
	{
		NSString *attrName = [[NSString alloc] initWithUTF8String:(const char *)attributes[5*i]];
		
		NSString *attrValue = [[NSString alloc] initWithBytesNoCopy:(void *)attributes[5*i+3] length:attributes[5*i+4]-attributes[5*i+3] encoding:NSUTF8StringEncoding freeWhenDone:NO];
		
		[attrArray addObject:[NSArray arrayWithObjects:attrName, attrValue, nil]];
		
		[attrName release];
		[attrValue release];
	}
	
	[parser startElementSAX:name attributes:attrArray];
	
	[attrArray release];
	
	[name release];
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI)
{    
    WPBannerInfoParser *parser = (WPBannerInfoParser *)ctx;
	
	NSString *name   = [[NSString alloc] initWithUTF8String:(const char *)localname];
	
	[parser endElementSAX:name];
	
	[name release];
}

static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len)
{
    WPBannerInfoParser *parser = (WPBannerInfoParser *)ctx;
	
	if (len > 0)
	{
		NSData *data = [[NSData alloc] initWithBytes:ch length:len];
		NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[parser charactersFoundSAX:value];
		[value release];
		[data release];
	}
}

static void errorEncounteredSAX(void *ctx, const char *msg, ...)
{
    WPBannerInfoParser *parser = (WPBannerInfoParser *)ctx;
	
	[parser errorFoundSAX];
}

// The handler struct has positions for a large number of callback functions. If NULL is supplied at a given position,
// that callback functionality won't be used. Refer to libxml documentation at http://www.xmlsoft.org for more information
// about the SAX callbacks.
static xmlSAXHandler simpleSAXHandlerStruct = {
	NULL,                       /* internalSubset */
	NULL,                       /* isStandalone   */
	NULL,                       /* hasInternalSubset */
	NULL,                       /* hasExternalSubset */
	NULL,                       /* resolveEntity */
	NULL,                       /* getEntity */
	NULL,                       /* entityDecl */
	NULL,                       /* notationDecl */
	NULL,                       /* attributeDecl */
	NULL,                       /* elementDecl */
	NULL,                       /* unparsedEntityDecl */
	NULL,                       /* setDocumentLocator */
	NULL,                       /* startDocument */
	NULL,                       /* endDocument */
	NULL,                       /* startElement*/
	NULL,                       /* endElement */
	NULL,                       /* reference */
	charactersFoundSAX,         /* characters */
	NULL,                       /* ignorableWhitespace */
	NULL,                       /* processingInstruction */
	NULL,                       /* comment */
	NULL,                       /* warning */
	errorEncounteredSAX,        /* error */
	NULL,                       /* fatalError //: unused error() get all the errors */
	NULL,                       /* getParameterEntity */
	NULL,                       /* cdataBlock */
	NULL,                       /* externalSubset */
	XML_SAX2_MAGIC,             //
	NULL,
	startElementSAX,            /* startElementNs */
	endElementSAX,              /* endElementNs */
	NULL,                       /* serror */
};
