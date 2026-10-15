### [转自](https://www.jianshu.com/p/9a2e66916fcb)

### CameraManager
> 一种用于查询、描述和连接摄像设备的系统服务管理器。

和其他系统服务初始化的方式一样：
```
Context.getSystemService(Context.CAMERA_SERVICE)
```

主要功能：
- cameraManager.getCameraIdList()： 获取Android设备的摄像头列表。
- cameraManager.getCameraCharacteristics(cameraId)： 获取指定摄像头的相关特性。
- cameraManager.openCamera(String cameraId, CameraDevice.StateCallback callback, Handler handler)： 打开指定Id的摄像头，StateCallback 是打开状态的一个监听回调，Handler 表示使用哪个线程处理回调，如果为null则表示当前线程。

### CameraDevice
> 代表当前连接的相机设备。

通过开启相机时的CameraDevice.StateCallback回调获取。

主要功能：
- cameraDevice.createCaptureRequest：创建CaptureRequest。
- cameraDevice.createCaptureSession：创建CameraCaptureSession。
- 关闭相机设备。
- 监听相机设备的状态，例如断开连接、开启成功和开启失败等。

### CameraCharacteristics
> 提供相机设备的信息。它是CameraMetadata的子类。

通过如下获得。
```
CameraManager.getCameraCharacteristics(cameraId)
```

主要功能：

相机设备硬件设备支持Camera2特性的级别，截止到 Android P 为止，从低到高一共有 ==LEGACY、LIMITED、FULL 和 LEVEL_3== 四个级别：
- LEGACY：向后兼容的级别，处于该级别的设备意味着它只支持 Camera1 的功能，不具备任何 Camera2 高级特性。
- LIMITED：除了支持 Camera1 的基础功能之外，还支持部分 Camera2 高级特性的级别。
- FULL：支持所有 Camera2 的高级特性。
- LEVEL_3：新增更多 Camera2 高级特性，例如 YUV 数据的后处理等。

使用如下代码检查设备的支持级别：
```
// Returns true if the device supports the required hardware level, or better.
 boolean isHardwareLevelSupported(CameraCharacteristics c, int requiredLevel) {
     final int[] sortedHwLevels = {
         CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY,
         CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_EXTERNAL,
         CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED,
         CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_FULL,
         CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_3
     };
     int deviceLevel = c.get(CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL);
     if (requiredLevel == deviceLevel) {
         return true;
     }

     for (int sortedlevel : sortedHwLevels) {
         if (sortedlevel == requiredLevel) {
             return true;
         } else if (sortedlevel == deviceLevel) {
             return false;
         }
     }
     return false; // Should never reach here
 }
```
可以通过==CameraCharacteristics#REQUEST_AVAILABLE_CAPABILITIES==查看相机设备支持的完整特性列表。

通过==CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP==获取Camera支持的输出格式和尺寸。
```
val streamConfigurationMap = cameraCharacteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
val supportedSizes = streamConfigurationMap?.getOutputSizes(SurfaceTexture::class.java)
```
获取相机支持的尺寸列表会需要你传递一个 Class 类型，然后根据这个类型返回对应的尺寸列表，如果给定的类型不支持，则返回 null，你可以通过 ==StreamConfigurationMap.isOutputSupportedFor()== 方法判断某一个类型是否被支持，常见的类型有：

- ImageReader：常用来拍照或接收 YUV 数据。
- MediaRecorder：常用来录制视频。
- MediaCodec：常用来录制视频。
- SurfaceHolder：常用来显示预览画面。
- SurfaceTexture：常用来显示预览画面。

### CameraCaptureSession
> CameraCaptureSession 实际上就是配置了一组目标 Surface 的 Pipeline 实例，我们在使用相机功能之前必须先创建 CameraCaptureSession 实例。一个 CameraDevice 一次只能开启一个 CameraCaptureSession，绝大部分的相机操作都是通过向 CameraCaptureSession 提交一个 Capture 请求实现的，例如拍照、连拍、设置闪光灯模式、触摸对焦、显示预览画面等等。

通过如下代码在callback回调中获得：
```
CameraDevice.createCaptureSession(List<Surface> outputs, CameraCaptureSession.StateCallback callback, Handler handler)
```

主要功能：
- 关闭Capture通道。
- 取消所有正在执行和挂起的Capture。
- CameraCaptureSession.capture：发送请求。
- CameraCaptureSession.setRepeatingRequest：发送循环请求。

### Surface
> Surface 是一块用于填充图像数据的内存空间，例如你可以使用 SurfaceView 的 Surface 接收每一帧预览数据用于显示预览画面，也可以使用 ImageReader 的 Surface 接收 JPEG 或 YUV 数据。每一个 Surface 都可以有自己的尺寸和数据格式，你可以从 CameraCharacteristics 获取某一个数据格式支持的尺寸列表。

Surface可以从SurfaceTexture、ImageReader等中获得。

设置Surface缓冲区大小。
```
    val previewSize = getOptimalSize(cameraCharacteristics, SurfaceTexture::class.java, maxWidth, maxHeight)!!
    // Set the SurfaceTexture's buffer size with preview size.
    val previewSurfaceTexture = previewSurfaceTextureFuture!!.get()!!
    previewSurfaceTexture.setDefaultBufferSize(previewSize.width, previewSize.height)
    val previewSurface = Surface(previewSurfaceTexture)
    @WorkerThread
    private fun getOptimalSize(cameraCharacteristics: CameraCharacteristics, clazz: Class<*>, maxWidth: Int, maxHeight: Int): Size? {
        val streamConfigurationMap = cameraCharacteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
        val supportedSizes = streamConfigurationMap?.getOutputSizes(clazz)
        return getOptimalSize(supportedSizes, maxWidth, maxHeight)
    }

    @AnyThread
    private fun getOptimalSize(supportedSizes: Array<Size>?, maxWidth: Int, maxHeight: Int): Size? {
        val aspectRatio = maxWidth.toFloat() / maxHeight
        if (supportedSizes != null) {
            for (size in supportedSizes) {
                if (size.width.toFloat() / size.height == aspectRatio && size.height <= maxHeight && size.width <= maxWidth) {
                    return size
                }
            }
        }
        return null
    }
```

### CaptureRequest
> CaptureRequest 是向 CameraCaptureSession 提交 Capture 请求时的信息载体，其内部包括了本次 Capture 的参数配置和接收图像数据的 Surface。CaptureRequest 可以配置的信息非常多，包括图像格式、图像分辨率、传感器控制、闪光灯控制、3A 控制等等，可以说绝大部分的相机参数都是通过 CaptureRequest 配置的。值得注意的是每一个 CaptureRequest 表示一帧画面的操作，这意味着你可以精确控制每一帧的 Capture 操作。

CaptureRequest通过CameraDevice获得：
```
val requestBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)
```

因为 CaptureRequest 可以配置的参数实在是太多了，如果每一个参数都要我们手动去配置，那真的是既复杂又费时，所以 Camera2 根据使用场景的不同，为我们事先配置好了一些常用的参数模板：
- TEMPLATE_RECORD：适用于视频录制的模板。
- TEMPLATE_STILL_CAPTURE：适用于拍照的模板。
- TEMPLATE_VIDEO_SNAPSHOT：适用于在录制视频过程中支持拍照的模板。
- TEMPLATE_MANUAL：适用于希望自己手动配置大部分参数的模板。

一个CaptureRequest除了需要配置大量配置之外还需要配置输出图像数据的Surface，这个Surface也必须在创建Session时添加到Session中。Surface可添加多个。
```
requestBuilder.addTarget(previewSurface)
```
通过 CaptureRequest.Builder.build() 方法创建出一个只读的 CaptureRequest 实例：
```
val request = requestBuilder.build()
```

### 疑问
#### 1. Camera2 焦点的坑

#### 2. Camera2 拍照 方向旋转调整

#### 3. captureBuilder.set(CaptureRequest.JPEG_ORIENTATION, jpegOrientation);

捕获拍照时设置CaptureRequest.JPEG_ORIENTATION会导致部分手机(HUAWEI P20)与 2. 设置冲突。

```
2020-09-09 16:47:06.646 16760-16949/com.jrxj.lookback E/CrashReport: java.lang.NullPointerException: Attempt to invoke virtual method 'void android.graphics.SurfaceTexture.setDefaultBufferSize(int, int)' on a null object reference
        at com.jrxj.lookback.ui.activity.ImagePreviewActivity.setPreviewSize(ImagePreviewActivity.java:420)
        at com.jrxj.lookback.ui.activity.ImagePreviewActivity.handleMessage(ImagePreviewActivity.java:172)
        at android.os.Handler.dispatchMessage(Handler.java:103)
        at android.os.Looper.loop(Looper.java:230)
        at android.os.HandlerThread.run(HandlerThread.java:67)

```
