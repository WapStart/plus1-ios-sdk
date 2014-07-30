WPBannerViewDelegate
====================

    @protocol WPBannerViewDelegate <NSObject>

    @optional

    (void) bannerViewPressed:(WPBannerView *) bannerView;
    (void) bannerViewInfoLoaded:(WPBannerView *) bannerView;
    (void) bannerViewInfoDidFailWithError:(WPBannerInfoLoaderErrorCode) errorCode;
    (void) bannerViewDidHide:(WPBannerView *) bannerView;
    (void) bannerViewMinimizedStateWillChange:(WPBannerView *) bannerView;
    (void) bannerViewMinimizedStateChanged:(WPBannerView *) bannerView;

Параметры
---------
* `(void) bannerViewPressed:(WPBannerView *) bannerView`  
  Вызывается при клике по баннеру
* `(void) bannerViewInfoLoaded:(WPBannerView *) bannerView`  
  Вызывается при получении информации о баннере
* `(void) bannerViewInfoDidFailWithError:(WPBannerInfoLoaderErrorCode) errorCode`  
  Вызывается при ошибке загрузки баннера, errorCode содержит тип ошибки
* `(void) bannerViewDidHide:(WPBannerView *) bannerView;`  
  Вызывается после вызова метода hide у [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md)
* `(void) bannerViewMinimizedStateWillChange:(WPBannerView *) bannerView`  
  Вызывается перед началом анимации сворачивания или разворачивания баннера
* `(void) bannerViewMinimizedStateChanged:(WPBannerView *) bannerView`  
  Вызывается, когда баннер сворачивается или разворачивается
