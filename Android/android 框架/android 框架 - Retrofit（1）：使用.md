### Retrofit 配置

还需要添加Gson依赖
```
 compile 'com.squareup.retrofit2:retrofit:2.0.2'
 compile 'com.squareup.retrofit2:converter-gson:2.1.0'
```
> 注意: Retrofit 2.0不再依赖于Gson, 如果你想接收json 结果并解析成DAO，你必须把Gson Converter 作为一个独立的依赖添加进来。

### 添加权限

```
<uses-permission android:name="android.permission.INTERNET"/>
```

### Retrofit使用

1. 创建一个Retrofit 对象

```
Retrofit retrofit = new Retrofit.Builder()
            .addConverterFactory(GsonConverterFactory.create())//解析方法
             //这里建议：- Base URL: 总是以/结尾；- @Url: 不要以/开头
            .baseUrl("http://www.wangyinews.com.cn/")
            .build();
```

2. 接口申明

```
public interface LoginInter
{
  /**
   * 如果不需要转换成Json数据,可以用了ResponseBody;
   * @return call
   */
  @GET("login")
  Call<UserInfo> login(@Query("username") String username, @Query("password") String password);
}
```
若需要重新定义接口地址可以使用@Url，例：

```
@(android 框架)GET
  Call<List<CaigenActivitySubjectsBean>> getActivitySubjectsList(
          @Url String url,
          @QueryMap Map<String, String> map);
```

3. 创建访问API的请求

```
LoginInter api = retrofit.create(LoginInter.class);
Call<UserInfo> call = service.login("xxxxxxx", "xxxxxx");
```

4. 同步调用

```
UserInfo userInfo = call.execute();
```

5. 异步调用

```
call.enqueue(new Callback<UserInfo>(){  
         @Override  
         public void onResponse(Response<UserInfo> response) {  
             //成功返回数据后在这里处理，使用response.body();获取得到的结果
             UserInfo userInfo = response.body();
          }  
          @Override  
          public voidonFailure(Throwable t) {  
             //请求失败在这里处理  
         }  
     });
```

6. 取消请求

```
call.cancel();
```

### 接口参数
#### Path
类似这样链接：http://wuxiaolong.me/2016/01/15/retrofit/

```
 @GET("2016/01/15/{retrofit}")
 Call<ResponseBody> getData(@Path("retrofit") String retrofit);
```

即您传的参数retrofit内容会替换大括号里的内容。

#### Query
类似这样链接：http://wuxiaolong.me/v1?ip=202.202.33.33&name=WuXiaolong

```
@GET("v1")
Call<ResponseBody> getData(@Query("ip") String ip,@Query("name") String name);
```

#### Field
表单提交，如登录

```
 @FormUrlEncoded
 @POST("v1/login")
 Call<ResponseBody> userLogin(@Field("phone") String phone, @Field("password") String password);
```

 
#### 传json格式
如果参数是json格式，如：

```
{        
    "apiInfo": {        
        "apiName": "WuXiaolong",        
        "apiKey": "666"        
    }        
}
```

建立Bean

```
public class ApiInfo {
        private ApiInfoBean apiInfo;

        public ApiInfoBean getApiInfo() {
            return apiInfo;
        }

        public void setApiInfo(ApiInfoBean apiInfo) {
            this.apiInfo = apiInfo;
        }

        public class ApiInfoBean {
            private String apiName;
            private String apiKey;
            //省略get和set方法
        }
    }
```

ApiStores

```
@POST("client/shipper/getCarType")
Call<ResponseBody> getData(@Body ApiInfo apiInfo);
```

代码调用

```
ApiInfo apiInfo = new ApiInfo();
ApiInfo.ApiInfoBean apiInfoBean = apiInfo.new ApiInfoBean();
apiInfoBean.setApiKey("666");
apiInfoBean.setApiName("WuXiaolong");
apiInfo.setApiInfo(apiInfoBean);
//调接口
getData(apiInfo);
```

#### 传数组

```
@GET("v1/enterprise/find")
Call<ResponseBody> getData(@Query("id") String id, @Query("linked[]") String... linked);
```

代码调用

```
String id="WuXiaolong"；
String[] s = new String[]{"WuXiaolong"};
//调接口
getData(id, s);
```

#### 传文件-单个

```
@Multipart
@POST("v1/create")
Call<ResponseBody> create(@Part("pictureName") RequestBody pictureName,  @Part MultipartBody.Part picture);
```

代码调用

```
RequestBody pictureNameBody = RequestBody.create(MediaType.parse(AppConstants.CONTENT_TYPE_FILE), "pictureName");
File picture= new File(path);
RequestBody requestFile = RequestBody.create(MediaType.parse(AppConstants.CONTENT_TYPE_FILE), picture);
// MultipartBody.Part is used to send also the actual file name
MultipartBody.Part picturePart = MultipartBody.Part.createFormData("picture", picture.getName(), requestFile);
//调接口
create(pictureNameBody, picturePart);
```

#### 传文件-多个

```
@Multipart
@POST("v1/create")
Call<ResponseBody> create(@Part("pictureName") RequestBody pictureName,   @PartMap Map<String, RequestBody> params);
```

代码调用

```
RequestBody pictureNameBody = RequestBody.create(MediaType.parse(AppConstants.CONTENT_TYPE_FILE), "pictureName");
File picture= new File(path);
RequestBody requestFile = RequestBody.create(MediaType.parse(AppConstants.CONTENT_TYPE_FILE), picture);
Map<String, RequestBody> params = new HashMap<>();
params.put("picture\"; filename=\"" + picture.getName() + "", requestFile);
//调接口
create(pictureNameBody, params);
```

### 接收String结果
> 默认情况下, Retrofit只能将HTTP请求体反序列化为OkHttp的ResponseBody类型, 并且在@Body中只能接受RequestBody类型.
 
 
添加`String`转化器的操作步骤
 
 1. 在`build.gradle`中添加如下:
```
compile 'com.squareup.retrofit2:converter-scalars:2.1.0'
```

 2. 使用`addConverterFactory`添加对String返回类型的支持:

```
Retrofit retrofit = new Retrofit.Builder()
    .baseUrl("https://api.github.com")
    .addConverterFactory(ScalarsConverterFactory.create())
    .build();

GitHubService service = retrofit.create(GitHubService.class);
```

### 标签总结
- @Path：所有在网址中的参数（URL的问号前面）
- @Query：`用于GET请求`URL问号后面的参数
- @QueryMap：相当于多个@Query
- @Field：`用于POST请求`，提交单个数据
- @Body：相当于多个@Field，以对象的形式提交
> - 使用@Field时记得添加@FormUrlEncoded
> - 若需要重新定义接口地址，可以使用@Url，将地址以参数的形式传入即可。如

```
  @GET
  Call<List<Activity>> getActivityList(
          @Url String url,
          @QueryMap Map<String, String> map);
  Call<List<Activity>> call = service.getActivityList(
              "http://115.159.198.162:3001/api/ActivitySubjects", map);
```

### 参考文档
[Retrofit中文文档](https://fantasymaker.gitbooks.io/retrofit-document-in-chinese/content/converters.html)
[Retrofit 2.0 的使用](http://www.jianshu.com/p/7efdc3477269)
[Android Retrofit 实现文字（参数）和多张图片一起上传](http://blog.csdn.net/jdsjlzx/article/details/52246114)
[你真的会用Retrofit2吗?Retrofit2完全教程](http://www.jianshu.com/p/308f3c54abdd)
