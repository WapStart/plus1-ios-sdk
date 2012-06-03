WPBannerRequestInfo
===================

    @interface WPBannerRequestInfo : NSObject
    
    @property (nonatomic, assign) NSInteger  applicationId;
    @property (nonatomic, assign) WPGender   gender;
    @property (nonatomic, assign) NSInteger  age;
    @property (nonatomic, readonly) NSString *pageId;
    @property (nonatomic, retain) NSString   *login;
    @property (nonatomic, retain) CLLocation *location;

    @end

Параметры
---------

* `applicationId`
ID приложения в системе Plus1 WapStart
* `gender`
пол текущего пользователя приложения (если известен)
* `age`
возраст текущего пользователя приложения (если известен)
* `pageId`

* `login`
имя пользователя (если известно)
* `location`