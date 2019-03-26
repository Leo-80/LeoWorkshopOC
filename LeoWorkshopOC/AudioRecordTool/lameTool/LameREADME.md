##lame静态库生成及使用

###第一步：下载[lame](https://sourceforge.net/projects/lame/files/lame/3.99/)的最新版本并解压

下载后的文件不能直接使用，需要打包成静态库来使用

###第二步:生成静态库

1、在桌面上新建lameBuild文件夹

2、将下载解压后的文件夹（lame-3.100）拷贝到刚刚新建的文件夹中并改名为”lame“

3、在lameBuild新建.sh脚本文件，命令如下

```
-> cd  Desktop/lamebuild
-> touch build_lame.sh
-> open build_lame.sh
```
4、复制如下脚本到build_lame.sh中

```
#!/bin/sh

CONFIGURE_FLAGS="--disable-shared --disable-frontend"

ARCHS="arm64 armv7s x86_64 i386 armv7"

# directories
SOURCE="lame"
FAT="fat-lame"

SCRATCH="scratch-lame"
# must be an absolute path
THIN=`pwd`/"thin-lame"

COMPILE="y"
LIPO="y"

if [ "$*" ]
then
if [ "$*" = "lipo" ]
then
# skip compile
COMPILE=
else
ARCHS="$*"
if [ $# -eq 1 ]
then
# skip lipo
LIPO=
fi
fi
fi

if [ "$COMPILE" ]
then
CWD=`pwd`
for ARCH in $ARCHS
do
echo "building $ARCH..."
mkdir -p "$SCRATCH/$ARCH"
cd "$SCRATCH/$ARCH"

if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
then
PLATFORM="iPhoneSimulator"
if [ "$ARCH" = "x86_64" ]
then
SIMULATOR="-mios-simulator-version-min=7.0"
HOST=x86_64-apple-darwin
else
SIMULATOR="-mios-simulator-version-min=5.0"
HOST=i386-apple-darwin
fi
else
PLATFORM="iPhoneOS"
SIMULATOR=
HOST=arm-apple-darwin
fi

XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
CC="xcrun -sdk $XCRUN_SDK clang -arch $ARCH"
#AS="$CWD/$SOURCE/extras/gas-preprocessor.pl $CC"
CFLAGS="-arch $ARCH $SIMULATOR"
if ! xcodebuild -version | grep "Xcode [1-6]\."
then
CFLAGS="$CFLAGS -fembed-bitcode"
fi
CXXFLAGS="$CFLAGS"
LDFLAGS="$CFLAGS"

CC=$CC $CWD/$SOURCE/configure \
$CONFIGURE_FLAGS \
--host=$HOST \
--prefix="$THIN/$ARCH" \
CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"

make -j3 install
cd $CWD
done
fi

if [ "$LIPO" ]
then
echo "building fat binaries..."
mkdir -p $FAT/lib
set - $ARCHS
CWD=`pwd`
cd $THIN/$1/lib
for LIB in *.a
do
cd $CWD
lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB
done

cd $CWD
cp -rf $THIN/$1/include $FAT
fi

```

5、启动命令行输入如下命令 

```
-> cd Desktop/lamebuild
-> sh build_lame.sh
```

#注意：如果报command line tools 路径找不到错误，请前往xcode -> Preferences->Locations->Command Line Tools: 选择对应xcode即可

6、辨已完成后，检查是否编译成功。打开build_lame文件下，发现多了一个fat-lame,查看里面lib文件夹，有一个libmp3lame.a 文件,代表编译成功

##第三步：使用
1、将fat-lame ->include->lame->lame.h 和  fat-lame-> lib -> libmp3lame.a 这两个文件加入项目中 

2、在需要使用的文件中引用 #import "lame.h"

3、加入如下代码

```
- (NSString *)audioRecordTypeToMP3:(NSString *)filePath isDelSourceFile:(BOOL)isDel{
    // 输入路径
    NSString *inPath = filePath;
    // 判断输入路径是否存在
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) {
        NSLog(@"文件不存在");
    }
    // 输出路径
    NSString *outPath = [[filePath stringByDeletingPathExtension] stringByAppendingString:@".mp3"];
    
    @try {
        int read, write;
        FILE *pcm = fopen([inPath cStringUsingEncoding:1], "rb");//被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);
        FILE *mp3 = fopen([outPath cStringUsingEncoding:1], "wb");//生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        // 初始化lame编码器
        lame_t lame = lame_init();
        // 设置lame mp3编码的采样率 / 声道数 / 比特率
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_num_channels(lame,2);
        lame_set_out_samplerate(lame, 11025.0);
        lame_set_brate(lame, 8);
        // MP3音频质量.0~9.其中0是最好,非常慢,9是最差.
        lame_set_quality(lame, 7);
        
        // 设置mp3的编码方式
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            size_t size = (size_t)(2 * sizeof(short int));
            read = fread(pcm_buffer, size, PCM_SIZE, pcm);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        // 转码完成
        if (isDel) {
            NSError * error;
            [fm removeItemAtPath:filePath error:&error];
            if (error == nil) {
                NSLog(@"原文件删除成功！");
            }
        }
        return outPath;
    }
}
```