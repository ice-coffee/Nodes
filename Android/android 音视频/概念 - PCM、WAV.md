### 转载自
[多媒体基础知识之PCM数据](https://www.cnblogs.com/CoderTian/p/6657844.html)

### 参考

[参考文献1](http://soundfile.sapp.org/doc/WaveFormat/)
[参考文献2](http://www.lightlink.com/tjweber/StripWav/Canon.html)
[参考文献3](http://www.topherlee.com/software/pcm-tut-wavformat.html)

[视音频数据处理入门：PCM音频采样数据处理](http://blog.csdn.net/leixiaohua1020/article/details/50534316)
[PCM、WAV格式介绍及用C语言实现PCM转WAV](http://blog.csdn.net/u010011236/article/details/53026127)

### 1.什么是PCM音频数据
PCM(Pulse Code Modulation)也被称为脉冲编码调制。PCM音频数据是未经压缩的音频采样数据裸流，它是由模拟信号经过采样、量化、编码转换成的标准的数字音频数据。PCM格式文件中不包含头部信息，播放器无法知道采样率、声道数、采样位数、音频数据大小等信息，所以无法播放，可转为WAV格式播放。

### 2.PCM音频数据是如何存储的
如果是单声道的音频文件，采样数据按时间的先后顺序依次存入（有的时候也会采用LRLRLR方式存储，只是另一个声道的数据为0），如果是双声道的话就按照LRLRLR的方式存储，存储的时候还和机器的大小端有关。大端模式如下图所示：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_pcm.png)

### 3.PCM音频数据中常用的专业术语
一般我们描述PCM音频数据的参数的时候有如下描述方式

    44100HZ 16bit stereo: 每秒钟有 44100 次采样, 采样数据用 16 位(2字节)记录, 双声道(立体声);
    22050HZ 8bit  mono: 每秒钟有 22050 次采样, 采样数据用 8 位(1字节)记录, 单声道;
    
44100Hz指的是采样率，它的意思是每秒取样44100次。采样率越大，存储数字音频所占的空间就越大。

16bit指的是采样精度，意思是原始模拟信号被采样后，每一个采样点在计算机中用16位（两个字节）来表示。采样精度越高越能精细地表示模拟信号的差异。

一般来说PCM数据中的波形幅值越大，代表音量越大。

### 4.PCM音频数据的处理

#### 4.3.将PCM音频数据转换成WAV格式
WAV为微软公司（Microsoft)开发的一种声音文件格式，它符合RIFF(Resource Interchange File Format)文件规范，用于保存Windows平台的音频信息资源，被Windows平台及其应用程序所广泛支持。WAVE文件通常只是一个具有单个“WAVE”块的RIFF文件，该块由两个子块（”fmt”子数据块和”data”子数据块），它的格式如下图所示

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_wav.png)

该格式的实质就是在PCM文件的前面加了一个文件头，每个字段的的含义为


```
typedef struct{
       char          ChunkID[4];//内容为"RIFF"
       unsigned long ChunkSize;//存储文件的字节数（不包含ChunkID和ChunkSize这8个字节）
       char          Format[4];//内容为"WAVE"
   }WAVE_HEADER;
   typedef struct{
        char          Subchunk1ID[4];//内容为"fmt"
        unsigned long  Subchunk1Size;//存储该子块的字节数（不含前面的Subchunk1ID和Subchunk1Size这8个字节）
        unsigned short AudioFormat;//存储音频文件的编码格式，例如若为PCM则其存储值为1，若为其他非PCM格式的则有一定的压缩。
        unsigned short NumChannels;//通道数，单通道(Mono)值为1，双通道(Stereo)值为2，等等
        unsigned long  SampleRate;//采样率，如8k，44.1k等
        unsigned long  ByteRate;//每秒存储的bit数，其值=SampleRate * NumChannels * BitsPerSample/8
        unsigned short BlockAlign;//块对齐大小，其值=NumChannels * BitsPerSample/8
        unsigned short BitsPerSample;//每个采样点的bit数，一般为8,16,32等。
   }WAVE_FMT;
   typedef struct{
        char          Subchunk2ID[4];//内容为“data”
        unsigned long Subchunk2Size;//内容为接下来的正式的数据部分的字节数，其值=NumSamples * NumChannels * BitsPerSample/8
   }WAVE_DATA;
```

比如下面的例子

这里是一个WAVE文件的开头72字节，字节显示为十六进制数字：

    52 49 46 46 24 08 00 00 57 41 56 45 66 6d 74 20 10 00 00 00 01 00 02 00 
    22 56 00 00 88 58 01 00 04 00 10 00 64 61 74 61 00 08 00 00 00 00 00 00 
    24 17 1e f3 3c 13 3c 14 16 f9 18 f9 34 e7 23 a6 3c f2 24 f2 11 ce 1a 0d 
字段解析：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_pcm_to_wav.png)

代码实现为
```
int simplest_pcm16le_to_wave(const char *pcmpath,int channels,int sample_rate,const char *wavepath)
{
    typedef struct WAVE_HEADER{  
        char         fccID[4];        
        unsigned   long    dwSize;            
        char         fccType[4];    
    }WAVE_HEADER;  
    typedef struct WAVE_FMT{  
        char         fccID[4];        
        unsigned   long       dwSize;            
        unsigned   short     wFormatTag;    
        unsigned   short     wChannels;  
        unsigned   long       dwSamplesPerSec;  
        unsigned   long       dwAvgBytesPerSec;  
        unsigned   short     wBlockAlign;  
        unsigned   short     uiBitsPerSample;  
    }WAVE_FMT;  
    typedef struct WAVE_DATA{  
        char       fccID[4];          
        unsigned long dwSize;              
    }WAVE_DATA;  
    if(channels==0||sample_rate==0){
    channels = 2;
    sample_rate = 44100;
    }
    int bits = 16;
    WAVE_HEADER   pcmHEADER;  
    WAVE_FMT   pcmFMT;  
    WAVE_DATA   pcmDATA;  
 
    unsigned   short   m_pcmData;
    FILE   *fp,*fpout;  
    fp=fopen(pcmpath, "rb");
    if(fp == NULL) {  
        printf("open pcm file error\n");
        return -1;  
    }
    fpout=fopen(wavepath,   "wb+");
    if(fpout == NULL) {    
        printf("create wav file error\n");  
        return -1; 
    }        
    //WAVE_HEADER
    memcpy(pcmHEADER.fccID,"RIFF",strlen("RIFF"));                    
    memcpy(pcmHEADER.fccType,"WAVE",strlen("WAVE"));  
    fseek(fpout,sizeof(WAVE_HEADER),1); 
    //WAVE_FMT
    pcmFMT.dwSamplesPerSec=sample_rate;  
    pcmFMT.dwAvgBytesPerSec=pcmFMT.dwSamplesPerSec*sizeof(m_pcmData);  
    pcmFMT.uiBitsPerSample=bits;
    memcpy(pcmFMT.fccID,"fmt ",strlen("fmt "));  
    pcmFMT.dwSize=16;  
    pcmFMT.wBlockAlign=2;  
    pcmFMT.wChannels=channels;  
    pcmFMT.wFormatTag=1;  
 
    fwrite(&pcmFMT,sizeof(WAVE_FMT),1,fpout); 
    //WAVE_DATA;
    memcpy(pcmDATA.fccID,"data",strlen("data"));  
    pcmDATA.dwSize=0;
    fseek(fpout,sizeof(WAVE_DATA),SEEK_CUR);
    fread(&m_pcmData,sizeof(unsigned short),1,fp);
    while(!feof(fp)){  
        pcmDATA.dwSize+=2;
        fwrite(&m_pcmData,sizeof(unsigned short),1,fpout);
        fread(&m_pcmData,sizeof(unsigned short),1,fp);
    }  
    pcmHEADER.dwSize=44+pcmDATA.dwSize;
    rewind(fpout);
    fwrite(&pcmHEADER,sizeof(WAVE_HEADER),1,fpout);
    fseek(fpout,sizeof(WAVE_FMT),SEEK_CUR);
    fwrite(&pcmDATA,sizeof(WAVE_DATA),1,fpout);
    
    fclose(fp);
    fclose(fpout);
    return 0;
}
```
