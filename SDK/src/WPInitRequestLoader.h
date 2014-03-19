//
//  WPInitRequestLoader.h
//  WapPlusDemo
//
//  Created by WapStart on 3/11/14.
//
//

#import <Foundation/Foundation.h>

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
	id<WPInitRequestLoaderDelegate> _delegate;

	NSURLConnection		*_urlConnection;
}

@end

@protocol WPInitRequestLoaderDelegate

- (void) initRequestLoaderDidFinish:(NSDictionary *) properties;
- (void) initRequestLoader:(WPInitRequestLoader *) loader didFailWithCode:(WPInitRequestLoaderErrorCode) errorCode;

@end