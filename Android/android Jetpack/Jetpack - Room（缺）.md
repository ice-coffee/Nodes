### 准备

```
dependencies {
  def room_version = "2.3.0"

  implementation "androidx.room:room-runtime:$room_version"
  kapt "androidx.room:room-compiler:$room_version"

  // optional - Kotlin Extensions and Coroutines support for Room
  implementation "androidx.room:room-ktx:$room_version"

  // optional - Test helpers
  testImplementation "androidx.room:room-testing:$room_version"
}
```

### Entity
使用 `@Entity` 注解修饰的实体类会在关联的 `DataBase` 对象中创建一个相对应的表，默认类名为表名，字段名为表字段名。

> 注意：要保留某个字段，Room 必须拥有该字段的访问权限。您可以将某个字段设为公开字段，也可以为其提供 getter 和 setter。

#### `@Entity` 注解
- primaryKeys - String[]：主键

### Dao


### DataBase
