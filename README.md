Plus1 WapStart iOS SDK
======================
This is an open source library for [Plus1 WapStart](https://plus1.wapstart.ru) network advertisement integration into your iOS Apps, including iPhone and  iPad.

Plus1 WapStart iOS SDK is distributed under a free license BSD (as is).

# Installation and set up

1. Download our latest version of SDK: https://github.com/WapStart/plus1-ios-sdk/tags
2. Copy all files located from directories _SDK/resources_ и _SDK/src_ into your project;
3. In prefix header file *(.pch)* of your App state the constant values necessary for working with SDK. For example:

    \#define PLUS1_APP_ID 4242 // App Identification in Plus1 WapStart system  
    \#define UPDATE_BANNER_TIMEOUT 15 // Browser refresh rate in seconds

For the correct functioning of your test App please also specify publisher identification *(PLUS1_APP_ID)* in [WapPlusDemo_Prefix.pch](https://github.com/WapStart/plus1-ios-sdk/blob/master/examples/WapPlusDemo/WapPlusDemo_Prefix.pch) file. For a test App [AdWhirlSample](https://github.com/WapStart/plus1-ios-sdk/tree/master/examples/AdWhirlSample) publisher identification must be specified in [adWhirlViewController.m](https://github.com/WapStart/plus1-ios-sdk/blob/master/examples/AdWhirlSample/Classes/adWhirlViewController.m#L48) (**initWithApplicationId** method).

Publisher identification *PLUS1_APP_ID* can be found on **Publisher code** page after registration in [Plus1 WapStart](https://plus1.wapstart.ru) system and added an iOS type publisher.

## If you use ARC
If you use ARC in your App, you need to add **-fno-objc-arc** compilator flag to SDK classes. Otherwise there will be errors at the compilation stage.

To add flags, go to your project settings, then to *Build Phases*, open *Compile Sources* list, find the necessary classes and double click on them. After adding the flag you will see the following result:
![Adding flag -fno-objc-arc](https://github.com/WapStart/plus1-ios-sdk/raw/master/doc/flag-fno-objc-arc.png)

# Using SDK
Examples of banner set up and configuring can be found in test App [WapPlusDemo](https://github.com/WapStart/plus1-ios-sdk/tree/master/examples/WapPlusDemo). This section contains brief comments for quick project set up.

First, add your own url scheme. It is necessary for return back to the App from the browser after the user cookie synchronization. The scheme must be added to your App plist. If you are using *disabledOpenLinkAction* of [WPBannerRequestInfo](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerRequestInfo.md), you may skip these settings (not recommended).

For example, for Например, WapPlusDemo test App url scheme looks as follows:
![WapPlusDemo url scheme](https://github.com/WapStart/plus1-ios-sdk/raw/master/doc/demo-url-scheme.png)

For a test App Для wsp1demo:// can be used as a scheme.

**Note:** in order to guaranty the return to your App the scheme must be unique. If your specified scheme is being used by another App, iOS behavior is not regulated and link may lead to any App. Try to create a unique scheme.

## Adding banner into your App
Add protocol [WPBannerViewDelegate](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerViewDelegate.md) support to successor *UIViewController*:

```ObjectiveC
#import <UIKit/UIKit.h>
#import "WPBannerView.h"

@interface ExampleViewController : UIViewController <WPBannerViewDelegate>
{
  ...
}
...

@end
```
Initialize and tune objects [WPBannerRequestInfo](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerRequestInfo.md) and [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md) in **viewDidLoad** method as follows:

```ObjectiveC
#import "ExampleViewController.h"
#import "WPBannerInfo.h"

@interface ExampleViewController (PrivateMethods)
...
@end

@implementation ExampleViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  ...

  WPBannerRequestInfo *requestInfo = [[WPBannerRequestInfo alloc] initWithApplicationId:PLUS1_APP_ID];

  topBannerView = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo andCallbackUrl:@"wsp1demo://ru.wapstart.plus1.ios.demoapp"];
  topBannerView.showCloseButton = YES;
  topBannerView.delegate = self;
  topBannerView.autoupdateTimeout = UPDATE_BANNER_TIMEOUT;
  [topBannerView setHidden:YES];
  [self.view addSubview:topBannerView];

  [requestInfo release];
  [topBannerView reloadBanner];
}

@end
```
You may set *nil* for *andCallbackUrl* if you are using *disabledOpenLinkAction* of [WPBannerRequestInfo](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerRequestInfo.md) (not recommended).

All objects may be tuned as you like – see detailed description of object specifications for [WPBannerRequestInfo](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerRequestInfo.md) and [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md).

If necessary, add the required methods of [WPBannerViewDelegate](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerViewDelegate.md) protocol into your App.

# Using SDK with AdWhirl
We suppose that you are familiar with AdWhirl and have already integrated it into your App.

Examples of banner setup and configurations can be seen in test App [AdWhirlSample](https://github.com/WapStart/plus1-ios-sdk/tree/master/examples/AdWhirlSample). This section contains brief comments for quick setup of your project that uses AdWhirl.

Below you can find the steps for adding [Plus1 WapStart](https://plus1.wapstart.ru) advertising network via **Custom Events** mechanism.

## Adding a code into your App with AdWhirl
Add protocol [WPBannerViewDelegate](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerViewDelegate.md) (if necessary), object of [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md) class and **plus1CustomEvent** method, responsible for receiving banners from the network:

```ObjectiveC
#import <UIKit/UIKit.h>
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "WPBannerView.h"

@interface adWhirlViewController : UIViewController<AdWhirlDelegate, WPBannerViewDelegate> {
    WPBannerView *plus1Banner;
}

- (void) plus1CustomEvent:(AdWhirlView *) adWhirlView;

@end
```
Initialize and set up objects [WPBannerRequestInfo](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerRequestInfo.md) and [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md) in **viewDidLoad** method, add implementation of method **plus1CustomEvent** for processing of AdWhirl events:

```ObjectiveC
#import "adWhirlViewController.h"

@implementation adWhirlViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    ...

    WPBannerRequestInfo *requestInfo =
        [[WPBannerRequestInfo alloc] initWithApplicationId:
                            /* Place your WapStart Plus1 application id here */];

    plus1Banner = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo andCallbackUrl:/* Place your callback url here */];
    plus1Banner.showCloseButton = NO;
    plus1Banner.autoupdateTimeout = 0;
    plus1Banner.delegate = self;
    [plus1Banner setFrame:adView.bounds];
    [requestInfo release];
}

- (void)dealloc {
    [plus1Banner release];
    [super dealloc];
}

# pragma mark Plus1 Custom Event

- (void) plus1CustomEvent:(AdWhirlView *) adWhirlView {
    [plus1Banner reloadBanner];
    [adWhirlView replaceBannerViewWith:plus1Banner];
}

@end
```
If necessary, add the required methods of [WPBannerViewDelegate](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerViewDelegate.md) protocol into your App.

## Adding Custom Event in AdWhirl
Go to App control panel on AdWhirl site and add newly created Custom Event to the network:
![Adding Custom Event](https://github.com/WapStart/plus1-ios-sdk/raw/master/doc/plus1_custom_event.png)

After adding it, you will be able to specify the percentage of ads that will be sent to [Plus1 WapStart](https://plus1.wapstart.ru) network.

# Contact information
If you have any questions on integration please contact our support team:  
E-Mail: clientsupport@co.wapstart.ru  
ICQ: 553425962
