WPBannerViewDelegate
====================

    @protocol WPBannerViewDelegate <NSObject>

    @optional

    (void) bannerViewInfoLoaded:(WPBannerView *) bannerView;
    (void) bannerViewDidHide:(WPBannerView *) bannerView;
    (void) bannerViewMinimizedStateChanged:(WPBannerView *) bannerView;

Параметры
---------
* `(void) bannerViewInfoLoaded:(WPBannerView *) bannerView`  
  Вызывается при получении информации о баннере
* `(void) bannerViewDidHide:(WPBannerView *) bannerView;`  
  Вызывается после вызова метода hide у [WPBannerView](doc/WPBannerView.md)
* `(void) bannerViewMinimizedStateChanged:(WPBannerView *) bannerView`  
  Вызывается, когда баннер сворачивается или разворачивается
