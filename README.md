Plus1 WapStart iOS SDK
======================
Это open source библиотека для интеграции рекламы сети [Plus1 WapStart](https://plus1.wapstart.ru) в ваши iOS-приложения, включая iPhone и iPad.

Plus1 WapStart iOS SDK распространяется под свободной лицензией BSD (as is).

# Установка и настройка

1. Скачайте последнюю версию SDK: https://github.com/WapStart/plus1-ios-sdk/tags
2. Скопируйте все файлы, находящиеся в директориях _SDK/resources_ и _SDK/src_, в свой проект;
3. В prefix header файле *(.pch)* своего приложения укажите константы, необходимые для работы SDK. Например:

    \#define PLUS1_APP_ID 4242 // Идентификатор приложения в системе Plus1 WapStart  
    \#define UPDATE_BANNER_TIMEOUT 15 // Частота обновления баннера в секундах

Для корректной работы тестового приложения также требуется указать идентификатор площадки *(PLUS1_APP_ID)* в файле [WapPlusDemo_Prefix.pch](https://github.com/WapStart/plus1-ios-sdk/blob/master/examples/WapPlusDemo/WapPlusDemo_Prefix.pch). Для тестового приложения [AdWhirlSample](https://github.com/WapStart/plus1-ios-sdk/tree/master/examples/AdWhirlSample) идентификатор площадки нужно задать в файле [adWhirlViewController.m](https://github.com/WapStart/plus1-ios-sdk/blob/master/examples/AdWhirlSample/Classes/adWhirlViewController.m#L48) (метод **initWithApplicationId**).

Идентификатор площадки *PLUS1_APP_ID* можно узнать на странице **Код для площадки** после регистрации в системе [Plus1 WapStart](https://plus1.wapstart.ru) и добавления площадки типа iOS.

## Если используется ARC
Если вы используете ARC в вашем приложении, то требуется добавить флаг компилятора **-fno-objc-arc** к классам SDK. В противном случае на этапе компиляции будут ошибки.

Для добавления флагов пройдите в настройки вашего проекта, затем перейдите в *Build Phases*, раскройте список *Compile Sources*, найдите в списке классов нужные и кликните по ним двойным щелчком. После добавления флага должен получиться примерно следующий результат:
![Добавление флага -fno-objc-arc](https://github.com/WapStart/plus1-ios-sdk/raw/master/doc/flag-fno-objc-arc.png)

# Использование SDK
Примеры настройки и конфигурации баннеров можно посмотреть в тестовом приложении [WapPlusDemo](https://github.com/WapStart/plus1-ios-sdk/tree/master/examples/WapPlusDemo). В этом разделе даются краткие пояснения для быстрой настройки собственного проекта.

## Добавление баннера в приложение
Добавьте поддержку протокола [WPBannerViewDelegate](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerViewDelegate.md) к наследнику *UIViewController*:

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
Инициализируйте и настройте объекты [WPBannerRequestInfo](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerRequestInfo.md) и [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md) в методе **viewDidLoad** следующим образом:

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

  topBannerView = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo];
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
Все объекты можно настраивать на ваше усмотрение - смотрите подробное описание свойств объектов [WPBannerRequestInfo](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerRequestInfo.md) и [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md).

Если необходимо, добавьте в ваше приложение необходимые методы протокола [WPBannerViewDelegate](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerViewDelegate.md).

# Использование SDK с AdWhirl
Предполагается, что вы знакомы с AdWhirl и выполнили все шаги по его интеграции в приложение.

Примеры настройки и конфигурации баннеров можно посмотреть в тестовом приложении [AdWhirlSample](https://github.com/WapStart/plus1-ios-sdk/tree/master/examples/AdWhirlSample). В этом разделе даются краткие пояснения для быстрой настройки собственного проекта, использующего AdWhirl.

Ниже приводится последовательность действий для добавления рекламной сети [Plus1 WapStart](https://plus1.wapstart.ru) через механизм **Custom Events**.

## Добавление кода в приложение с AdWhirl
Добавьте поддержку протокола [WPBannerViewDelegate](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerViewDelegate.md) (если необходимо), объект класса [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md) и метод **plus1CustomEvent**, отвечающий за получение баннеров от сети:

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
Инициализируйте и настройте объекты [WPBannerRequestInfo](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerRequestInfo.md) и [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md) в методе **viewDidLoad**, добавьте имплементацию метода **plus1CustomEvent** для обработки событий AdWhirl:

```ObjectiveC
#import "adWhirlViewController.h"

@implementation adWhirlViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    ...

    WPBannerRequestInfo *requestInfo =
        [[WPBannerRequestInfo alloc] initWithApplicationId:
                            /* Place your WapStart Plus1 application id here */];

    plus1Banner = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo];
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
Если необходимо, добавьте в ваше приложение необходимые методы протокола [WPBannerViewDelegate](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerViewDelegate.md).

##Добавление Custom Event в AdWhirl
Зайдите в панель управления приложением на сайте AdWhirl и добавьте вновь созданный Custom Event к сети:
![Добавление Custom Event](https://github.com/WapStart/plus1-ios-sdk/raw/master/doc/plus1_custom_event.png)

После добавления вы сможете указать процент рекламных объявлений, который будет отсылаться сети [Plus1 WapStart](https://plus1.wapstart.ru).

# Контактная информация
По всем возникающим у вас вопросам интеграции вы можете обратиться в службу поддержки пользователей:  
E-Mail: clientsupport@co.wapstart.ru  
ICQ: 553425962
