* 查询文件描述信息：

```java
public static String getCreationTime(File file) {
    if (file == null) {
        return null;
    }

    BasicFileAttributes attr = null;
    try {
        Path path =  file.toPath();
        attr = Files.readAttributes(path, BasicFileAttributes.class);
    } catch (IOException e) {
        e.printStackTrace();
    }
    // 创建时间
    Instant instant = attr.creationTime().toInstant();
    // 更新时间
    Instant instant = attr.lastModifiedTime().toInstant();
    // 上次访问时间
    Instant instant = attr.lastAccessTime().toInstant();
    String format = DateTimeFormatter.ofPattern("yyyy-MM-dd").withZone(ZoneId.systemDefault()).format(instant);
    
    return format;
}
```

* 创建文件夹
