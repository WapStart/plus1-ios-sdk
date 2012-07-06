WPBannerRequestInfo
===================
 Информация для получения баннера.

    @interface WPBannerRequestInfo : NSObject
    
    @property (nonatomic, assign) NSInteger  applicationId;
    @property (nonatomic, assign) WPGender   gender;
    @property (nonatomic, assign) NSInteger  age;
    @property (nonatomic, readonly) NSString *pageId;
    @property (nonatomic, retain) NSString   *login;
    @property (nonatomic, retain) CLLocation *location;

Обязательным параметром является только идентификатор площадки **applicationId** в системе Plus1 WapStart, но рекомендуется устанавливать параметры **age**, **gender** и **login** для более точного подбора объявлений.

Старайтесь также передавать информацию о местоположении пользователя для повышения точности таргетирования рекламы. Текущее местоположение может быть установлено в автоматическом режиме (см. [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/doc/WPBannerView.md)), но вы можете устанавливать его самостоятельно, если ваше приложение использует геолокацию.

Параметры
---------

* `applicationId`  
  ID приложения в системе [Plus1 WapStart](http://plus1.wapstart.ru/) (обязательный параметр)
* `gender`  
  пол текущего пользователя приложения (необязательный параметр)
* `age`  
  возраст текущего пользователя приложения (необязательный параметр)
* `pageId`  
  идентификатор страницы (вкладки приложения) (readonly)
* `login`  
  имя пользователя (необязательный параметр)  
Для сохранения конфиденциальности пользователя рекомендуется передавать результат хеширующей функции от логина.
* `location`  
  Местоположение пользователя (необязательный параметр)
