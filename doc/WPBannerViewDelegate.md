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
  вызывается при получении информации о баннере.
* `(void) bannerViewDidHide:(WPBannerView *) bannerView;`  
  вызывается после вызова метода hide: у WPBannerView.
* `(void) bannerViewMinimizedStateChanged:(WPBannerView *) bannerView`  
  вызывается, когда баннер сворачивается или разворачивается.