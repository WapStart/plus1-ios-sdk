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

Параметры
---------

* `applicationId`  
  ID приложения в системе Plus1 WapStart (обязательный).
* `gender`  
  пол текущего пользователя приложения (необязательный).
* `age`  
  возраст текущего пользователя приложения (необязательный).
* `pageId`  

* `login`  
  имя пользователя (необязательный).
* `location`  