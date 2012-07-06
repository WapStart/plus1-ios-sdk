WPBannerView
============
 Отображение баннера.

    @interface WPBannerView : UIView <WPBannerInfoLoaderDelegate, WPLocationManagerDelegate, MRAdViewDelegate, WPAdViewDelegate>

    @property (nonatomic, assign) BOOL showCloseButton;
    @property (nonatomic, assign) CGFloat autoupdateTimeout;
    @property (nonatomic, assign) BOOL isMinimized;
    @property (nonatomic, retain) NSString *minimizedLabel;
    @property (nonatomic, readonly) BOOL isEmpty;
    @property (nonatomic, readonly) CGFloat bannerHeight;
    @property (nonatomic, assign) BOOL disableAutoDetectLocation;
    @property (nonatomic, assign) UIInterfaceOrientation orientation;

    @property (nonatomic, assign) id<WPBannerViewDelegate> delegate;

    (id) initWithBannerRequestInfo:(WPBannerRequestInfo *) requestInfo;

    (void) showFromTop:(BOOL) animated;
    (void) showFromBottom:(BOOL) animated;

    (void) hide:(BOOL) animated;

    (void) reloadBanner;

    (void) setIsMinimized:(BOOL)minimize animated:(BOOL) animated;

Параметры
---------
* `showCloseButton`  
  Показывать или нет кнопку закрытия баннера (по умолчанию: *YES*)
* `autoupdateTimeout`  
  Период авто обновления (в секундах). Если равно 0, то авто обновление баннера отключено
* `isMinimized`  
  Минимизирован баннер или нет
* `minimizedLabel`  
  Строка, которая отображается, когда баннер свёрнут (по умолчанию = "*Открыть баннер*")
* `isEmpty`  
  Есть ли информация с сервера
* `bannerHeight`  
  Высота баннера в данный момент
* `disableAutoDetectLocation`  
  Получение местонахождения пользователя. Информация автоматически получаться не будет (по умолчанию: *YES*)
* `delegate`  
  Объект, который будет информироваться о текущем состоянии баннера (см. [WPBannerViewDelegate](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerViewDelegate.md)
* `(id) initWithBannerRequestInfo:(WPBannerRequestInfo *) requestInfo`  
  Инициализация объекта
* `(void) showFromTop:(BOOL) animated`  
  Показать баннер сверху superview
* `(void) showFromBottom:(BOOL) animated`  
  Показать баннер снизу superview
* `(void) hide:(BOOL) animated`  
  Скрыть баннер. Метод работает только в случае, если баннер находится сверху или снизу
* `(void) reloadBanner`  
  Получить заново информацию о баннере
* `(void) setIsMinimized:(BOOL)minimize animated:(BOOL) animated`  
  Минимизировать баннер
