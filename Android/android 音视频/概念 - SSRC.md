### 转载自
[音视频技术 —— 音频处理工具SSRC](https://www.cnblogs.com/renhui/articles/12166070.html)

音频处理工具SSRC能提供转换采样率、采样位数、音量等功能。

### 1、[下载地址](https://github.com/shibatch/SSRC)

### 2、SSRC介绍
SSRC —— A fast and high quality sampling rate converter written by Naoki Shibata

Homepage : http://shibatch.sourceforge.net/ e-mail : shibatch@users.sourceforge.net

This program converts sampling rates of PCM wav files. This program also has a function to apply dither to its output and extend perceived dynamic range.

Sampling rates of 44.1kHz and 48kHz are populary used, but the ratio between these two frequencies is 147:160, which are not small numbers. As a result, sampling rate conversion without degradation of sound quality requires filter with very large order, and it is difficult to have both quality and speed. This program quickly converts between these sampling frequencies without audible degradation.

### 3、总结
一款命令行转换工具，可以转换采样率、音量、保存位数等，转换效果很好。比取平均值的方案效果好多了。

对于一个音频应用的开发人员来说，感觉质量很高，效果也是够用，唯一的不足就是效率较慢。

此外，有人基于[Java](https://github.com/umjammer/vavi-sound/tree/67db9c098c079a356b42627310e9c622342fde43/src/main/java/vavi/sound/pcm/resampling/ssrc)重写了一套，有兴趣的可以了解一下。
