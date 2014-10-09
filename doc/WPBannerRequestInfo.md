WPBannerRequestInfo
===================
 Информация для получения баннера.

    @interface WPBannerRequestInfo : NSObject
    
    @property (nonatomic, assign) NSInteger  applicationId;
    @property (nonatomic, assign) WPGender   gender;
    @property (nonatomic, assign) NSInteger  age;
    @property (nonatomic, retain) NSString   *login;
    @property (nonatomic, retain) CLLocation *location;
    @property (nonatomic, retain) NSString   *uid;
    @property (nonatomic, retain) NSString   *facebookUserHash;
    @property (nonatomic, retain) NSString   *twitterUserHash;

Обязательным параметром является только идентификатор площадки **applicationId** в системе Plus1 WapStart, но рекомендуется устанавливать параметры **age**, **gender** и **login** для более точного подбора объявлений.

Старайтесь также передавать информацию о местоположении пользователя для повышения точности таргетирования рекламы. Текущее местоположение может быть установлено в автоматическом режиме (см. [WPBannerView](https://github.com/WapStart/plus1-ios-sdk/blob/master/doc/WPBannerView.md), но вы можете устанавливать его самостоятельно, если ваше приложение использует геолокацию.

Параметры
---------

* `applicationId`  
  ID приложения в системе [Plus1 WapStart](https://plus1.wapstart.ru) (обязательный параметр)
* `gender`  
  Пол текущего пользователя приложения (необязательный параметр)
* `age`  
  Возраст текущего пользователя приложения (необязательный параметр)
* `login`  
  Имя пользователя (необязательный параметр)  
Для сохранения конфиденциальности пользователя рекомендуется передавать результат хеширующей функции от логина.
* `location`  
  Местоположение пользователя (необязательный параметр)
* `uid`  
  Идентификатор пользователя в системе Plus1 WapStart (устанавливает SDK)
* `facebookUserHash`  
  Идентификатор пользователя в facebook (устанавливает SDK)
* `twitterUserHash`  
  Идентификатор пользователя в twitter (устанавливает SDK)
* `disabledOpenLinkAction`  
  Этот параметр отключает механизм перехода в браузер (с последующим возвращением в приложение) при инициализации SDK
