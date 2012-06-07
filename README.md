WapStart Plus1 iOS SDK
======================
Это open source библиотека для интеграции рекламы системы WapStart Plus1 в ваши iOS-приложения, включая iPhone и iPad.

WapStart Plus1 iOS SDK распространяется под свободной лицензией BSD.

# Установка и настройка

1. Скачайте последнюю версию SDK: https://github.com/Wapstart/plus1-ios-sdk/tag
2. Скопируйте все файлы, находящиеся в директориях _SDK/resources_ и _SDK/src_, в свой проект;
3. В prefix header файле *(.pch)* своего приложения укажите константы, необходимые для работы sdk. Например:

    \#define APPLICATION_ID 4242 // Идентификатор приложения в системе WapStart Plus1  
    \#define UPDATE_BANNER_TIMEOUT 15 // Частота обновления баннера в секундах

Для корректной работы тестового приложения также требуется указать идентификатор площадки *(APPLICATION_ID)* в prefix header файле *(.pch)*.

Идентификатор площадки *APPLICATION_ID* можно узнать на странице **Код для площадки** после регистрации в системе [WapStart Plus1](https://plus1.wapstart.ru/) и добавления площадки типа iOS.

## Если используется ARC
Если вы используете ARC в вашем приложении, то требуется добавить флаг компилятора **-fno-objc-arc** к классам SDK. В противном случае на этапе компиляции будут ошибки.

Для добавления флагов пройдите в настройки вашего проекта, затем перейдите в *Build Phases*, раскройте список *Compile Sources*, найдите в списке классов нужные и кликните по ним двойным щелчком. После добавления флага должен получиться примерно следующий результат:
![Добавление флага -fno-objc-arc](http://www.imaladec.net/upload-files/images/Lessons/arc/arc_03.jpg)

# Использование SDK
Примеры настройки и конфигурации баннеров можно посмотреть в тестовом приложении **WapPlusDemo**. В этом разделе даются краткие пояснения для быстрой настройки собственного проекта.

## Добавление баннера в приложение
Добавьте поддержку протокола *WPBannerViewDelegate* к наследнику *UIViewController*:

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
Инициализируйте и настройте объекты *WPBannerRequestInfo* и *WPBannerView* в методе *viewDidLoad* следующим образом:

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

  WPBannerRequestInfo *requestInfo = [[WPBannerRequestInfo alloc] initWithApplicationId:APPLICATION_ID];

  topBannerView = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo];
  topBannerView.showCloseButton = YES;
  topBannerView.delegate = self;
  topBannerView.hideWhenEmpty = YES;
  topBannerView.autoupdateTimeout = UPDATE_BANNER_TIMEOUT;
  [topBannerView setHidden:YES];
  [self.view addSubview:topBannerView];

  [requestInfo release];
  [topBannerView reloadBanner];
}
```
Все объекты можно настраивать на ваше усмотрение - смотрите подробное описание свойств объектов [WPBannerRequestInfo](doc/WPBannerRequestInfo.md) и [WPBannerView](doc/WPBannerView.md).

Если необходимо, добавьте в ваше приложение необходимые [методы протокола WPBannerViewDelegate](doc/WPBannerViewDelegate.md).

# Контактная информация
По всем возникающим у вас вопросам интеграции вы можете обратиться в службу поддержки пользователей:  
email: clientsupport@co.wapstart.ru  
icq: 553425962