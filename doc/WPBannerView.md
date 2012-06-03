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
  показывать или нет кнопку закрытия баннера (по умолчанию: YES).
* `autoupdateTimeout`  
  период авто обновления (в секундах). Если равно 0, то авто обновление баннера отключено.
* `isMinimized`  
  минимизирован баннер или нет.
* `minimizedLabel`  
  строка, которая отображается, когда баннер свернут (по умолчанию = "Открыть баннер").
* `isEmpty`  
  есть ли информация с сервера.
* `bannerHeight`  
  высота баннера в данный момент.
* `disableAutoDetectLocation`  
  получение местонахождения пользователя. Информация автоматически получаться не будет (по умолчанию: YES).
* `delegate`  
  объект, который будет информироваться о текущем состоянии баннера (см. описание WPBannerViewDelegate).
* `(id) initWithBannerRequestInfo:(WPBannerRequestInfo *) requestInfo`  
  инициализация объекта.
* `(void) showFromTop:(BOOL) animated`  
  показать баннер сверху superview.
* `(void) showFromBottom:(BOOL) animated`  
  показать баннер снизу superview.
* `(void) hide:(BOOL) animated`  
  cкрыть баннер. Метод работает только в случае, если баннер находится сверху или снизу.
* `(void) reloadBanner`  
  получить заново информацию о баннере.
* `(void) setIsMinimized:(BOOL)minimize animated:(BOOL) animated`  
  минимизировать баннер.
